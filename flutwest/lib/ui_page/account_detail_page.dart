import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/cust_widget/cust_appbar.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/loading_text.dart';
import 'package:flutwest/cust_widget/outlined_container.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/account_transaction.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/choose_payee_page.dart';
import 'package:flutwest/ui_page/payment_page.dart';
import 'package:flutwest/ui_page/transaction_detail_page.dart';
import 'package:flutwest/ui_page/transfer_page.dart';

import '../model/account.dart';

class AccountDetailPage extends StatefulWidget {
  final List<AccountOrderInfo> accounts;
  final int currIndex;
  final List<Account> rawAccounts;

  final String memberId;
  final DateTime? recentPayeeDate;

  const AccountDetailPage(
      {Key? key,
      required this.accounts,
      required this.currIndex,
      required this.rawAccounts,
      required this.memberId,
      required this.recentPayeeDate})
      : super(key: key);

  @override
  _AccountDetailPageState createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  late AccountOrderInfo _currAccount;

  late final PageController _pageController;
  final List<AccountDetailSection> _accountDetailSections = [];
  final List<ScrollController> _scrollControllers = [];
  late ScrollController _currScrollController = ScrollController();

  @override
  void initState() {
    _currAccount = widget.accounts[widget.currIndex];
    _pageController = PageController(initialPage: widget.currIndex);

    for (int i = 0; i < widget.accounts.length; i++) {
      ScrollController scrollController = ScrollController();
      _accountDetailSections.add(AccountDetailSection(
          onTransactionMade: _onTransactionMade,
          accounts: widget.rawAccounts,
          memberId: widget.memberId,
          recentPayeeDate: widget.recentPayeeDate,
          account: widget.accounts[i].getAccount(),
          scrollController: scrollController));
      _scrollControllers.add(scrollController);
    }
    _currScrollController = _scrollControllers[widget.currIndex];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustAppbar(
          scrollController: _currScrollController,
          scrollControllers: _scrollControllers,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.red[900],
            ),
          ),
          title: "Westpac ${_currAccount.getAccount().type}",
          subTitle:
              "\$${Utils.formatDecimalMoneyUS(_currAccount.getAccount().balance)}",
          trailing: [
            Padding(
              padding: const EdgeInsets.only(right: Vars.standardPaddingSize),
              child: Tooltip(
                message: "Additional Details",
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _currAccount = widget.accounts[2];
                      });
                    },
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.red[900],
                      size: 30,
                    )),
              ),
            )
          ],
        ),
        body: PageView(
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                _currAccount = widget.accounts[index];
                _currScrollController = _scrollControllers[index];
              });
            },
            children: _accountDetailSections));
  }

  void _onTransactionMade() {
    setState(() {
      _currAccount;
    });
  }
}

class AccountDetailSection extends StatefulWidget {
  final List<Account> accounts;
  final Account account;
  final ScrollController scrollController;
  final DateTime? recentPayeeDate;
  final String memberId;
  final VoidCallback onTransactionMade;

  const AccountDetailSection(
      {Key? key,
      required this.account,
      required this.scrollController,
      required this.accounts,
      required this.recentPayeeDate,
      required this.memberId,
      required this.onTransactionMade})
      : super(key: key);

  @override
  _AccountDetailSectionState createState() => _AccountDetailSectionState();
}

class _AccountDetailSectionState extends State<AccountDetailSection>
    with AutomaticKeepAliveClientMixin {
  static const TextStyle headingStyle =
      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);

  static const EdgeInsetsGeometry buttonMargin =
      EdgeInsets.symmetric(vertical: Vars.topBotPaddingSize / 2);

  static const BorderSide outlinedBorderSide =
      BorderSide(width: 0.5, color: Colors.black12);

  late Future<QuerySnapshot<Map<String, dynamic>>> _recentTransactions;

  @override
  void initState() {
    _recentTransactions = FirestoreController.instance.colTransaction
        .getAllLimitBy(widget.account.getNumber, 5);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
        future: _recentTransactions,
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          return SingleChildScrollView(
            controller: widget.scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Vars.standardPaddingSize,
                  vertical: Vars.topBotPaddingSize),
              child: Column(
                children: [
                  _getAccountInfo(widget.account),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _getSimpleButton(Icons.transfer_within_a_station, "Pay",
                          () async {
                        Object? result = await Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    ((context, animation, secondaryAnimation) =>
                                        ChoosePayeePage(
                                            currAccount: widget.account,
                                            accounts: widget.accounts,
                                            memberId: widget.memberId,
                                            recentPayeeEdit:
                                                widget.recentPayeeDate)),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero));
                        if (result != null && (result as bool)) {
                          widget.onTransactionMade();
                          setState(() {
                            _recentTransactions = FirestoreController
                                .instance.colTransaction
                                .getAllLimitBy(widget.account.getNumber, 5);
                          });
                        }
                      }),
                      const SizedBox(width: 10.0),
                      _getSimpleButton(
                          Icons.transfer_within_a_station, "Transfer",
                          () async {
                        Object? result = await Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    ((context, animation, secondaryAnimation) =>
                                        TransferPage(
                                            currAccount: widget.account,
                                            accounts: widget.accounts)),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero));
                        if (result != null && (result as bool)) {
                          widget.onTransactionMade();
                          setState(() {
                            _recentTransactions = FirestoreController
                                .instance.colTransaction
                                .getAllLimitBy(widget.account.getNumber, 5);
                          });
                        }
                      }),
                      const SizedBox(width: 10.0),
                      _getSimpleButton(
                          Icons.transfer_within_a_station, "BPay", () {})
                    ],
                  ),
                  const SizedBox(height: Vars.heightGapBetweenWidgets),
                  _getTransactionSummary(widget.account, snapshot),
                  _getBottomContent(widget.account),
                  const SizedBox(height: 40)
                ],
              ),
            ),
          );
        });

    //return _getAccountDetail(widget.account);
  }

  @override
  bool get wantKeepAlive => true;

  Widget _getTransactionLineBr(DateTime dateTime) {
    return StandardPadding(
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
    );
  }

  Widget _getTransactionButton(AccountTransaction transaction, Decimal balance,
      Decimal actualAmount, String? description) {
    return CustButton(
      onTap: () {},
      borderOn: false,
      paragraphStyle: const TextStyle(fontSize: 16.0),
      leftWidget: const Icon(
        Icons.monetization_on_sharp,
        size: 30,
      ),
      paragraph: description,
      rightWidget: Padding(
        padding: const EdgeInsets.only(left: 45.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              actualAmount > Decimal.fromInt(0)
                  ? "\$${actualAmount.round(scale: 2)}"
                  : "-\$${-actualAmount.round(scale: 2)}",
              style: TextStyle(
                  color:
                      actualAmount > Decimal.fromInt(0) ? Colors.green : null),
            ),
            Text("bal \$${balance.round(scale: 2)}")
          ],
        ),
      ),
    );
  }

  /*Widget _getAccountDetail(Account account) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Vars.standardPaddingSize,
            vertical: Vars.topBotPaddingSize),
        child: Column(
          children: [
            _getAccountInfo(account),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _getSimpleButton(Icons.transfer_within_a_station, "Pay",
                    () async {
                  Object? result = await Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder:
                              ((context, animation, secondaryAnimation) =>
                                  ChoosePayeePage(
                                      currAccount: widget.account,
                                      accounts: widget.accounts,
                                      memberId: widget.memberId,
                                      recentPayeeEdit: widget.recentPayeeDate)),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero));
                  if (result != null && (result as bool)) {
                    setState(() {
                      _recentTransactions = FirestoreController
                          .instance.colTransaction
                          .getAllLimitBy(widget.account.getNumber, 5);
                    });
                  }
                }),
                const SizedBox(width: 10.0),
                _getSimpleButton(Icons.transfer_within_a_station, "Transfer",
                    () async {
                  Object? result = await Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder:
                              ((context, animation, secondaryAnimation) =>
                                  TransferPage(
                                      currAccount: widget.account,
                                      accounts: widget.accounts)),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero));
                  if (result != null && (result as bool)) {
                    setState(() {
                      _recentTransactions = FirestoreController
                          .instance.colTransaction
                          .getAllLimitBy(widget.account.getNumber, 5);
                    });
                  }
                }),
                const SizedBox(width: 10.0),
                _getSimpleButton(Icons.transfer_within_a_station, "BPay", () {})
              ],
            ),
            const SizedBox(height: Vars.heightGapBetweenWidgets),
            _getTransactionSummary(account),
            _getBottomContent(account),
            const SizedBox(height: 40)
          ],
        ),
      ),
    );
  }*/

  Widget _getAccountInfo(Account account) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Vars.standardPaddingSize,
          vertical: Vars.topBotPaddingSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Westpac ${account.type}", style: headingStyle),
          const SizedBox(
            height: Vars.heightGapBetweenWidgets,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("BSB ${account.getBsb} Acct ${account.getNumber}"),
              Icon(
                Icons.share,
                size: 20,
                color: Colors.red[700],
              )
            ],
          ),
          Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: Vars.topBotPaddingSize * 2),
              child: Text("\$${Utils.formatDecimalMoneyUS(account.balance)}",
                  style: headingStyle)),
        ],
      ),
    );
  }

  Widget _getSimpleButton(
      IconData iconData, String title, VoidCallback callback) {
    return InkWell(
      onTap: callback,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: Vars.standardPaddingSize - 5,
            horizontal: Vars.standardPaddingSize),
        decoration: BoxDecoration(
            color: Colors.red[900], borderRadius: BorderRadius.circular(3.0)),
        child: Row(
          children: [
            Icon(iconData, color: Colors.white),
            const SizedBox(width: 4.0),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16.0),
            )
          ],
        ),
      ),
    );
  }

  Widget _getTransactionSummary(Account account,
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    return Padding(
      padding: buttonMargin,
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              border: Border.all(width: 0.5, color: Colors.black12)),
          child: Column(
            children: [
              Padding(
                padding: OutlinedContainer.defaultPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recent Transactions",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14.0)),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => TransactionDetailPage(
                                      account: account, isInputting: true))));
                        },
                        child: Icon(Icons.search, color: Colors.red[900]))
                  ],
                ),
              ),
              _getTransactions(account, snapshot),
              const SizedBox(height: 20.0),
              Container(
                decoration: const BoxDecoration(
                    border: Border(top: outlinedBorderSide)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) =>
                                TransactionDetailPage(account: account))));
                  },
                  child: const Padding(
                      padding: OutlinedContainer.defaultPadding,
                      child: Center(
                          child: Text(
                        "More transactions",
                        style: TextStyle(color: Colors.red),
                      ))),
                ),
              )
            ],
          )),
    );
  }

  Widget _getTransactions(Account account,
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    if (snapshot.hasError) {
      return const Text("Error while retrieving transactions");
    }

    if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
      QuerySnapshot<Map<String, dynamic>> readTransactions =
          snapshot.data as QuerySnapshot<Map<String, dynamic>>;
      List<AccountTransaction> transactions = readTransactions.docs
          .map((e) => AccountTransaction.fromMap(e.data(), e.id))
          .toList();
      Decimal balance = account.getBalance;
      DateTime dateTime = Vars.invalidDateTime;
      print("${DateTime.now()} Recreating details page");
      return Column(
        children: transactions.map(((transaction) {
          Widget retWidget;
          Decimal actualAmount =
              transaction.getAmountPerspReceiver(account.getNumber);

          if (Vars.isSameDay(dateTime, transaction.getDateTime)) {
            retWidget = _getTransactionButton(
                transaction,
                balance,
                actualAmount,
                transaction.description[widget.account.accountID.getNumber]);
          } else {
            dateTime = transaction.dateTime;
            retWidget = Column(
              children: [
                _getTransactionLineBr(dateTime),
                _getTransactionButton(transaction, balance, actualAmount,
                    transaction.description[widget.account.accountID.getNumber])
              ],
            );
          }

          balance = balance - actualAmount;

          return retWidget;
        })).toList(),
      );
    }
    return const LoadingText(repeats: 1);
  }

  Widget _getBottomContent(Account account) {
    return Column(
      children: [
        CustButton(
            onTap: () {},
            leftWidget: const Icon(Icons.monetization_on_outlined),
            heading: "Upcoming payments",
            margin: buttonMargin),
        account.hasCard()
            ? CustButton(
                onTap: () {},
                leftWidget: const Icon(CupertinoIcons.gift_fill),
                heading: "Rewards and offers",
                margin: buttonMargin)
            : const SizedBox(),
        account.hasCard()
            ? CustButton(
                onTap: () {},
                leftWidget: const Icon(Icons.settings),
                heading: "Card settings",
                paragraph: "Lock card, autopay, digital card",
                margin: buttonMargin)
            : const SizedBox(),
        CustButton(
            onTap: () {},
            leftWidget: const Icon(Icons.book),
            heading: "Documents",
            paragraph: "Statements, interest, tax, proof of balance",
            margin: buttonMargin)
      ],
    );
  }
}
