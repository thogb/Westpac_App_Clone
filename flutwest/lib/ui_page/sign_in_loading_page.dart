import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/cust_widget/background_image.dart';
import 'package:flutwest/cust_widget/big_circular_loading.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/member.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/home_page.dart';

class SignInLoadingPage extends StatefulWidget {
  const SignInLoadingPage({Key? key}) : super(key: key);

  @override
  _SignInLoadingPageState createState() => _SignInLoadingPageState();
}

class _SignInLoadingPageState extends State<SignInLoadingPage> {
  final Future<DocumentSnapshot<Map<String, dynamic>>> _futureMember =
      FirestoreController.instance.colMember.getByDocId(Vars.fakeMemberID);
  final Future<QuerySnapshot<Map<String, dynamic>>> _futureAccounts =
      FirestoreController.instance.colAccount
          .getAllByMemberId(Vars.fakeMemberID);
  late final Future<List<Object>> _futures;

  List<Account> _accounts = [];
  late Member _member;

  @override
  void initState() {
    _futures = Future.wait([_futureMember, _futureAccounts]);
    Utils.showSysNavBarColour();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _getData();
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

  void _getData() async {
    List<Object> data = await _futures;
    QuerySnapshot<Map<String, dynamic>> queryAccounts =
        data[1] as QuerySnapshot<Map<String, dynamic>>;
    DocumentSnapshot<Map<String, dynamic>> queryMember =
        data[0] as DocumentSnapshot<Map<String, dynamic>>;
    if (queryMember.data() == null) {
      Navigator.pop(context,
          "Could not load member data of member: ${Vars.fakeMemberID}");
    }

    if (_accounts.isEmpty) {
      _accounts = queryAccounts.docs
          .map((e) => Account.fromMap(e.data(), e.id))
          .toList();
    }
    _member = Member.fromMap((queryMember.data() as Map<String, dynamic>),
        _accounts, queryMember.id);

    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: ((context, animation, secondaryAnimation) =>
                HomePage(member: _member, accounts: _accounts)),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero));
  }
}
