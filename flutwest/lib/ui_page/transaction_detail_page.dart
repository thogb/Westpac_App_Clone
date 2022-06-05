import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/cust_widget/cust_fake_appbar.dart';
import 'package:flutwest/cust_widget/cust_radio.dart';
import 'package:flutwest/cust_widget/cust_text_field_search.dart';
import 'package:flutwest/cust_widget/loading_text.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_transaction.dart';
import 'package:flutwest/model/transaction_filter.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/filtering_page.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../cust_widget/cust_button.dart';

class TransactionDetailPage extends StatefulWidget {
  final Account account;
  final bool isInputting;

  const TransactionDetailPage(
      {Key? key, required this.account, this.isInputting = false})
      : super(key: key);

  @override
  _TransactionDetailPageState createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage>
    with TickerProviderStateMixin {
  static const int loadingIncrement = 10;

  late final AnimationController _fakeAppBarController = AnimationController(
      duration: const Duration(milliseconds: 300), vsync: this);
  /*
  late final Animation<double> _fakeAppBarFade =
      CurvedAnimation(parent: _fakeAppBarController, curve: Curves.linear);

  late final Animation<double> _fakeAppBarSize =
      CurvedAnimation(parent: _fakeAppBarController, curve: Curves.linear);*/

  late final Animation<double> _fakeAppBarFade =
      Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _fakeAppBarController, curve: Curves.easeIn));

  late final Animation<double> _fakeAppBarSize =
      Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _fakeAppBarController, curve: Curves.easeIn));

  final TextEditingController _textEditingController = TextEditingController();

  // String _transactionType = AccountTransaction.allTypes;
  String _transactionType = AccountTransaction.allTypes;

  bool _isInputting = false;
  // int _nOfProcessed = 0;
  int _readLimits = 20;
  // late double _prevbalance;
  // DateTime _prevDateTime = Vars.invalidDateTime;

  bool _noMoreDataToLoad = false;

  double? _amountSearch;
  String? _descriptionSearch;

  // final List<TransactionGroup> _transactionGroups = [];

  final ScrollController _scrollController = ScrollController();
  bool _showLoading = false;

  late TransactionFilter _transactionFilter;
  late TransactionFilter _resetTransactionFilter;

  @override
  void initState() {
    if (widget.isInputting) {
      _fakeAppBarController.animateTo(1.0, duration: Duration.zero);
    }
    _isInputting = widget.isInputting;
    _scrollController.addListener(_onScrollTransactions);

    _resetTransactionFilter = TransactionFilter();
    _transactionFilter = TransactionFilter();

    // _prevbalance = widget.account.getBalance;

    super.initState();
  }

  @override
  void dispose() {
    _fakeAppBarController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustFakeAppbar(
            bottomspaceHeight: Vars.heightGapBetweenWidgets / 2,
            scrollController: _scrollController,
            content: Container(
              padding: const EdgeInsets.only(top: 38.0),
              child: Column(
                children: [
                  SizeTransition(
                    axisAlignment: -1,
                    sizeFactor: _fakeAppBarSize,
                    child: FadeTransition(
                      opacity: _fakeAppBarFade,
                      child: _getFakeAppBar(),
                    ),
                  ),
                  _getSearchBar(),
                  const SizedBox(height: Vars.topBotPaddingSize),
                  _getFilters(),
                  const SizedBox(
                    height: Vars.topBotPaddingSize,
                  )
                ],
              ),
            ),
          ),
          //Expanded(child: _getTransactionList())
          Expanded(
              child: FutureBuilder(
            future: FirestoreController.instance.colTransaction.getAllLimitBy(
                widget.account.getNumber, _readLimits,
                transactionType: _transactionType,
                amount: _amountSearch,
                description: _descriptionSearch,
                startAmount: _transactionFilter.getStartAmount,
                endAmount: _transactionFilter.getEndAmount,
                startDate: _transactionFilter.getStartDate,
                endDate: _transactionFilter.getEndDate),
            builder: (context, snapshots) {
              if (snapshots.hasError) {
                print(snapshots.error);
                return const Center(child: Text("Error"));
              }

              // print(
              // "${DateTime.now()} --- ${_readLimits} --------------------------- before length and hasData = ${snapshots.hasData} + ${(snapshots.data as QuerySnapshot<Map<String, dynamic>>).docs.length} + ${snapshots.connectionState}");

              if ((!_showLoading ||
                      snapshots.connectionState == ConnectionState.done) &&
                  snapshots.hasData) {
                QuerySnapshot<Map<String, dynamic>> readTransactions =
                    snapshots.data as QuerySnapshot<Map<String, dynamic>>;
                _showLoading = false;

                if (readTransactions.docs.isEmpty) {
                  return const Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.all(Vars.standardPaddingSize),
                        child: Text("No Transactions"),
                      ));
                }

                //_nOfTransactions = readTransactions.docs.length;

                AccountTransaction accountTransaction;
                AccountTransactionPersp accountTransactionPersp;
                Decimal actualAmount;
                int _nOfProcessed = 0;
                Decimal _prevbalance = widget.account.getBalance;
                DateTime _prevDateTime = Vars.invalidDateTime;
                List<TransactionGroup> _transactionGroups = [];
                // print(
                // "------------------------------length is + ${_transactionGroups.length}");

                Decimal? startAmount = _transactionFilter.getStartAmount != null
                    ? Decimal.parse(
                        _transactionFilter.getStartAmount.toString())
                    : null;
                Decimal? endAmount = _transactionFilter.getEndAmount != null
                    ? Decimal.parse(_transactionFilter.getEndAmount.toString())
                    : null;
                String? descriptionSearch = _descriptionSearch?.toLowerCase();
                if (_amountSearch != null) {
                  startAmount =
                      Decimal.parse((_amountSearch! - 0.050).toString());
                  endAmount =
                      Decimal.parse((_amountSearch! + 0.050).toString());
                }
                print(descriptionSearch);
                while (_nOfProcessed < readTransactions.docs.length) {
                  accountTransaction = AccountTransaction.fromMap(
                      readTransactions.docs[_nOfProcessed].data(),
                      readTransactions.docs[_nOfProcessed].id);
                  print(
                      "$descriptionSearch ------ ${accountTransaction.description[widget.account.accountID]}");
                  if ((startAmount == null ||
                          accountTransaction.amount >= startAmount) &&
                      (endAmount == null ||
                          accountTransaction.amount <= endAmount) &&
                      (descriptionSearch == null ||
                          (accountTransaction
                                      .description[widget.account.getNumber] !=
                                  null &&
                              accountTransaction
                                  .description[widget.account.getNumber]!
                                  .toLowerCase()
                                  .contains(descriptionSearch)))) {
                    actualAmount = accountTransaction
                        .getAmountPerspReceiver(widget.account.getNumber);
                    accountTransactionPersp = AccountTransactionPersp(
                        actualAmount: actualAmount,
                        balance: _prevbalance,
                        accountTransaction: accountTransaction);

                    if (Vars.isSameDay(
                        accountTransaction.getDateTime, _prevDateTime)) {
                      _transactionGroups[_transactionGroups.length - 1]
                          .add(accountTransactionPersp);
                    } else {
                      _prevDateTime = accountTransaction.getDateTime;
                      _transactionGroups.add(TransactionGroup(
                          transactions: [accountTransactionPersp],
                          dateTime: accountTransaction.getDateTime));
                    }
                    _prevbalance = _prevbalance - actualAmount;
                  }
                  _nOfProcessed++;
                }

                _noMoreDataToLoad = _readLimits >
                    readTransactions.docs.length + loadingIncrement;

                /*return ListView.builder(
                  controller: _scrollController,
                  itemCount: readTransactions.docs.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 30,
                      child: Text(readTransactions.docs[index]
                          .data()[AccountTransaction.fnDescription]),
                    );
                  },
                );*/

                bool showBalance = _transactionFilter.isAllFilterAny();

                return SafeArea(
                  top: false,
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      controller: _scrollController,
                      itemCount: _transactionGroups.length + 1,
                      itemBuilder: (context, index) {
                        //return _transactionGroups[index];
                        if (index == _transactionGroups.length) {
                          if (snapshots.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                                padding: const EdgeInsets.only(
                                    bottom: Vars.topBotPaddingSize),
                                child: _getLoading("Loading more"));
                          }

                          if (_noMoreDataToLoad) {
                            return const Padding(
                                padding: EdgeInsets.only(
                                    bottom: Vars.topBotPaddingSize),
                                child: Center(
                                    child: Text("No More Transactions")));
                          }

                          return const SizedBox(
                              height: Vars.topBotPaddingSize * 3);
                        }

                        return StickyHeader(
                            header: _getTransactionLineBr(
                                _transactionGroups[index].dateTime),
                            content: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: _transactionGroups[index]
                                    .transactions
                                    .length,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemBuilder: (context, indexTwo) {
                                  // print(
                                  // "$index + types = ${_transactionGroups[index].transactions[indexTwo].accountTransaction.transactionTypes} ++ = $_transactionType");
                                  return _getTransactionButton(
                                      _transactionGroups[index]
                                          .transactions[indexTwo],
                                      showBalance);
                                }));
                      }),
                );
              }

              return Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Vars.topBotPaddingSize),
                  child: _getLoading("Loading"),
                ),
              );
            },
          )),
        ],
      ),
    );
  }

  void _clearTransactions() async {
    if (_scrollController.positions.isNotEmpty) {
      await _scrollController.animateTo(0,
          duration: const Duration(microseconds: 1), curve: Curves.easeIn);
    }
    _noMoreDataToLoad = false;
    _showLoading = true;
    _readLimits = 20;
  }

  void _onScrollTransactions() {
    if (!_noMoreDataToLoad && _scrollController.position.extentAfter == 0.0) {
      setState(() {
        _readLimits += loadingIncrement;
      });
    }
  }

  Widget _getLoading(String msg) {
    return LoadingText.getLoadingWithMessage(msg);
  }

  Widget _getFakeAppBar() {
    return StandardPadding(
        showVerticalPadding: true,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.red[900],
              ),
            ),
            const SizedBox(width: Vars.standardPaddingSize),
            StandardPadding(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "WestPac ${widget.account.type}",
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Transaction",
                  style: TextStyle(fontSize: 12.0),
                )
              ],
            ))
          ],
        ));
  }

  Widget _getSearchBar() {
    return StandardPadding(
      child: CustTextFieldSearch(
        autoFocus: _isInputting,
        hintText: "Search by name, date, amount",
        textEditingController: _textEditingController,
        onFocus: (bool hasFocus) {
          if (hasFocus) {
            _clearTransactions();
            _fakeAppBarController.forward();
          }
        },
        onSubmitted: (String value) async {
          double? val = double.tryParse(value);

          if (value.isNotEmpty) {
            if (val != null) {
              if (val != _amountSearch) {
                _clearTransactions();
                setState(() {
                  _amountSearch = val;

                  if (_descriptionSearch != null) {
                    _descriptionSearch = null;
                  }
                });
              }
            } else {
              if (_amountSearch != null) {
                setState(() {
                  _amountSearch = null;
                });
              }

              if (value != _descriptionSearch && value.length > 2) {
                if (_scrollController.positions.isNotEmpty) {
                  await _scrollController.animateTo(0,
                      duration: const Duration(microseconds: 1),
                      curve: Curves.easeIn);
                }
                _clearTransactions();
                setState(() {
                  _descriptionSearch = value;
                });
              }
            }
          } else {
            _clearTransactions();
            setState(() {
              if (_amountSearch != null) {
                _amountSearch = null;
              }

              if (_descriptionSearch != null) {
                _descriptionSearch = null;
              }
            });
          }
        },
        onClearButtonTap: () {
          _clearTransactions();
          setState(() {
            //_textEditingController.clear();
            _amountSearch = null;
            _descriptionSearch = null;
          });
        },
        onPrefixButtonTap: () {
          _fakeAppBarController.reverse();
          _clearTransactions();
          setState(() {
            //_textEditingController.clear();
            _amountSearch = null;
            _descriptionSearch = null;
          });
        },
      ),
    );
  }

  Widget _getFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: List.generate(AccountTransaction.types.length + 1, (index) {
        if (index == 0) {
          return Padding(
            padding: CustRadio.smallPaddingRight
                .copyWith(left: Vars.standardPaddingSize),
            child: GestureDetector(
              onTap: () async {
                Object? result = await Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder:
                            ((context, animation, secondaryAnimation) =>
                                FilteringPage(
                                    filterType: false,
                                    filter: _transactionFilter,
                                    resetFilter: _resetTransactionFilter))));
                if (result != null && (result as bool)) {
                  _clearTransactions();
                  setState(() {
                    _transactionFilter;
                  });
                }
              },
              child: CustRadio.getTypeOne(
                  name: "Filter",
                  backGroundColor: CustRadio.unselectColor,
                  fontColor: Colors.black,
                  trailing: const Icon(
                    Icons.arrow_drop_down,
                    size: 15,
                  )),
            ),
          );
        }
        return CustRadio.typeOne(
            padding: CustRadio.smallPaddingRight,
            value: AccountTransaction.types[index - 1],
            groupValue: _transactionType,
            onChanged: (value) async {
              if (_scrollController.positions.isNotEmpty) {
                await _scrollController.animateTo(0,
                    duration: const Duration(microseconds: 1),
                    curve: Curves.easeIn);
              }
              if (_transactionType != value) {
                _clearTransactions();
                setState(() {
                  _transactionType = value;
                });
              }
            },
            name: AccountTransaction.types[index - 1]);
      })),
    );
  }

  Widget _getTransactionLineBr(DateTime dateTime) {
    return Material(
      color: Colors.grey[50],
      child: StandardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: Vars.heightGapBetweenWidgets / 2.0,
            ),
            Text(Utils.getDateTimeWDDMYToday(dateTime)),
            const SizedBox(height: 2.0),
            Container(
              height: 1,
              color: Colors.black12,
            )
          ],
        ),
      ),
    );
  }

  Widget _getTransactionButton(
      AccountTransactionPersp accountTransactionPersp, bool showBalance) {
    AccountTransaction accountTransaction =
        accountTransactionPersp.accountTransaction;
    Decimal actualAmount = accountTransactionPersp.actualAmount;
    Decimal balance = accountTransactionPersp.balance;

    return CustButton(
      onTap: () {},
      padding: const EdgeInsets.fromLTRB(Vars.standardPaddingSize, 5.0,
          Vars.standardPaddingSize, Vars.topBotPaddingSize),
      borderOn: false,
      paragraphStyle: const TextStyle(fontSize: 16.0),
      leftWidget: const Icon(
        Icons.monetization_on_sharp,
        size: 30,
      ),
      paragraph:
          accountTransaction.description[widget.account.accountID.getNumber],
      rightWidget: Padding(
        padding: const EdgeInsets.only(left: 45.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              actualAmount >= Decimal.fromInt(0)
                  ? "\$${Utils.formatDecimalMoneyUS(actualAmount)}"
                  : "-\$${Utils.formatDecimalMoneyUS(-actualAmount)}",
              style: TextStyle(
                  color:
                      actualAmount > Decimal.fromInt(0) ? Colors.green : null),
            ),
            showBalance
                ? Text("bal \$${Utils.formatDecimalMoneyUS(balance)}")
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}

class AccountTransactionPersp {
  final Decimal actualAmount;
  final Decimal balance;
  final AccountTransaction accountTransaction;

  AccountTransactionPersp({
    required this.actualAmount,
    required this.balance,
    required this.accountTransaction,
  });
}

class TransactionGroup {
  final DateTime dateTime;
  final List<AccountTransactionPersp> transactions;

  const TransactionGroup({required this.transactions, required this.dateTime});

  void add(AccountTransactionPersp accountTransactionPersp) {
    transactions.add(accountTransactionPersp);
  }
}
