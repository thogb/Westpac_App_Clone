import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/cust_widget/cust_radio.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_transaction.dart';
import 'package:flutwest/model/vars.dart';
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
      Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
          parent: _fakeAppBarController, curve: Curves.decelerate));

  late final Animation<double> _fakeAppBarSize =
      Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
          parent: _fakeAppBarController, curve: Curves.decelerate));

  String _transactionType = AccountTransaction.types[0];

  bool _isInputting = false;
  bool _showElevation = false;
  int _nOfProcessed = 0;
  int _readLimits = 20;
  late double _prevbalance;
  DateTime _prevDateTime = Vars.invalidDateTime;

  bool _loadingData = false;
  bool _noMoreDataToLoad = false;

  final List<TransactionGroup> _transactionGroups = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _isInputting = widget.isInputting;
    _scrollController.addListener(_onScrollTransactions);

    _prevbalance = widget.account.getBalance;

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
      body: Column(
        children: [
          Material(
            elevation: _showElevation ? 4.0 : 0.0,
            child: Container(
              padding: const EdgeInsets.only(top: 30.0),
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
          const SizedBox(height: 5.0),
          //Expanded(child: _getTransactionList())
          Expanded(
              child: FutureBuilder(
            future: FirestoreController.instance
                .getTransactionLimitBy(widget.account.getNumber, _readLimits),
            builder: (context, snapshots) {
              if (snapshots.hasError) {
                return const Center(child: Text("Error"));
              }

              if (snapshots.hasData) {
                QuerySnapshot<Map<String, dynamic>> readTransactions =
                    snapshots.data as QuerySnapshot<Map<String, dynamic>>;

                if (readTransactions.docs.isEmpty) {
                  return const Center(child: Text("No Transactions"));
                }

                //_nOfTransactions = readTransactions.docs.length;

                AccountTransaction accountTransaction;
                AccountTransactionPersp accountTransactionPersp;
                double actualAmount;
                bool hasDataToProcess =
                    _nOfProcessed < readTransactions.docs.length;

                while (_nOfProcessed < readTransactions.docs.length) {
                  accountTransaction = AccountTransaction.fromMap(
                      readTransactions.docs[_nOfProcessed].data(),
                      readTransactions.docs[_nOfProcessed].id);
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
                    if (_loadingData) {
                      _transactionGroups[
                          _transactionGroups.length -
                              1] = TransactionGroup(
                          transactions:
                              _transactionGroups[_transactionGroups.length - 1]
                                  .transactions,
                          dateTime:
                              _transactionGroups[_transactionGroups.length - 1]
                                  .dateTime);
                    }
                  } else {
                    _prevDateTime = accountTransaction.getDateTime;
                    _transactionGroups.add(TransactionGroup(
                        transactions: [accountTransactionPersp],
                        dateTime: accountTransaction.getDateTime));
                  }

                  _prevbalance = _prevbalance - actualAmount;
                  _nOfProcessed++;
                }

                _noMoreDataToLoad = _readLimits >
                    readTransactions.docs.length + loadingIncrement;

                if (hasDataToProcess && !_noMoreDataToLoad) {
                  _loadingData = false;
                }

                return ListView.builder(
                    controller: _scrollController,
                    itemCount: _transactionGroups.length + 1,
                    itemBuilder: (context, index) {
                      //return _transactionGroups[index];
                      if (index == _transactionGroups.length) {
                        if (!_noMoreDataToLoad && _loadingData) {
                          return Container(
                              padding: const EdgeInsets.only(
                                  bottom: Vars.topBotPaddingSize),
                              child: _getLoading("Loading more"));
                        }

                        if (_noMoreDataToLoad) {
                          return const SizedBox(height: Vars.topBotPaddingSize);
                        }

                        return const SizedBox(
                            height: Vars.topBotPaddingSize * 3);
                      }

                      return StickyHeader(
                          header: _getTransactionLineBr(
                              _transactionGroups[index].dateTime),
                          content: ListView.builder(
                              itemCount:
                                  _transactionGroups[index].transactions.length,
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemBuilder: (context, indexTwo) {
                                return _getTransactionButton(
                                    _transactionGroups[index]
                                        .transactions[indexTwo]);
                              }));
                    });
              }

              return Align(
                alignment: Alignment.topCenter,
                child: _getLoading("Loading"),
              );
            },
          )),
        ],
      ),
    );
  }

  void _onScrollTransactions() {
    if (_scrollController.offset > 5.0) {
      if (_showElevation == false) {
        setState(() {
          _showElevation = true;
        });
      }
    } else {
      if (_showElevation == true) {
        setState(() {
          _showElevation = false;
        });
      }
    }

    if (!_loadingData &&
        !_noMoreDataToLoad &&
        _scrollController.position.extentAfter == 0.0) {
      _loadingData = true;
      setState(() {
        _readLimits += loadingIncrement;
      });
    }
  }

  Widget _getLoading(String msg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(msg,
            style: const TextStyle(fontSize: 15.0, color: Colors.black54)),
        const SizedBox(width: Vars.heightGapBetweenWidgets / 2),
        const SizedBox(
            height: 15.0,
            width: 15.0,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.black54,
            )),
      ],
    );
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
        child: TextField(
      onTap: () {
        _fakeAppBarController.forward();
        setState(() {
          _isInputting = true;
        });
      },
      style: const TextStyle(fontSize: 18.0),
      decoration: InputDecoration(
          prefixIcon: !_isInputting
              ? const Icon(Icons.search, color: Colors.black54)
              : GestureDetector(
                  onTap: () {
                    _fakeAppBarController.reverse();
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    setState(() {
                      _isInputting = false;
                    });
                  },
                  child: const Icon(Icons.arrow_back, color: Colors.black54)),
          contentPadding: EdgeInsets.zero,
          hintText: "Search by name, date, amount",
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0)),
          border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0))),
    ));
  }

  Widget _getFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: List.generate(AccountTransaction.types.length + 1, (index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(
                left: Vars.standardPaddingSize,
                right: Vars.heightGapBetweenWidgets / 2),
            child: GestureDetector(
              onTap: () {},
              child: CustRadio.getTypeOne("Filter", CustRadio.unselectColor,
                  Colors.black, const Icon(Icons.arrow_drop_down)),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Vars.heightGapBetweenWidgets / 2),
          child: CustRadio.typeOne(
              value: AccountTransaction.types[index - 1],
              groupValue: _transactionType,
              onChanged: (value) {
                setState(() {
                  _transactionType = value;
                });
              },
              name: AccountTransaction.types[index - 1]),
        );
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
            Text(
                "${Vars.days[dateTime.weekday]} ${dateTime.day} ${Vars.months[dateTime.month]} ${dateTime.year}"),
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
      AccountTransactionPersp accountTransactionPersp) {
    AccountTransaction accountTransaction =
        accountTransactionPersp.accountTransaction;
    double actualAmount = accountTransactionPersp.actualAmount;
    double balance = accountTransactionPersp.balance;

    return CustButton(
      onTap: () {},
      padding: const EdgeInsets.fromLTRB(Vars.standardPaddingSize, 5.0,
          Vars.standardPaddingSize, Vars.topBotPaddingSize),
      borderOn: false,
      paragraphStype: const TextStyle(fontSize: 16.0),
      leftWidget: const Icon(
        Icons.monetization_on_sharp,
        size: 30,
      ),
      paragraph: accountTransaction.getDescription,
      rightWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            actualAmount >= 0.0 ? "\$$actualAmount" : "-\$${-actualAmount}",
            style: TextStyle(color: actualAmount > 0.0 ? Colors.green : null),
          ),
          Text("bal \$$balance")
        ],
      ),
    );
  }
}

class AccountTransactionPersp {
  final double actualAmount;
  final double balance;
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
