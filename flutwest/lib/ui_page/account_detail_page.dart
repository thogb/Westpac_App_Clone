import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_appbar.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/outlined_container.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
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
  static const TextStyle headingStyle =
      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);

  static const EdgeInsetsGeometry buttonMargin =
      EdgeInsets.symmetric(vertical: Vars.topBotPaddingSize / 2);

  static const BorderSide outlinedBorderSide =
      BorderSide(width: 0.5, color: Colors.black12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustAppbar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.red[900],
              ),
            ),
            title: const Text(""),
            trailing: [
              GestureDetector(
                  onTap: () {},
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.red[900],
                  ))
            ]),
        body: PageView(
          children: widget.accounts
              .map((Account account) => _getAccountDetail(account))
              .toList(),
        ));
  }

  Widget _getAccountDetail(Account account) {
    return SingleChildScrollView(
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
                _getSimpleButton(Icons.transfer_within_a_station, "Pay", () {}),
                const SizedBox(width: 10.0),
                _getSimpleButton(
                    Icons.transfer_within_a_station, "Transfer", () {}),
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
              Text("BSB ${account.bsb} Acct ${account.number}"),
              Icon(
                Icons.share,
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
      children: const [
        CustButton(
            leftWidget: Icon(Icons.money),
            heading: "Upcoming payments",
            margin: buttonMargin),
        CustButton(
            leftWidget: Icon(CupertinoIcons.gift_fill),
            heading: "Rewards and offers",
            margin: buttonMargin),
        CustButton(
            leftWidget: Icon(Icons.settings),
            heading: "Card settings",
            paragraph: "Lock card, autopay, digital card",
            margin: buttonMargin),
        CustButton(
            leftWidget: Icon(Icons.book),
            heading: "Documents",
            paragraph: "Statements, interest, tax, proof of balance",
            margin: buttonMargin)
      ],
    );
  }
}
