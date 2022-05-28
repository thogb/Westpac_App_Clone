import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/account_button.dart';
import 'package:flutwest/cust_widget/cust_heading.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/account_detail_page.dart';
import 'package:flutwest/ui_page/account_ordering_page.dart';

class HiddenAccountsPage extends StatefulWidget {
  final List<Account> accounts;
  final List<AccountOrderInfo> accountOrderInfos;
  final List<AccountOrderInfo> hiddenAccountOrderInfos;
  final String memberId;
  final DateTime? recentPayeeDate;
  const HiddenAccountsPage(
      {Key? key,
      required this.hiddenAccountOrderInfos,
      required this.accountOrderInfos,
      required this.accounts,
      required this.memberId,
      required this.recentPayeeDate})
      : super(key: key);

  @override
  _HiddenAccountsPageState createState() => _HiddenAccountsPageState();
}

class _HiddenAccountsPageState extends State<HiddenAccountsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.close, color: Vars.clickAbleColor),
          ),
          title: const Text(
            "Hidden accounts",
            style: Vars.headingStyle1,
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder:
                              ((context, animation, secondaryAnimation) =>
                                  AccountOrderingPage(
                                      accountOrderInfos:
                                          widget.hiddenAccountOrderInfos))));
                  Navigator.pop(context);
                },
                child: const Text("Edit",
                    style: TextStyle(
                        fontSize: Vars.headingTextSize2,
                        color: Vars.clickAbleColor)))
          ],
        ),
        body: ListView.builder(
            itemCount: widget.hiddenAccountOrderInfos.length + 1,
            itemBuilder: ((context, index) {
              int accountIndex = index - 1;
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Vars.heightGapBetweenWidgets),
                    CustHeading.big(heading: "Cash", showHorPadding: true),
                  ],
                );
              }
              return StandardPadding(
                child: AccountButton(
                    leftTitle:
                        "Westpac ${widget.hiddenAccountOrderInfos[accountIndex].account.type}",
                    rightTitle:
                        "\$${Utils.formatDecimalMoneyUS(widget.hiddenAccountOrderInfos[accountIndex].account.balance)}",
                    ontap: () async {
                      await Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: ((context, animation,
                                      secondaryAnimation) =>
                                  AccountDetailPage(
                                      accounts: widget.hiddenAccountOrderInfos,
                                      currIndex: accountIndex,
                                      rawAccounts: widget.accounts,
                                      memberId: widget.memberId,
                                      recentPayeeDate:
                                          widget.recentPayeeDate))));
                      setState(() {
                        widget.hiddenAccountOrderInfos;
                      });
                    }),
              );
            })));
  }
}
