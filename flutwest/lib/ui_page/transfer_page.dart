import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/clickable_text.dart';
import 'package:flutwest/cust_widget/cust_text_field.dart';
import 'package:flutwest/cust_widget/in_text_button.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/vars.dart';

class TransferPage extends StatefulWidget {
  final List<Account> accounts;
  final Account currAccount;
  const TransferPage(
      {Key? key, required this.accounts, required this.currAccount})
      : super(key: key);

  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  bool _enableTransferButton = false;
  late Account _currAccount;
  late Account _toAccount;

  @override
  void initState() {
    _currAccount = widget.currAccount;
    for (Account account in widget.accounts) {
      if (account.getNumber != _currAccount.getNumber) {
        _toAccount = account;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.close,
            color: Vars.clickAbleColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Vars.standardPaddingSize * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // From this account
                const SizedBox(height: Vars.heightGapBetweenWidgets * 0.5),
                InTextButton.standard(
                    leftLabel: "From ",
                    label: _currAccount.getAccountName,
                    rightLabel: ""),
                const SizedBox(height: Vars.gapBetweenTextVertical),
                Text(_currAccount.getBalanceUSDToString),
                const SizedBox(height: Vars.heightGapBetweenWidgets),

                // To This account
                widget.accounts.length > 2
                    ? InTextButton.standard(
                        leftLabel: "To ",
                        label: _toAccount.getAccountName,
                        rightLabel: "")
                    : InTextButton.noButton(
                        leftLabel: "To ",
                        rightLabel: _toAccount.getAccountName),
                const SizedBox(height: Vars.gapBetweenTextVertical),
                Text(_toAccount.getBalanceUSDToString),
                const SizedBox(
                    height: Vars.heightGapBetweenWidgets +
                        Vars.gapBetweenTextVertical),

                // Input amount text field
                const Text("Amount", style: Vars.headingStyle3),
                CustTextField.moneyInput(
                  getErrorMsg: (String value) {
                    if (Decimal.parse(value.replaceAll(r",", "")) >
                        _currAccount.balance) {
                      return "Insufficient funds in your ${_currAccount.getAccountName} account.";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: Vars.heightGapBetweenWidgets * 2),

                // Schedule Date
                InTextButton.standard(
                    leftLabel: "Schedule for ", label: "Today", rightLabel: ""),
                const SizedBox(height: Vars.heightGapBetweenWidgets * 1.5),

                // Desription
                CustTextField.standardSmall(
                  label: "Description (optional)",
                  maxLength: 18,
                ),
                const SizedBox(height: Vars.heightGapBetweenWidgets * 2),

                // Extra info
                ClickableText.standard(text: "Things you should know"),

                const SizedBox(height: 100.0)
              ],
            )),
      ),

      // floating action button
      floatingActionButton: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: Vars.standardPaddingSize),
        color: Colors.grey[50],
        child: TextButton(
          style: TextButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
              backgroundColor: _enableTransferButton
                  ? Vars.clickAbleColor
                  : Vars.disabledClickableColor),
          onPressed: () {},
          child: const Center(
              heightFactor: 0,
              child: Text(
                "Transfer",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.normal),
              )),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
