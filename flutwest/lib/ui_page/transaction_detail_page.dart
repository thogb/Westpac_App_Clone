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

  AccountTransactionPersp getLast() {
    return transactions.last;
  }
}

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

  late final Animation<double> _fakeAppBarFade =
      Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _fakeAppBarController, curve: Curves.easeIn));

  late final Animation<double> _fakeAppBarSize =
      Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _fakeAppBarController, curve: Curves.easeIn));

  final TextEditingController _textEditingController = TextEditingController();

  String _transactionType = AccountTransaction.allTypes;

  bool _isInputting = false;

  double? _amountSearch;
  String? _descriptionSearch;

  /// scroll controller for transctions' listview
  final ScrollController _scrollController = ScrollController();

  /// Stores the transctions in groups of same dates, stickyheader requireds
  /// content againts a header, trasnctions againts datetime
  final List<TransactionGroup> _transactionGroups = [];

  /// filter used for searching transactions, modified in [FilteringPage]
  late TransactionFilter _transactionFilter;

  /// filter used to represent the default filter used to by [FilteringPage] to
  /// reset [_transactionFilter] to this default filter options
  late TransactionFilter _resetTransactionFilter;

  /// If the there is error loading transctions from firebase
  bool _hasError = false;

  /// If there are more [AccountTransaction] to be loaded from firestore against
  /// the current [_transactionFilter]
  bool _noMoreData = false;

  /// The previous snapshot docs length that was read. Updated each time more
  /// transactions are read in each loop pass of [_getTransactions]. Used to
  /// calculate [_noMoreData], if previous transction docs length is same as
  /// current
  int _prevSnapshotLen = 0;

  /// This indicates still reading [AccountTransaction]s from firestore that
  /// [_transactionCount] is 0 and [_transactionGroups] is empty, that there are
  /// nothing to display in the listview. This is true when [_getTransactions]
  /// is called after [_resetTransactions]
  bool _isLoading = true;

  /// This is the count of the nubmer of [AccountTransaction]s read from
  /// firestore currently
  int _transactionCount = 0;

  /// This is indicate listview that more data are being read. This is when
  /// user scrolls to the last tranactions in listview and [_noMoreData] is
  /// false and [_transactionCount] is not 0. Triggered by scrolling to end of
  /// listview and [_noMoreData] is not empty.
  bool _loadingMore = false;

  /// This is the amount to be limited from firestore get
  int _readLimits = 0;

  /// This is how many [AccountTransaction] is to be displayed in the listview
  int _displayLimits = 20;

  @override
  void initState() {
    // Means open page with search text field on focus
    if (widget.isInputting) {
      _fakeAppBarController.animateTo(1.0, duration: Duration.zero);
    }

    _isInputting = widget.isInputting;
    _scrollController.addListener(_onScrollTransactions);

    _resetTransactionFilter = TransactionFilter();
    _transactionFilter = TransactionFilter();

    // _prevbalance = widget.account.getBalance;

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _resetTransactions();
      _getTransactions();
    });

    super.initState();
  }

  @override
  void dispose() {
    _fakeAppBarController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  /// Reset all variables used by [_getTransactions] due to filter changes, that
  /// requires retriving data again.
  Future<void> _resetTransactions() async {
    // Amimate listview to top, to remove the fake app bar elevation if any
    if (_scrollController.positions.isNotEmpty) {
      await _scrollController.animateTo(0,
          duration: const Duration(microseconds: 1), curve: Curves.easeIn);
    }

    _readLimits = 0;
    _displayLimits = 20;
    _noMoreData = false;
    _prevSnapshotLen = 0;
    _transactionCount = 0;
    _transactionGroups.clear();
    setState(() {
      _isLoading = true;
    });
  }

  /// Retrieves [AccountTransaction]s from firestore and updates
  /// [_transactionGroups] for listview to display.
  ///
  /// If [_transactionGroups] is empty and [_transactionCount] is 0, that this
  /// function is called after [_resetTransactions] then it means some filters
  /// change are applied and require retriving from firestore from start again.
  ///
  /// If [_transactionGroups] is not empty and [_transactionCount] is greater
  /// than 0 when this function is called. Then it means user has scrolled to
  /// the end of the listview and requiresz more data to be loaded by increasing
  /// [_readLimits] and previously increased [_displayLimits]
  void _getTransactions() async {
    int limitIncrement = 10;
    int readsMultiple = 2;
    _loadingMore = true;

    try {
      while (!_noMoreData && _transactionCount < _displayLimits) {
        // If this while loop runs more than once then it means that the first
        // time not enough transactions are retrieed, hence it means its hard
        // to find transactions that satisfy this filter requirement or search
        // requirement hence, each loop pass _readLimits is increased by a
        // multiple of two if limitIncrement
        _readLimits = _readLimits == 0
            ? 20
            : _readLimits + (limitIncrement * readsMultiple);
        readsMultiple *= 2;

        var snapShot = await FirestoreController.instance.colTransaction
            .getAllLimitBy(widget.account.getNumber, _readLimits,
                transactionType: _transactionType,
                amount: _amountSearch,
                description: _descriptionSearch,
                startAmount: _transactionFilter.getStartAmount,
                endAmount: _transactionFilter.getEndAmount,
                startDate: _transactionFilter.getStartDate,
                endDate: _transactionFilter.getEndDate);

        var docs = snapShot.docs;

        // Previous call to firestore returned same amount of docs means no more
        // data to be read
        _noMoreData = _prevSnapshotLen == docs.length;
        _prevSnapshotLen = docs.length;

        if (!_noMoreData) {
          // The past transaction id means the last transaction doc id in the
          // _transactionGroups or null if empty
          String? lastTransactionId = _transactionGroups.isEmpty
              ? null
              : _transactionGroups.last.getLast().accountTransaction.getId;

          // The balance of the last transactions or if no transactions then
          // means the account balance
          Decimal _prevBalance = _transactionGroups.isEmpty
              ? widget.account.getBalance
              : _transactionGroups.last.getLast().balance -
                  _transactionGroups.last.getLast().actualAmount;

          // From the new data read if there are already data stored from
          // previous reads then loop the snapshot docs until reach index of
          // the new data to be processed
          int index = 0;
          if (lastTransactionId != null) {
            while (index < docs.length && lastTransactionId != docs[index].id) {
              index++;
            }
            index++;
          }

          AccountTransaction accountTransaction;
          AccountTransactionPersp accountTransactionPersp;
          Decimal actualAmount = Decimal.zero;
          // Setting up filters
          Decimal? startAmount = _transactionFilter.getStartAmount != null
              ? Decimal.parse(_transactionFilter.getStartAmount.toString())
              : null;
          Decimal? endAmount = _transactionFilter.getEndAmount != null
              ? Decimal.parse(_transactionFilter.getEndAmount.toString())
              : null;
          String? descriptionSearch = _descriptionSearch?.toLowerCase();
          if (_amountSearch != null) {
            startAmount = Decimal.parse((_amountSearch! - 0.050).toString());
            endAmount = Decimal.parse((_amountSearch! + 0.050).toString());
          }
          // If there are some transactions stored already then get the last
          // group's dateTime and compare with new data, else chose a invalid
          // time
          DateTime prevDateTime = _transactionGroups.isEmpty
              ? Vars.invalidDateTime
              : _transactionGroups.last.dateTime;

          // Loop through all new datrra
          for (int i = index; i < docs.length; i++) {
            accountTransaction =
                AccountTransaction.fromMap(docs[i].data(), docs[i].id);
            // Check if satisfy the filter requirements
            bool passAmount = (startAmount == null ||
                    accountTransaction.amount >= startAmount) &&
                (endAmount == null || accountTransaction.amount <= endAmount);
            bool passDescription = (descriptionSearch == null ||
                (accountTransaction.description[widget.account.getNumber] !=
                        null &&
                    accountTransaction.description[widget.account.getNumber]!
                        .toLowerCase()
                        .contains(descriptionSearch)));
            bool passed = _amountSearch == null
                ? passAmount && passDescription
                : passAmount || passDescription;
            if (passed) {
              _transactionCount++;
              actualAmount = accountTransaction
                  .getAmountPerspReceiver(widget.account.getNumber);
              accountTransactionPersp = AccountTransactionPersp(
                  actualAmount: actualAmount,
                  balance: _prevBalance,
                  accountTransaction: accountTransaction);

              // This transaction is same day as the prev then add to the last
              // transaction group else create new transaction group and add to
              // this
              if (Vars.isSameDay(
                  accountTransaction.getDateTime, prevDateTime)) {
                _transactionGroups[_transactionGroups.length - 1]
                    .add(accountTransactionPersp);
              } else {
                prevDateTime = accountTransaction.getDateTime;
                _transactionGroups.add(TransactionGroup(
                    transactions: [accountTransactionPersp],
                    dateTime: accountTransaction.getDateTime));
              }
            }

            _prevBalance = _prevBalance - actualAmount;
          }
        }
      }
    } on Exception catch (e) {
      _hasError = true;
    }

    // displayLimits to the acutal amount amount read. display limit is is used
    // in while checks when enough transactions are read. In this loop pass more
    // transactions might be read than the displaylimit need to update avoid
    // setting while loop to true when there are more data to be loaded
    _displayLimits = _transactionCount;
    _loadingMore = false;

    // Set loading false
    if (_isLoading) {
      setState(() {
        _isLoading = false;
      });
    }

    // Update listview
    setState(() {
      _transactionGroups.length;
    });
  }

  Widget _getLoading(String msg) {
    return LoadingText.getLoadingWithMessage(msg);
  }

  Widget _getTransactionsListView() {
    if (_hasError) {
      return const Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.all(Vars.standardPaddingSize),
            child: Text("Error"),
          ));
    } else if (_isLoading) {
      return _getLoading("Loading");
    } else if (_transactionGroups.isEmpty) {
      return const Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.all(Vars.standardPaddingSize),
            child: Text("No Transactions"),
          ));
    } else {
      bool showBalance = _transactionFilter.isAllFilterAny();
      return Expanded(
        child: SafeArea(
          top: false,
          child: ListView.builder(
              padding: EdgeInsets.zero,
              controller: _scrollController,
              itemCount: _transactionGroups.length + 1,
              itemBuilder: (context, index) {
                //return _transactionGroups[index];
                if (index == _transactionGroups.length) {
                  if (_noMoreData) {
                    return const Padding(
                        padding:
                            EdgeInsets.only(bottom: Vars.topBotPaddingSize),
                        child: Center(child: Text("No More Transactions")));
                  } else {
                    return Container(
                        padding: const EdgeInsets.only(
                            bottom: Vars.topBotPaddingSize),
                        child: _getLoading("Loading more"));
                  }

                  //return const SizedBox(height: Vars.topBotPaddingSize * 3);
                }

                return StickyHeader(
                    header: _getTransactionLineBr(
                        _transactionGroups[index].dateTime),
                    content: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount:
                            _transactionGroups[index].transactions.length,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, indexTwo) {
                          // print(
                          // "$index + types = ${_transactionGroups[index].transactions[indexTwo].accountTransaction.transactionTypes} ++ = $_transactionType");
                          return _getTransactionButton(
                              _transactionGroups[index].transactions[indexTwo],
                              showBalance);
                        }));
              }),
        ),
      );
    }
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
          _getTransactionsListView()
        ],
      ),
    );
  }

  void _onScrollTransactions() {
    if (!_noMoreData &&
        !_loadingMore &&
        _scrollController.position.extentAfter == 0.0) {
      /*setState(() {
        _readLimits += loadingIncrement;
      });*/
      _displayLimits += loadingIncrement;
      _getTransactions();
    }
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
        onFocus: (bool hasFocus) async {
          if (hasFocus) {
            //await _resetTransactions();
            _fakeAppBarController.forward();
            //_getTransactions();
          }
        },
        onSubmitted: (String value) async {
          value = value.trim();
          //double? val = double.tryParse(value);
          _amountSearch = double.tryParse(value);
          _descriptionSearch = value;
          await _resetTransactions();
          _getTransactions();

          /*if (value.isNotEmpty) {
            if (val != null) {
              if (val != _amountSearch) {
                await _resetTransactions();
                setState(() {
                  _amountSearch = val;

                  /*if (_descriptionSearch != null) {
                    _descriptionSearch = null;
                  }*/
                });
                _getTransactions();
              }
            } else {
              if (_amountSearch != null) {
                setState(() {
                  _amountSearch = null;
                });
              }

              if (value != _descriptionSearch && value.length > 2) {
                await _resetTransactions();
                setState(() {
                  _descriptionSearch = value;
                });
                _getTransactions();
              }
            }
          } else {
            await _resetTransactions();
            setState(() {
              if (_amountSearch != null) {
                _amountSearch = null;
              }

              if (_descriptionSearch != null) {
                _descriptionSearch = null;
              }
            });
            _getTransactions();
          }*/
        },
        onClearButtonTap: () async {
          await _resetTransactions();
          setState(() {
            //_textEditingController.clear();
            _amountSearch = null;
            _descriptionSearch = null;
          });
          _getTransactions();
        },
        onPrefixButtonTap: () async {
          _fakeAppBarController.reverse();
          await _resetTransactions();
          setState(() {
            //_textEditingController.clear();
            _amountSearch = null;
            _descriptionSearch = null;
          });
          _getTransactions();
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
                  await _resetTransactions();
                  setState(() {
                    _transactionFilter;
                  });
                  _getTransactions();
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
              if (_transactionType != value) {
                await _resetTransactions();
                setState(() {
                  _transactionType = value;
                });
                _getTransactions();
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
