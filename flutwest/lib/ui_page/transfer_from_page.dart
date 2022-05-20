import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/transfer_page.dart';

class TransferFromPage extends StatelessWidget {
  final String title;
  final bool pushReplacement;
  final bool requestResult;
  final List<Account> accounts;

  const TransferFromPage(
      {Key? key,
      required this.accounts,
      this.requestResult = false,
      this.pushReplacement = false,
      this.title = "From"})
      : super(key: key);

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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: Vars.standardPaddingSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Vars.topBotPaddingSize),
              StandardPadding(
                child: Text(
                  title,
                  style: Vars.headingStyle1,
                ),
              ),
              const SizedBox(height: Vars.topBotPaddingSize * 2),
              const StandardPadding(child: Text("Cash")),
              Column(
                children: List.generate(accounts.length,
                    (index) => _getAccountButton(accounts[index], context)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getAccountButton(Account account, BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: Vars.standardPaddingSize / 4),
      child: CustButton(
        onTap: () {
          if (requestResult) {
            Navigator.pop(context, account);
          } else {
            PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
                pageBuilder: ((context, animation, secondaryAnimation) =>
                    TransferPage(accounts: accounts, currAccount: account)),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero);
            if (pushReplacement) {
              Navigator.pushReplacement(context, pageRouteBuilder);
            } else {
              Navigator.push(context, pageRouteBuilder);
            }
          }
        },
        headingStyle: const TextStyle(fontSize: Vars.headingTextSize3),
        heading: account.getAccountName,
        paragraph: "${account.getBsb} ${account.getNumber}",
        rightWidget: Column(
          children: [
            Text(
              account.getBalanceUSDToString,
              style: Vars.headingStyle3,
            ),
            const Text(
              "Available",
              style: TextStyle(fontSize: Vars.paragraphTextSizeSmall),
            )
          ],
        ),
      ),
    );
  }
}
