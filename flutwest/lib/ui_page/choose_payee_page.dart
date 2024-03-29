import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/cust_widget/clickable_text.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/cust_fake_appbar.dart';
import 'package:flutwest/cust_widget/cust_radio.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';
import 'package:flutwest/cust_widget/cust_text_field_search.dart';
import 'package:flutwest/cust_widget/loading_text.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/payee.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/add_payee_page.dart';
import 'package:flutwest/ui_page/payee_info_page.dart';
import 'package:flutwest/ui_page/payment_page.dart';

class ChoosePayeePage extends StatefulWidget {
  final String memberId;
  final DateTime? recentPayeeEdit;
  final List<Account> accounts;
  final Account? currAccount;
  const ChoosePayeePage(
      {Key? key,
      required this.accounts,
      required this.memberId,
      required this.recentPayeeEdit,
      this.currAccount})
      : super(key: key);

  @override
  _ChoosePayeePageState createState() => _ChoosePayeePageState();
}

class _ChoosePayeePageState extends State<ChoosePayeePage>
    with TickerProviderStateMixin {
  //static const String recentPaymentKey = "recent_payment";
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
  //final Map<String, bool> _alphabetHeaderIndexs = {};
  final List<Payee> _recentPayees = [];
  final List<List<Payee>> _payeeGroups = [];
  List<Payee> _payees = [];
  bool _requireReconstruct = false;
  String _filterKeyword = "";
  bool _madeAnyPayment = false;

  @override
  void initState() {
    _futurePayees = FirestoreController.instance.colMember.colPayee
        .getAllLocal(widget.memberId, widget.recentPayeeEdit);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          _onBackPressed();
          return true;
        },
        child: Column(
          children: [
            const SizedBox(height: Vars.gapAtTop),
            _getFakeAppBar(),
            Expanded(child: _getPayeeList())
          ],
        ),
      ),
    );
  }

  void _resetPayeeData() {
    //_alphabetHeaderIndexs.clear();
    _payeeGroups.clear();
    _recentPayees.clear();
  }

  void _onBackPressed() {
    Navigator.pop(context, _madeAnyPayment);
  }

  Widget _getFakeAppBar() {
    return CustFakeAppbar(
      scrollController: _scrollController,
      content: Container(
        padding: const EdgeInsets.only(top: 0, bottom: 15),
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
                          child: const Icon(Icons.close,
                              color: Vars.clickAbleColor),
                          onTap: () {
                            _onBackPressed();
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
              hintText: "Search",
              textEditingController: _tecSearch,
              onFocus: (bool isFocused) {
                if (isFocused) {
                  _fakeAppBarController.forward();
                }

                _applyFilter();
              },
              onPrefixButtonTap: () {
                _fakeAppBarController.reverse();
              },
              onChanged: (String value) {
                _applyFilter();
              },
            )),
            const SizedBox(height: Vars.heightGapBetweenWidgets),

            // Payee filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                    payeeFilters.length,
                    (index) => CustRadio.typeOne(
                        padding: index == 0
                            ? CustRadio.smallPaddingRight
                                .copyWith(left: Vars.standardPaddingSize)
                            : CustRadio.smallPaddingRight,
                        value: payeeFilters[index],
                        groupValue: _currFilter,
                        onChanged: (value) {
                          setState(() {
                            _currFilter = value;
                          });
                        },
                        name: payeeFilters[index])),
              ),
            ),
            /*
            Material(
              borderOnForeground: false,
              elevation: 3,
              child: Container(
                height: 20,
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  void _applyFilter() {
    String processedValue = _tecSearch.text.toLowerCase().trim();
    if (processedValue != _filterKeyword.toLowerCase()) {
      setState(() {
        _filterKeyword = processedValue;
      });
    }
  }

  void _showBottomSheet() {
    TextStyle headingButtonStyle = const TextStyle(
        fontSize: Vars.headingTextSize3, fontWeight: FontWeight.w600);
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                const CustTextButton(
                  heading: "Add new",
                  headingTextStyle: TextStyle(
                      fontSize: Vars.headingTextSize3, color: Colors.black54),
                ),
                CustTextButton(
                  headingTextStyle: headingButtonStyle,
                  heading: "BSB & Account",
                  onTap: () async {
                    Navigator.pop(context);
                    Object? result = await Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                ((context, animation, secondaryAnimation) =>
                                    AddPayeePage(
                                      memberId: widget.memberId,
                                      accounts: widget.accounts,
                                      currAccount: widget.accounts[0],
                                    ))));
                    if (result != null) {
                      Payee newPayee = result as Payee;

                      _payees.add(newPayee);
                      // _payees.sort(
                      // ((a, b) => a.getNickName.compareTo(b.getNickName)));
                      //_sortPayeeList(_payees);
                      await _waitPaymentPage(newPayee);
                      setState(() {
                        _requireReconstruct = true;
                        //_payees.length;
                      });
                    }
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
                ),
              ],
            ),
          );
        });
  }

  Future<Object?> _waitPaymentPage(Payee payee) async {
    Object? result = await Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: ((context, animation, secondaryAnimation) =>
                PaymentPage(
                    memberId: widget.memberId,
                    payee: payee,
                    accounts: widget.accounts,
                    currAccount: widget.currAccount ?? widget.accounts[0])),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero));

    return result;
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
            if (payees != null) {
              if (_payees.isEmpty) {
                _payees = payees;
              }

              if (_payees.isEmpty) {
                return const Align(
                    alignment: Alignment.topCenter, child: Text("No Payees"));
              }

              if (_requireReconstruct || _payeeGroups.isEmpty) {
                _resetPayeeData();
                DateTime now = DateTime.now();
                DateTime sevenDayAgo =
                    DateTime(now.year, now.month, now.day - 7);

                Utils.sortPayeeListByLastPay(_payees);

                for (int i = 0; i < 5; i++) {
                  if (i < _payees.length &&
                      _payees[i].lastPayDate != null &&
                      _payees[i].lastPayDate!.isAfter(sevenDayAgo)) {
                    _recentPayees.add(_payees[i]);
                  }
                }

                Utils.sortPayeeList(payees);
                //currChar = _payees[0].getNickName[0].toUpperCase();
                String currChar = "";
                List<Payee> group = [];

                for (int i = 0; i < _payees.length; i++) {
                  if (currChar == _payees[i].getNickName[0].toUpperCase()) {
                    group.add(_payees[i]);
                  } else {
                    if (group.isNotEmpty) {
                      _payeeGroups.add(group);
                      //print(group.length);
                    }
                    group = [];
                    group.add(_payees[i]);
                    currChar = _payees[i].getNickName[0].toUpperCase();
                  }
                }
                _payeeGroups.add(group);
                _requireReconstruct = false;
              }

              return SafeArea(
                top: false,
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    controller: _scrollController,
                    itemCount:
                        _payeeGroups.length + (_recentPayees.isEmpty ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index == 0 && _recentPayees.isNotEmpty) {
                        List<Payee> displayPayees = [];
                        for (Payee payee in _recentPayees) {
                          if (_payeeSatisfyFilter(payee)) {
                            displayPayees.add(payee);
                          }
                        }

                        if (displayPayees.isEmpty) {
                          return const SizedBox();
                        }

                        return Column(
                            children: List.generate(
                                displayPayees.length + 1,
                                (index) => index == 0
                                    ? _getPayeeHeader("Recently paid")
                                    : _getRecentPayeeButton(
                                        displayPayees[index - 1])));
                        /*
                        if (_payeeSatisfyFilter(_recentPayees[index])) {
                          bool? displayHeader =
                              _alphabetHeaderIndexs[recentPaymentKey];
                          if (displayHeader != null && !displayHeader) {
                            _alphabetHeaderIndexs[recentPaymentKey] = true;
                            return Column(children: [
                              _getPayeeHeader("Recently paid"),
                              _getRecentPayeeButton(_recentPayees[index])
                            ]);
                          } else {
                            return _getRecentPayeeButton(_recentPayees[index]);
                          }
                        }*/
                      } else {
                        int actualIndex =
                            index - (_recentPayees.isEmpty ? 0 : 1);
                        List<Payee> displayPayees = [];

                        for (Payee payee in _payeeGroups[actualIndex]) {
                          if (_payeeSatisfyFilter(payee)) {
                            displayPayees.add(payee);
                          }
                        }

                        if (displayPayees.isEmpty) {
                          return const SizedBox();
                        }

                        return Column(
                            children: List.generate(
                                displayPayees.length + 1,
                                (index) => index == 0
                                    ? _getPayeeHeader(displayPayees
                                        .first.getNickName[0]
                                        .toUpperCase())
                                    : _getPayeeButton(
                                        displayPayees[index - 1])));
                        /*
                        int actualIndex = index - _recentPayees.length;
                        Payee payee = _payees[actualIndex];
              
                        if (_payeeSatisfyFilter(payee)) {
                          String initialUpper =
                              payee.getNickName[0].toUpperCase();
                          bool? displayHeader =
                              _alphabetHeaderIndexs[initialUpper];
                          if (displayHeader != null && !displayHeader) {
                            _alphabetHeaderIndexs[initialUpper] = true;
                            return Column(
                              children: [
                                _getPayeeHeader(
                                    payee.getNickName[0].toUpperCase()),
                                _getPayeeButton(payee)
                              ],
                            );
                          } else {
                            return _getPayeeButton(payee);
                          }
                        }
                      }
                      return const SizedBox();*/
                      }
                    }),
              );
            }
          }

          return const LoadingText(repeats: 2);
        }));
  }

  Widget _getPayeeHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Vars.gapBetweenTextVertical,
          horizontal: Vars.standardPaddingSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: Vars.headingTextSize3)),
          const SizedBox(height: Vars.gapBetweenTextVertical),
          const Divider(height: 0.5, color: Colors.black54)
        ],
      ),
    );
  }

  Widget _getRecentPayeeButton(Payee payee) {
    return CustButton(
      borderOn: false,
      heading: payee.getNickName,
      headingStyle: const TextStyle(fontSize: Vars.headingTextSize2),
      paragraph: "${payee.getAccountID.getBsb} ${payee.getAccountID.getNumber}",
      rightWidget: Text(
        Utils.getDateTimeWDDNM(payee.lastPayDate!),
        style: const TextStyle(
          fontSize: Vars.headingTextSize3,
        ),
      ),
      onTap: () async {
        // This payee already on recent payee area no need to reconstruct
        await handlePaymentPage(payee);
      },
    );
  }

  Widget _getPayeeButton(Payee payee) {
    return CustButton(
      borderOn: false,
      heading: payee.getNickName,
      headingStyle: const TextStyle(fontSize: Vars.headingTextSize2),
      paragraph: "${payee.getAccountID.getBsb} ${payee.getAccountID.getNumber}",
      rightWidget: GestureDetector(
          child: const Icon(Icons.info_outline),
          onTap: () async {
            Object? result = await Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder: ((context, animation, secondaryAnimation) =>
                        PayeeInfoPage(
                            memberId: widget.memberId,
                            payee: payee,
                            accounts: widget.accounts)),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero));
            if (result != null) {
              if ((result as bool) == true) {
                _payees.remove(payee);
                setState(() {
                  _requireReconstruct = true;
                });
              }
            }
          }),
      onTap: () async {
        Object? result = await handlePaymentPage(payee);
        if (result != null && (result as bool)) {
          setState(() {
            _requireReconstruct = true;
          });
        }
      },
    );
  }

  bool _payeeSatisfyFilter(Payee payee) {
    if (_filterKeyword.isEmpty) {
      return true;
    }

    return payee.getNickName.toLowerCase().contains(_filterKeyword) ||
        payee.getAccountName.toLowerCase().contains(_filterKeyword) ||
        payee.accountID.bsb.contains(_filterKeyword) ||
        payee.accountID.number.contains(_filterKeyword);
  }

  Future<Object?> handlePaymentPage(Payee payee) async {
    Object? result = await _waitPaymentPage(payee);
    _madeAnyPayment = (result != null && (result as bool)) || _madeAnyPayment;
    return result;
  }
}
