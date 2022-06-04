import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/controller/sqlite_controller.dart';
import 'package:flutwest/cust_widget/background_image.dart';
import 'package:flutwest/cust_widget/big_circular_loading.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/member.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/home_page.dart';

class SignInLoadingPage extends StatefulWidget {
  final String userName;
  final String password;
  const SignInLoadingPage(
      {Key? key, required this.userName, required this.password})
      : super(key: key);

  @override
  _SignInLoadingPageState createState() => _SignInLoadingPageState();
}

class _SignInLoadingPageState extends State<SignInLoadingPage> {
  late final Future<DocumentSnapshot<Map<String, dynamic>>> _futureMember;
  late final Future<QuerySnapshot<Map<String, dynamic>>> _futureAccounts;
  late final Future<List<Object>> _futures;

  final List<AccountOrderInfo> _accountOrderInfos = [];

  List<Account> _accounts = [];
  late Member _member;

  @override
  void initState() {
    Utils.showSysNavBarColour();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _trySignIn();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Stack(
              children: [const BackgroundImage(), _getLoadingContainer()])),
    );
  }

  Widget _getLoadingContainer() {
    double bigCircularLoadingSize = 100;
    double lockIconSize = 50;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(Vars.standardPaddingSize * 2),
        decoration: BoxDecoration(
            color: const Color.fromARGB(167, 27, 1, 31),
            borderRadius: BorderRadius.circular(3.0),
            border: Border.all(width: 1.0, color: Colors.grey)),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.vertical,
          children: [
            Stack(
              children: [
                BigCircularLoading(
                  width: bigCircularLoadingSize,
                  height: bigCircularLoadingSize,
                ),
                Positioned(
                    top: (bigCircularLoadingSize / 2) - (lockIconSize / 2),
                    left: (bigCircularLoadingSize / 2) - (lockIconSize / 2),
                    child: Icon(Icons.lock,
                        size: lockIconSize, color: Colors.white))
              ],
            ),
            const SizedBox(height: Vars.heightGapBetweenWidgets),
            const Text("Signing in...",
                style: TextStyle(
                    color: Colors.white, fontSize: Vars.headingTextSize2)),
            const SizedBox(height: Vars.standardPaddingSize * 0.5)
          ],
        ),
      ),
    );
  }

  Future<bool> _createOrderInfos(
      List<Account> accounts, String memberId) async {
    //TODO: memberID update with auth
    List<Account> accountsClone = accounts.toList();

    List<AccountIDOrder> accountIDOrders = await SQLiteController
        .instance.tableAccountOrder
        .getAccountIDsOrdered(memberId);

    AccountOrderInfo? temp;

    for (AccountIDOrder accountIDOrder in accountIDOrders) {
      AccountID accountID = accountIDOrder.getAccountID;
      temp = null;
      for (Account account in accountsClone) {
        if (account.getNumber == accountID.getNumber &&
            account.getBsb == accountID.getBsb) {
          temp = AccountOrderInfo(
              account: account,
              order: accountIDOrder.getOrder,
              hidden: accountIDOrder.getHidden);
          accountsClone.remove(account);
          _accountOrderInfos.add(temp);
          break;
        }
      }
    }

    for (Account account in accountsClone) {
      _accountOrderInfos.add(AccountOrderInfo(
          account: account, order: _accountOrderInfos.length, hidden: 0));
    }

    return true;
  }

  void _trySignIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: "${widget.userName}${Vars.fakeMail}",
              password: widget.password);
      DateTime lastLogin = DateTime.now();
      await SQLiteController.instance.tableMember
          .insertMemberIfNotExist(widget.userName, lastLogin);
      await SQLiteController.instance.tableMember
          .updateRecentLogin(memberId: widget.userName, dateTime: lastLogin);
      Member.lastLoginMemberId = widget.userName;

      _futureMember =
          FirestoreController.instance.colMember.getByDocId(widget.userName);
      _futureAccounts = FirestoreController.instance.colAccount
          .getAllByMemberId(widget.userName);

      _futures = Future.wait([_futureMember, _futureAccounts]);

      List<Object> data = await _futures;
      QuerySnapshot<Map<String, dynamic>> queryAccounts =
          data[1] as QuerySnapshot<Map<String, dynamic>>;
      DocumentSnapshot<Map<String, dynamic>> queryMember =
          data[0] as DocumentSnapshot<Map<String, dynamic>>;
      if (queryMember.data() == null) {
        Navigator.pop(context,
            "Could not load member data of member: ${Vars.fakeMemberID}");
        return;
      }

      if (_accounts.isEmpty) {
        _accounts = queryAccounts.docs
            .map((e) => Account.fromMap(e.data(), e.id))
            .toList();
      }
      _member = Member.fromMap((queryMember.data() as Map<String, dynamic>),
          _accounts, queryMember.id);

      await _createOrderInfos(_accounts, widget.userName);

      await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: ((context, animation, secondaryAnimation) => HomePage(
                  member: _member,
                  accounts: _accounts,
                  accountOrderInfos: _accountOrderInfos,
                )),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context, e);
      return;
    }
  }
}
