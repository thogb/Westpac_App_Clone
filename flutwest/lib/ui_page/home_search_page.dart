import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/cust_fake_appbar.dart';
import 'package:flutwest/cust_widget/cust_heading.dart';
import 'package:flutwest/cust_widget/cust_radio.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';
import 'package:flutwest/cust_widget/cust_text_field_search.dart';
import 'package:flutwest/cust_widget/loading_text.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_transaction.dart';
import 'package:flutwest/model/member.dart';
import 'package:flutwest/model/payee.dart';
import 'package:flutwest/model/transaction_filter.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/choose_payee_page.dart';
import 'package:flutwest/ui_page/filtering_page.dart';
import 'package:flutwest/ui_page/payment_page.dart';

class HomeSearchPage extends StatefulWidget {
  final List<Account> rawAccounts;
  final Member member;
  const HomeSearchPage(
      {Key? key, required this.member, required this.rawAccounts})
      : super(key: key);

  @override
  _HomeSearchPageState createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> {
  static const String filterTop = "Top";
  static const String filterSelfServe = "Self-serve";
  static const String filterTransactions = "Transactions";
  static const String filterPayeeAndBillers = "Payees & billers";
  static const String filterProducts = "Products";
  static const String filterFQAAndTopics = "FQA & topics";

  static const List<String> filters = [
    filterTop,
    filterSelfServe,
    filterTransactions,
    filterPayeeAndBillers,
    filterProducts,
    filterFQAAndTopics
  ];

  static const int limitIncrement = 10;
  static const int initialLimit = 20;

  final TextEditingController _tecSearch = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _filterScrollController = ScrollController();

  late final TransactionFilter _transactionFilter;
  late final TransactionFilter _resetTransactionFilter;

  late final Map<String, List<DateTime?>> _customDateFilters;

  String _currFilter = filterTop;
  String _prevFilter = filterTop;

  int _filterCount = 0;

  // Used by transactions section
  String? _descriptionSearch;
  double? _amountSearch;
  int _limit = initialLimit;
  int _prevTransactionCount = 0;
  bool _noMoreToLoad = false;
  bool _newSearch = true;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    DateTime now = DateTime.now();

    _transactionFilter = TransactionFilter(
        allAccounts: List.from(widget.rawAccounts),
        selectedAccounts: HashSet.from(widget.rawAccounts),
        date: TransactionFilter.otherDate,
        startDate: DateTime(now.year, now.month - 2),
        endDate: now);
    _resetTransactionFilter = TransactionFilter(
        allAccounts: List.from(widget.rawAccounts),
        selectedAccounts: HashSet.from(widget.rawAccounts),
        date: TransactionFilter.otherDate,
        startDate: DateTime(now.year, now.month - 2),
        endDate: now);

    _customDateFilters = Map.from(TransactionFilter.dates);
    //_customDateFilters.remove(TransactionFilter.anyDate);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (_currFilter == filterTransactions &&
        !_noMoreToLoad &&
        _scrollController.position.extentAfter == 0.0) {
      setState(() {
        _limit += limitIncrement;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          CustFakeAppbar(
            bottomspaceHeight: 3,
            scrollController: _scrollController,
            content: Column(
              children: [
                // Serach text field
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Vars.standardPaddingSize,
                      vertical: Vars.standardPaddingSize / 2),
                  child: CustTextFieldSearch(
                    textEditingController: _tecSearch,
                    autoFocus: true,
                    onPrefixButtonTap: () {
                      Navigator.pop(context);
                    },
                    onSubmitted: (value) async {
                      await resetScrollControllerPosition();
                      _resetTransactionsValue();
                      setState(() {
                        _currFilter;
                      });
                    },
                  ),
                ),
                const SizedBox(height: Vars.standardPaddingSize / 2),
                // filters
                SingleChildScrollView(
                  controller: _filterScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: List.generate(
                          filters.length,
                          (index) => CustRadio.typeOne(
                              padding: CustRadio.smallPaddingRight.copyWith(
                                  left: index == 0
                                      ? Vars.standardPaddingSize
                                      : 0.0),
                              value: filters[index],
                              groupValue: _currFilter,
                              onChanged: (value) async {
                                onFilterRadioTap(value);
                              },
                              name: filters[index]))),
                ),
                const SizedBox(height: Vars.standardPaddingSize),
                _currFilter != filterTransactions
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.all(Vars.standardPaddingSize),
                        child: CustButton(
                            leftWidget: const Icon(
                              Icons.filter_list,
                              color: Vars.radioFilterColor,
                              size: Vars.headingTextSize2,
                            ),
                            heading: "Filter",
                            headingStyle: CustButton.buttonHeadingStyle
                                .copyWith(
                                    color: Vars.radioFilterColor,
                                    fontSize: Vars.headingTextSize2),
                            rightWidget: Text("${1 + _filterCount}"),
                            onTap: () async {
                              Object? result = await Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                      pageBuilder: ((context, animation,
                                              secondaryAnimation) =>
                                          FilteringPage(
                                              datesFilters: _customDateFilters,
                                              filter: _transactionFilter,
                                              resetFilter:
                                                  _resetTransactionFilter))));
                              setState(() {
                                _filterCount = _transactionFilter
                                    .getChangedCount(_resetTransactionFilter);
                              });
                              if (result != null && (result as bool)) {
                                await resetScrollControllerPosition();
                                if (_currFilter == filterTransactions) {
                                  _resetTransactionsValue();
                                }

                                setState(() {
                                  _currFilter;
                                });
                              }
                            }))
              ],
            ),
          ),
          Expanded(
              child: _tecSearch.text.isNotEmpty && _tecSearch.text.length < 2
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                          SizedBox(height: Vars.heightGapBetweenWidgets),
                          Text("No result found."),
                          Text("We need 2 or more characters to search.")
                        ])
                  : _getContent())
        ],
      ),
    ));
  }

  Future<void> resetScrollControllerPosition() async {
    if (_scrollController.positions.isNotEmpty) {
      await _scrollController.animateTo(0,
          duration: const Duration(microseconds: 1), curve: Curves.easeIn);
    }
  }

  void onFilterRadioTap(String value) async {
    await resetScrollControllerPosition();
    if (value != _currFilter) {
      setState(() {
        _prevFilter = _currFilter;
        _currFilter = value;
      });

      if (value == filterTransactions) {
        _resetTransactionsValue();
      }
    }
  }

  Widget _getMessageWidget(String msg) {
    return LoadingText.getLoadingWithMessage(msg, loading: false);
  }

  Widget _getLoadingMessage(String msg) {
    return LoadingText.getLoadingWithMessage(msg);
  }

  Widget _getContent() {
    if (_currFilter == filterTop) {
      return _getTop();
    } else if (_currFilter == filterSelfServe) {
      return ListView(controller: _scrollController, children: [
        _getHeading("Popular services"),
        CustTextButton(heading: "Upcoming payments", onTap: () {}),
        CustTextButton(heading: "Payment list", onTap: () {}),
        CustTextButton(heading: "Set or change card PIN", onTap: () {}),
        CustTextButton(heading: "Switch to eStatements", onTap: () {}),
        CustTextButton(heading: "Activate card", onTap: () {})
      ]);
    } else if (_currFilter == filterTransactions) {
      return _getTransactions();
    } else if (_currFilter == filterPayeeAndBillers) {
      return _getPayeesAndBillers();
    } else if (_currFilter == filterProducts) {
      return ListView(controller: _scrollController, children: [
        _getHeading("Popular products"),
        CustTextButton(heading: "Bank accounts", onTap: () {}),
        CustTextButton(heading: "Low Rate Card", onTap: () {}),
        CustTextButton(heading: "Westpac eSaver", onTap: () {}),
        CustTextButton(heading: "Unsecured Personal Loan", onTap: () {})
      ]);
    } else if (_currFilter == filterFQAAndTopics) {
      return ListView(controller: _scrollController, children: [
        _getHeading("Popular FAQs & topics"),
        CustTextButton(heading: "New app FAQs", onTap: () {}),
        CustTextButton(heading: "How can I close an account?", onTap: () {}),
        CustTextButton(heading: "COVID-19: Customer support", onTap: () {}),
        CustTextButton(
            heading: "What security devices are available?", onTap: () {}),
        CustTextButton(
            heading: "Where can i get the SWIFT and BIC codes from",
            onTap: () {}),
        CustTextButton(heading: "Disaster preparation", onTap: () {}),
      ]);
    } else {
      return _getMessageWidget("Error");
    }
  }

  Widget _getTop() {
    String searchText = _tecSearch.text.trim();

    if (searchText.isEmpty) {
      return ListView(controller: _scrollController, children: [
        _getHeading("Popular searches"),
        CustTextButton(heading: "Cardless cash", onTap: () {}),
        CustTextButton(heading: "Rewards and offers", onTap: () {}),
        CustTextButton(heading: "Update contact details", onTap: () {}),
        CustTextButton(heading: "Report lost or stolen", onTap: () {})
      ]);
    }

    String nickNameSearch = searchText;

    if (nickNameSearch.length > 2 &&
        nickNameSearch.substring(0, 3).toLowerCase() == "pay") {
      nickNameSearch = nickNameSearch.substring(3).trim();
    }

    return FutureBuilder(
        future: FirestoreController.instance.colMember.colPayee.getQueriedLocal(
            memberId: widget.member.id,
            recentPayee: widget.member.recentPayeeChange,
            nickNameSearch: nickNameSearch),
        builder: ((context, AsyncSnapshot<List<Payee>> snapshot) {
          if (snapshot.hasError) {
            return _getMessageWidget("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _getLoadingMessage("Loading");
          }

          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            List<Payee> payees = snapshot.data!;

            double scrollOffSet = 0;

            for (String stuff in filters) {
              if (stuff != filterTransactions) {
                scrollOffSet += (stuff.length * CustRadio.defaultFontSize / 2) +
                    (CustRadio.typeOneInnerPadding.right * 2) +
                    CustRadio.smallPaddingRight.right;
              } else {
                break;
              }
            }

            return ListView(
              controller: _scrollController,
              children: [
                _getHeading("Transactions"),
                CustTextButton(
                    heading: "Show transactions for '$searchText'",
                    headingTextStyle: CustTextButton.textButtonHeadingStyle
                        .copyWith(color: Vars.clickAbleColor),
                    onTap: () {
                      _filterScrollController.animateTo(scrollOffSet,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.linear);
                      setState(() {
                        onFilterRadioTap(filterTransactions);
                      });
                    }),
                CustTextButton(
                    heading: "Show all recent transactions",
                    headingTextStyle: CustTextButton.textButtonHeadingStyle
                        .copyWith(color: Vars.clickAbleColor),
                    onTap: () {
                      _filterScrollController.animateTo(scrollOffSet,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.linear);
                      _tecSearch.clear();
                      setState(() {
                        onFilterRadioTap(filterTransactions);
                      });
                    }),
                payees.isEmpty
                    ? const SizedBox()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                            payees.length + 1,
                            (index) => index == 0
                                ? _getHeading("Payees & billers")
                                : _getPayeeButton(payees[index - 1])))
              ],
            );
          }

          return _getMessageWidget("Error");
        }));
  }

  void _resetTransactionsValue() {
    _limit = initialLimit;
    _noMoreToLoad = false;
    _newSearch = true;
  }

  Widget _getTransactions() {
    _amountSearch = null;
    _descriptionSearch = null;

    String input = _tecSearch.text.trim();

    if (input.isNotEmpty) {
      _amountSearch = double.tryParse(input);

      if (_amountSearch == null) {
        _descriptionSearch = input;
      }
    }

    return FutureBuilder(
        future: FirestoreController.instance.colTransaction.getAllLimitBy(
            "", _limit,
            description: _descriptionSearch,
            amount: _amountSearch,
            startAmount: _transactionFilter.getStartAmount,
            endAmount: _transactionFilter.getEndAmount,
            startDate: _transactionFilter.getStartDate,
            endDate: _transactionFilter.getEndDate,
            transactionType: _transactionFilter.getType,
            accountNumbers: _transactionFilter.selectedAccounts
                .map((e) => e.getNumber)
                .toList()),
        builder: ((context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return LoadingText.getLoadingWithMessage("Error", loading: false);
          }

          if (snapshot.hasData &&
              (!_newSearch ||
                  ConnectionState.done == snapshot.connectionState)) {
            _newSearch = false;
            QuerySnapshot<Map<String, dynamic>> readTransactions =
                snapshot.data!;
            List<AccountTransactionBinded> transactions = [];
            Map<String, Account> selectedAccountMap = {};
            HashSet<int> headerIndexes = HashSet();

            DateTime currDate = Vars.invalidDateTime;
            int count = 0;

            print(snapshot.data!.docs.length);

            _noMoreToLoad =
                _prevTransactionCount == readTransactions.docs.length;
            _prevTransactionCount = readTransactions.docs.length;

            for (Account account in _transactionFilter.selectedAccounts) {
              selectedAccountMap.addAll({account.getNumber: account});
            }

            print(selectedAccountMap.toString());

            for (var readTransaction in readTransactions.docs) {
              AccountTransaction accountTransaction =
                  AccountTransaction.fromMap(
                      readTransaction.data(), readTransaction.id);
              Account? account =
                  selectedAccountMap[accountTransaction.sender.getNumber];
              if (!Vars.isSameDay(currDate, accountTransaction.dateTime)) {
                headerIndexes.add(count);
                currDate = accountTransaction.dateTime;
              }
              if (account != null) {
                transactions.add(AccountTransactionBinded(
                    accountTransaction: accountTransaction, account: account));
                count++;
              }
              account =
                  selectedAccountMap[accountTransaction.receiver.getNumber];
              if (account != null) {
                transactions.add(AccountTransactionBinded(
                    accountTransaction: accountTransaction, account: account));
                count++;
              }
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: transactions.length + 1,
              itemBuilder: (context, index) {
                if (headerIndexes.contains(index)) {
                  return Column(children: [
                    _getheader(transactions[index].accountTransaction.dateTime),
                    _getTransactionButton(
                        transactions[index].accountTransaction,
                        transactions[index].account)
                  ]);
                } else if (index == transactions.length) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingText.getLoadingWithMessage("Loading more");
                  }

                  return const StandardPadding(
                    showVerticalPadding: true,
                    child: Center(
                        child: Text(
                      "Can't find what you're looking for?\nTry changing the date or amount range filter",
                      textAlign: TextAlign.center,
                    )),
                  );
                }

                return _getTransactionButton(
                    transactions[index].accountTransaction,
                    transactions[index].account);
              },
            );
          }

          return LoadingText.getLoadingWithMessage("Loading");
        }));
  }

  Widget _getheader(DateTime dateTime) {
    return StandardPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Utils.getDateTimeWDDMYToday(dateTime)),
          const SizedBox(height: Vars.gapBetweenTextVertical / 2),
          const Divider(
            height: 1,
            thickness: 0.5,
          )
        ],
      ),
    );
  }

  Widget _getTransactionButton(
      AccountTransaction accountTransaction, Account account) {
    Decimal amount =
        accountTransaction.getAmountPerspReceiver(account.getNumber);
    return CustButton(
      borderOn: false,
      leftWidget: const Icon(
        Icons.monetization_on_sharp,
        size: 30,
      ),
      heading: accountTransaction.getDescription[account.getNumber],
      headingStyle: const TextStyle(fontSize: Vars.headingTextSize3),
      paragraph: account.getAccountName,
      rightWidget: Padding(
        padding: const EdgeInsets.only(left: Vars.standardPaddingSize * 3),
        child: Text(
          "\$${Utils.formatDecimalMoneyUS(amount)}",
          style: TextStyle(color: amount > Decimal.zero ? Colors.green : null),
        ),
      ),
      onTap: () {},
    );
  }

  Widget _getPayeesAndBillers() {
    String nickNameSearch = _tecSearch.text.trim();
    Future<List<Payee>> futurePayees;

    if (nickNameSearch.isNotEmpty) {
      if (nickNameSearch.length > 2 &&
          nickNameSearch.substring(0, 3).toLowerCase() == "pay") {
        nickNameSearch = nickNameSearch.substring(3).trim();
      }
      futurePayees = FirestoreController.instance.colMember.colPayee
          .getQueriedLocal(
              memberId: widget.member.id,
              recentPayee: widget.member.recentPayeeChange,
              nickNameSearch: nickNameSearch);
    } else if (_prevFilter != filterPayeeAndBillers) {
      futurePayees = FirestoreController.instance.colMember.colPayee
          .getRecentPayLocal(
              memberId: widget.member.id,
              recentPayee: widget.member.recentPayeeChange);
    } else {
      futurePayees = Future.delayed(Duration.zero);
    }

    return FutureBuilder(
        future: futurePayees,
        builder: (context, AsyncSnapshot<List<Payee>?> snapshot) {
          if (snapshot.hasError) {
            return _getMessageWidget("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _getLoadingMessage("Loading");
          }

          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            List<Payee> payees = snapshot.data!;

            return ListView(
              controller: _scrollController,
              children: [
                payees.isEmpty
                    ? const SizedBox()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                            payees.length + 1,
                            (index) => index == 0
                                ? _getHeading("Recently paid")
                                : _getPayeeButton(payees[index - 1]))),
                _getHeading("Make a payment"),
                CustTextButton(
                    heading: "See all payees & billers",
                    onTap: () async {
                      Object? result = await Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: ((context, animation,
                                      secondaryAnimation) =>
                                  ChoosePayeePage(
                                      accounts: widget.rawAccounts,
                                      memberId: widget.member.id,
                                      recentPayeeEdit:
                                          widget.member.recentPayeeChange))));
                      if (result != null && (result as bool)) {
                        setState(() {
                          _currFilter;
                        });
                      }
                    })
              ],
            );
          }

          return _getMessageWidget("Error");
        });
  }

  Widget _getPayeeButton(Payee payee) {
    return CustButton(
      borderOn: false,
      leftWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              const Text("Pay ", style: Vars.headingStyle2),
              Text(payee.getNickName,
                  style:
                      Vars.headingStyle2.copyWith(color: Vars.clickAbleColor))
            ],
          ),
          const SizedBox(height: Vars.gapBetweenTextVertical),
          Text("${payee.accountID.getBsb} ${payee.accountID.getNumber}",
              style: Vars.paragraphStyleGrey)
        ],
      ),
      rightWidget: Column(
        children: [
          const SizedBox(height: Vars.headingTextSize2),
          Text(
              payee.lastPayDate != null
                  ? Utils.getDateTimeWDDM(payee.lastPayDate!)
                  : "N/A",
              style: const TextStyle(fontSize: Vars.headingTextSize2)),
        ],
      ),
      onTap: () async {
        Object? result = await Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: ((context, animation, secondaryAnimation) =>
                    PaymentPage(
                        accounts: widget.rawAccounts,
                        currAccount: widget.rawAccounts[0],
                        payee: payee,
                        memberId: widget.member.id))));
        if (result != null && (result as bool)) {
          setState(() {
            _currFilter;
          });
        }
      },
    );
  }

  Widget _getHeading(String text) {
    return CustHeading.big(
        showHorPadding: true,
        heading: text,
        textStyle:
            CustHeading.bigHeadingStyle.copyWith(color: Vars.radioFilterColor));
  }
}
