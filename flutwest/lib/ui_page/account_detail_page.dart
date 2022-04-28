import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/outlined_container.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/transaction.dart';
import 'package:flutwest/model/vars.dart';

import '../model/account.dart';

class AccountDetailPage extends StatefulWidget {
  final List<Account> accounts;
  final int currIndex;

  const AccountDetailPage(
      {Key? key, required this.accounts, required this.currIndex})
      : super(key: key);

  @override
  _AccountDetailPageState createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  late Account _currAccount;
  bool _showNavBarTitle = false;
  late AppbarTitleStatus appbarTitleStatus;

  @override
  void initState() {
    appbarTitleStatus = AppbarTitleStatus(show: _showTitle, hide: _hideTitle);
    _currAccount = widget.accounts[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.grey[50],
            elevation: _showNavBarTitle ? 2 : 0,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.red[900],
              ),
            ),
            title: _showNavBarTitle
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Westpac ${_currAccount.type}",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text("\$${_currAccount.balance}",
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12.0))
                    ],
                  )
                : const SizedBox(),
            actions: [
              GestureDetector(
                  onTap: () {},
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.red[900],
                  ))
            ]),
        body: PageView(
          onPageChanged: (int index) {
            setState(() {
              _currAccount = widget.accounts[index];
              _showNavBarTitle = false;
            });
          },
          children: widget.accounts
              .map((Account account) => AccountDetailSection(
                  account: account, appbarTitleStatus: appbarTitleStatus))
              .toList(),
        ));
  }

  void _showTitle() {
    if (_showNavBarTitle == false) {
      setState(() {
        _showNavBarTitle = true;
      });
    }
  }

  void _hideTitle() {
    if (_showNavBarTitle == true) {
      setState(() {
        _showNavBarTitle = false;
      });
    }
  }
}

class AppbarTitleStatus {
  late bool visible;
  final VoidCallback show;
  final VoidCallback hide;

  AppbarTitleStatus(
      {this.visible = false, required this.show, required this.hide});

  void showTitle() {
    visible = true;
    show();
  }

  void hideTitle() {
    visible = false;
    hide();
  }
}

class AccountDetailSection extends StatefulWidget {
  final Account account;
  final AppbarTitleStatus appbarTitleStatus;

  const AccountDetailSection(
      {Key? key, required this.account, required this.appbarTitleStatus})
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

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return _getAccountDetail(widget.account);
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
          Text(
              "${Vars.days[dateTime.weekday]} ${dateTime.day} ${Vars.months[dateTime.month]} ${dateTime.year}"),
          const SizedBox(height: 2.0),
          Container(
            height: 1,
            color: Colors.black12,
          )
        ],
      ),
    );
  }

  Widget _getTransactionButton(Transaction transaction, double balance) {
    return CustButton(
      onTap: () {},
      borderOn: false,
      paragraphStype: const TextStyle(fontSize: 16.0),
      leftWidget: const Icon(
        Icons.monetization_on_sharp,
        size: 30,
      ),
      paragraph: transaction.getDescription,
      rightWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "\$${transaction.getAmount}",
            style: TextStyle(
                color: transaction.getAmount > 0.0 ? Colors.green : null),
          ),
          Text("bal \$$balance")
        ],
      ),
    );
  }

  Widget _getAccountDetail(Account account) {
    return NotificationListener(
      onNotification: ((notification) {
        if (notification is ScrollUpdateNotification) {
          if (_scrollController.offset > 60) {
            widget.appbarTitleStatus.showTitle();
          } else {
            widget.appbarTitleStatus.hideTitle();
          }
        }
        return false;
      }),
      child: SingleChildScrollView(
        controller: _scrollController,
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
                  _getSimpleButton(
                      Icons.transfer_within_a_station, "Pay", () {}),
                  const SizedBox(width: 10.0),
                  _getSimpleButton(
                      Icons.transfer_within_a_station, "Transfer", () {}),
                  const SizedBox(width: 10.0),
                  _getSimpleButton(
                      Icons.transfer_within_a_station, "BPay", () {})
                ],
              ),
              const SizedBox(height: Vars.heightGapBetweenWidgets),
              _getTransactionSummary(account),
              _getBottomContent(account),
              const SizedBox(height: 40)
            ],
          ),
        ),
      ),
    );
  }

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
              child: Text("\$${account.balance}", style: headingStyle)),
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

  Widget _getTransactionSummary(Account account) {
    List<Transaction> trans = [
      Transaction(
          sender: AccountID(number: "23232323", bsb: "123-123"),
          receiver: AccountID(number: "23232328", bsb: "423-123"),
          dateTime: DateTime.now(),
          id: "asdasd",
          description: "test trasnastion teasdnasd asdasdasdasdasdasdasd",
          amount: 23.0),
      Transaction(
          sender: AccountID(number: "23232323", bsb: "123-123"),
          receiver: AccountID(number: "23232328", bsb: "423-123"),
          dateTime: DateTime(2022, 4, 10),
          id: "asdasd",
          description: "test trasnastion teasdnasd asdasdasdasdasdasdasd",
          amount: -23.0),
      Transaction(
          sender: AccountID(number: "23232323", bsb: "123-123"),
          receiver: AccountID(number: "23232328", bsb: "423-123"),
          dateTime: DateTime(2022, 3, 2),
          id: "asdasd",
          description: "test trasnastion teasdnasd asdasdasdasdasdasdasd",
          amount: 23.0),
      Transaction(
          sender: AccountID(number: "23232323", bsb: "123-123"),
          receiver: AccountID(number: "23232328", bsb: "423-123"),
          dateTime: DateTime(2022, 3, 2),
          id: "asdasd",
          description: "test trasnastion teasdnasd asdasdasdasdasdasdasd",
          amount: 23.0),
      Transaction(
          sender: AccountID(number: "23232323", bsb: "123-123"),
          receiver: AccountID(number: "23232328", bsb: "423-123"),
          dateTime: DateTime(2022, 3, 2),
          id: "asdasd",
          description: "test trasnastion teasdnasd asdasdasdasdasdasdasd",
          amount: 23.0)
    ];

    double balance = account.getBalance;
    DateTime dateTime = DateTime(1000);

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
                    Icon(Icons.search, color: Colors.red[900])
                  ],
                ),
              ),
              Column(
                children: trans.map(((transaction) {
                  Widget widget;

                  if (Vars.isSameDay(dateTime, transaction.getDateTime)) {
                    widget = _getTransactionButton(transaction, balance);
                  } else {
                    dateTime = transaction.dateTime;
                    widget = Column(
                      children: [
                        _getTransactionLineBr(dateTime),
                        _getTransactionButton(transaction, balance)
                      ],
                    );
                  }

                  balance = balance - transaction.getAmount;

                  return widget;
                })).toList(),
              ),
              const SizedBox(height: 20.0),
              Container(
                  padding: OutlinedContainer.defaultPadding,
                  decoration: const BoxDecoration(
                      border: Border(top: outlinedBorderSide)),
                  child: Center(
                      child: GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "More transactions",
                            style: TextStyle(color: Colors.red),
                          ))))
            ],
          )),
    );
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
