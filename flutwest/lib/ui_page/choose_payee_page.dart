import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/controller/sqlite_controller.dart';
import 'package:flutwest/cust_widget/clickable_text.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/cust_floating_button.dart';
import 'package:flutwest/cust_widget/cust_radio.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';
import 'package:flutwest/cust_widget/cust_text_field_search.dart';
import 'package:flutwest/cust_widget/editing_page_scaffold.dart';
import 'package:flutwest/cust_widget/loading_text.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/payee.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/add_payee_page.dart';

class ChoosePayeePage extends StatefulWidget {
  final String meberId;
  final DateTime? recentPayeeEdit;
  final List<Account> accounts;
  const ChoosePayeePage(
      {Key? key,
      required this.accounts,
      required this.meberId,
      required this.recentPayeeEdit})
      : super(key: key);

  @override
  _ChoosePayeePageState createState() => _ChoosePayeePageState();
}

class _ChoosePayeePageState extends State<ChoosePayeePage>
    with TickerProviderStateMixin {
  late final AnimationController _fakeAppBarController = AnimationController(
      duration: const Duration(milliseconds: 300), vsync: this);

  late final Animation<double> _fakeAppBarFade =
      Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
          parent: _fakeAppBarController, curve: Curves.decelerate));

  late final Animation<double> _fakeAppBarSize =
      Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
          parent: _fakeAppBarController, curve: Curves.decelerate));

  static const List<String> payeeFilters = [
    "All",
    "Payees",
    "Billers",
    "Internationals"
  ];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _tecSearch = TextEditingController();

  late final Future<List<Payee>?> _futurePayees;

  String _currFilter = payeeFilters[1];
  double _elevationLevel = 0;
  final HashSet<int> _alphabetHeaderIndexs = HashSet();
  final List<Payee> _recentPayees = [];

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    _futurePayees = _getPayees(widget.meberId, widget.recentPayeeEdit);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [_getFakeAppBar(), Expanded(child: _getPayeeList())],
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.offset > 10) {
      setState(() {
        if (_elevationLevel == 0) {
          _elevationLevel = 3;
        }
      });
    } else {
      setState(() {
        if (_elevationLevel != 0) {
          _elevationLevel = 0;
        }
      });
    }
  }

  Widget _getFakeAppBar() {
    return Container(
      padding: const EdgeInsets.only(top: Vars.gapAtTop - 5, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fake app bar heading part
          SizeTransition(
            axisAlignment: -1,
            sizeFactor: _fakeAppBarSize,
            child: FadeTransition(
              opacity: _fakeAppBarFade,
              child: StandardPadding(
                  showVerticalPadding: true,
                  child: Row(
                    children: [
                      GestureDetector(
                        child:
                            const Icon(Icons.close, color: Vars.clickAbleColor),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      const Expanded(
                          child: Text("Choose who to pay",
                              style: Vars.headingStyle1)),
                      ClickableText(
                        text: "Add",
                        textStyle: const TextStyle(
                            fontSize: Vars.headingTextSize2,
                            color: Vars.clickAbleColor),
                        onTap: _showBottomSheet,
                      )
                    ],
                  )),
            ),
          ),

          // Search text field
          StandardPadding(
              child: CustTextFieldSearch(
            textEditingController: _tecSearch,
            onFocus: () {
              _fakeAppBarController.forward();
            },
            onPrefixButtonTap: () {
              _fakeAppBarController.reverse();
            },
          )),
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // Payee filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                  payeeFilters.length,
                  (index) => Padding(
                        padding: EdgeInsets.only(
                            left: index == 0
                                ? Vars.standardPaddingSize
                                : Vars.standardPaddingSize / 2,
                            right: Vars.standardPaddingSize / 2),
                        child: CustRadio.typeOne(
                            value: payeeFilters[index],
                            groupValue: _currFilter,
                            onChanged: (value) {
                              setState(() {
                                _currFilter = value;
                              });
                            },
                            name: payeeFilters[index]),
                      )),
            ),
          ),
          Material(
            elevation: _elevationLevel,
            child: Container(
              height: Vars.heightGapBetweenWidgets,
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet() {
    TextStyle headingButtonStyle = const TextStyle(
        fontSize: Vars.headingTextSize3, fontWeight: FontWeight.w600);
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              const CustTextButton(
                heading: "Add new",
                headingTextStyle: TextStyle(
                    fontSize: Vars.headingTextSize3, color: Colors.black54),
              ),
              CustTextButton(
                headingTextStyle: headingButtonStyle,
                heading: "BSB & Account",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder:
                              ((context, animation, secondaryAnimation) =>
                                  const AddPayeePage())));
                },
              ),
              CustTextButton(
                headingTextStyle: headingButtonStyle,
                heading: "BPAY Biller",
              ),
              CustTextButton(
                headingTextStyle: headingButtonStyle,
                heading: "BSB & Account",
              ),
              CustTextButton(
                headingTextStyle: headingButtonStyle,
                heading: "International",
              ),
              CustTextButton(
                headingTextStyle: headingButtonStyle,
                heading: "Other PayID",
              )
            ],
          );
        });
  }

  /*
  Widget _getPayeeList() {
    return ListView.builder(
        padding: EdgeInsets.zero,
        controller: _scrollController,
        itemCount: 60,
        itemBuilder: ((context, index) => Container(
              height: 40,
              margin: const EdgeInsets.all(Vars.standardPaddingSize),
              color: Colors.red,
            )));
  }*/

  Future<List<Payee>?> _getPayees(
      String memberId, DateTime? memberRecentPayeeEdit) async {
    List<Payee>? payees;

    List<Payee> localPayees =
        await SQLiteController.instance.getPayees(memberId);
    DateTime? recentPayeeEdit =
        await SQLiteController.instance.getRecentPayeeEditDate(memberId);

    if (memberRecentPayeeEdit != null) {
      if (recentPayeeEdit == null || recentPayeeEdit != memberRecentPayeeEdit) {
        var remotePayees =
            await FirestoreController.instance.getPayees(memberId);
        SQLiteController.instance
            .syncPayees(remotePayees: remotePayees, localPayees: localPayees);
        payees = remotePayees;
      } else {
        payees = localPayees;
      }
    } else {
      payees = [];
    }

    return payees;
  }

  Widget _getPayeeList() {
    return FutureBuilder(
        future: _futurePayees,
        builder: ((context, AsyncSnapshot<List<Payee>?> snapshot) {
          if (snapshot.hasError) {
            return const Align(
                alignment: Alignment.topCenter, child: Text("Unknow Error"));
          }

          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            List<Payee>? payees = snapshot.data;
            if (payees != null && _alphabetHeaderIndexs.isEmpty) {
              if (payees.isEmpty) {
                return const Align(
                    alignment: Alignment.topCenter, child: Text("No Payees"));
              }

              String currChar;
              DateTime now = DateTime.now();
              DateTime sevenDayAgo = DateTime(now.year, now.month, now.day - 7);

              for (int i = 0; i < 5; i++) {
                if (i < payees.length &&
                    payees[i].lastPayDate != null &&
                    payees[i].lastPayDate!.isAfter(sevenDayAgo)) {
                  _recentPayees.add(payees[i]);
                }
              }

              currChar = payees[0].getNickName[0].toUpperCase();
              _alphabetHeaderIndexs.add(0);

              for (int i = 0; i < payees.length; i++) {
                if (currChar != payees[i].getNickName[i].toUpperCase()) {
                  currChar = payees[i].getNickName[i].toUpperCase();
                  _alphabetHeaderIndexs.add(i);
                }
              }

              return ListView.builder(
                  itemCount: _recentPayees.length + payees.length,
                  itemBuilder: (context, index) {
                    if (index < _recentPayees.length) {
                      if (index == 0) {
                        return Column(children: [
                          _getPayeeHeader("Recently paid"),
                          _getRecentPayeeButton(_recentPayees[index])
                        ]);
                      } else {
                        return _getRecentPayeeButton(_recentPayees[index]);
                      }
                    } else {
                      int actualIndex = index - _recentPayees.length;
                      Payee payee = payees[actualIndex];

                      if (_alphabetHeaderIndexs.contains(actualIndex)) {
                        return Column(
                          children: [
                            _getPayeeHeader(payee.getNickName[0].toUpperCase()),
                            _getPayeeButton(payee)
                          ],
                        );
                      } else {
                        return _getPayeeButton(payee);
                      }
                    }
                  });
            }
          }

          return const LoadingText(repeats: 2);
        }));
  }

  Widget _getPayeeHeader(String title) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: Vars.gapBetweenTextVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Vars.buttonPragraphStyle),
          const SizedBox(height: Vars.gapBetweenTextVertical),
          const Divider(height: 0.5, color: Colors.black54)
        ],
      ),
    );
  }

  Widget _getRecentPayeeButton(Payee payee) {
    return CustButton(
      heading: payee.getNickName,
      paragraph: "${payee.getAccountID.getBsb} ${payee.getAccountID.getNumber}",
      rightWidget: Text(
        Utils.getDateTimeWDDNM(payee.lastPayDate!),
        style: const TextStyle(
          fontSize: Vars.headingTextSize3,
        ),
      ),
    );
  }

  Widget _getPayeeButton(Payee payee) {
    return CustButton(
      heading: payee.getNickName,
      paragraph: "${payee.getAccountID.getBsb} ${payee.getAccountID.getNumber}",
      rightWidget: const Icon(Icons.info),
    );
  }
}
