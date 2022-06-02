import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/cust_widget/clickable_text.dart';
import 'package:flutwest/cust_widget/cust_floating_button.dart';
import 'package:flutwest/cust_widget/cust_text_field.dart';
import 'package:flutwest/cust_widget/editing_page_scaffold.dart';
import 'package:flutwest/cust_widget/in_text_button.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/loading_page.dart';
import 'package:flutwest/ui_page/schedule_pay_page.dart';
import 'package:flutwest/ui_page/transfer_from_page.dart';

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
  DateTime _dateTime = DateTime.now();

  late Account _currAccount;
  late Account _toAccount;

  final TextEditingController _tecMoney = TextEditingController();
  final TextEditingController _tecDescription = TextEditingController();

  bool _madeTransfer = false;

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

  void _onBackPress() {
    Navigator.pop(context, _madeTransfer);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onBackPress();
        return false;
      },
      child: EditingPageScaffold(
          content: [
            // From this account
            const SizedBox(height: Vars.heightGapBetweenWidgets * 0.5),
            InTextButton.standard(
              leftLabel: "From ",
              label: _currAccount.getAccountName,
              rightLabel: "",
              onTap: () async {
                List<Account> inAccounts = List.from(widget.accounts);

                inAccounts.remove(_currAccount);
                Object? result = await Navigator.push(
                    context,
                    PageRouteBuilder(
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                        pageBuilder: (_, __, ___) => TransferFromPage(
                            accounts: inAccounts, requestResult: true)));
                if (result != null) {
                  Account resultAccount = result as Account;

                  setState(() {
                    if (resultAccount.getNumber == _toAccount.getNumber) {
                      _toAccount = _currAccount;
                    }
                    _currAccount = resultAccount;
                  });
                }
              },
            ),
            const SizedBox(height: Vars.gapBetweenTextVertical),
            Text(_currAccount.getBalanceUSDToString),
            const SizedBox(height: Vars.heightGapBetweenWidgets),

            // To This account
            widget.accounts.length > 2
                ? InTextButton.standard(
                    leftLabel: "To ",
                    label: _toAccount.getAccountName,
                    rightLabel: "",
                    onTap: () async {
                      List<Account> inAccounts = List.from(widget.accounts);

                      inAccounts.remove(_toAccount);
                      Object? result = await Navigator.push(
                          context,
                          PageRouteBuilder(
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                              pageBuilder: (_, __, ___) => TransferFromPage(
                                  title: "To",
                                  accounts: inAccounts,
                                  requestResult: true)));
                      if (result != null) {
                        Account resultAccount = result as Account;

                        setState(() {
                          if (resultAccount.getNumber ==
                              _currAccount.getNumber) {
                            _currAccount = _toAccount;
                          }
                          _toAccount = resultAccount;
                        });
                      }
                    },
                  )
                : InTextButton.noButton(
                    leftLabel: "To ", rightLabel: _toAccount.getAccountName),
            const SizedBox(height: Vars.gapBetweenTextVertical),
            Text(_toAccount.getBalanceUSDToString),
            const SizedBox(
                height:
                    Vars.heightGapBetweenWidgets + Vars.gapBetweenTextVertical),

            // Input amount text field
            const Text("Amount", style: Vars.headingStyle3),
            CustTextField.moneyInput(
              controller: _tecMoney,
              onChanged: (String value) {
                Decimal? amount = Decimal.tryParse(value.replaceAll(r",", ""));

                if (amount == null) {
                  if (_enableTransferButton) {
                    setState(() {
                      _enableTransferButton = false;
                    });
                  }
                } else {
                  if (!_enableTransferButton) {
                    setState(() {
                      _enableTransferButton = true;
                    });
                  }
                }
              },
              getErrorMsg: (String value) {
                Decimal? inputAmount =
                    Decimal.tryParse(value.replaceAll(r",", ""));

                if (inputAmount != null) {
                  if (inputAmount > _currAccount.balance) {
                    return "Insufficient funds in your ${_currAccount.getAccountName} account.";
                  }
                }

                return null;
              },
            ),
            const SizedBox(height: Vars.heightGapBetweenWidgets * 2),

            // Schedule Date
            InTextButton.standard(
                leftLabel: "Schedule for ",
                label: Utils.getDateTimeWDDMYToday(_dateTime),
                rightLabel: "",
                onTap: () async {
                  Object? result = await Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder:
                              ((context, animation, secondaryAnimation) =>
                                  SchedulePayPage(dateTime: _dateTime)),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero));
                  if (result != null) {
                    DateTime newDateTime = result as DateTime;

                    if (!Vars.isSameDay(newDateTime, _dateTime)) {
                      setState(() {
                        _dateTime = newDateTime;
                      });
                    }
                  }
                }),
            const SizedBox(height: Vars.heightGapBetweenWidgets * 1.5),

            // Desription
            CustTextField.standardSmall(
              controller: _tecDescription,
              label: "Description (optional)",
              maxLength: 18,
            ),
            const SizedBox(height: Vars.heightGapBetweenWidgets * 2),

            // Extra info
            ClickableText.standard(text: "Things you should know"),

            const SizedBox(height: 100.0)
          ],

          // floating action button
          floatingActionButton: !_enableTransferButton
              ? CustFloatingButton.disabled(title: "Transfer")
              : CustFloatingButton.enabled(
                  title: "Transfer",
                  onPressed: () async {
                    Decimal? amount =
                        Decimal.tryParse(_tecMoney.text.replaceAll(r",", ""));
                    await showDialog(
                        context: context,
                        builder: (contex) {
                          if (amount == null) {
                            return AlertDialog(
                                title: const Text("Error"),
                                content: const Text(
                                    "Failed to read input please try again."),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Ok"))
                                ]);
                          } else if (amount > _currAccount.balance) {
                            return AlertDialog(
                                title: const Text("Error"),
                                content: Text(
                                    "Insufficient funds in your ${_currAccount.getAccountName} account."),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Ok"))
                                ]);
                          } else {
                            return AlertDialog(
                              title: const Text("Check details"),
                              content: Text(
                                  "\$${Utils.formatDecimalMoneyUS(amount)}\n${Utils.getDateTimeWDDMYToday(_dateTime)} (Perth Time)"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () async {
                                      _madeTransfer = true;
                                      /*_currAccount.balance =
                                          _currAccount.balance - amount;
                                      _toAccount.balance =
                                          _toAccount.balance + amount;*/
                                      /*for (Account account in widget.accounts) {
                                        if (account.getNumber ==
                                            _toAccount.getNumber) {
                                          print(
                                              "changed bal to ${_toAccount.balance}");
                                          account.balance = _toAccount.balance;
                                        }
                                      }*/
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Transfer"))
                              ],
                            );
                          }
                        });
                    if (amount != null && _madeTransfer) {
                      await Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder:
                                  ((context, animation, secondaryAnimation) =>
                                      LoadingPage(
                                          futureObject: FirestoreController
                                              .instance.colTransaction
                                              .addTransferTransaction(
                                                  senderAccount: _currAccount,
                                                  receiverAccount: _toAccount,
                                                  transferDescription:
                                                      _tecDescription.text,
                                                  amount: amount,
                                                  dateTime: _dateTime))),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero));
                      _onBackPress();
                    }
                  })),
    );
  }
}
