import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/cust_widget/clickable_text.dart';
import 'package:flutwest/cust_widget/cust_floating_button.dart';
import 'package:flutwest/cust_widget/cust_text_field.dart';
import 'package:flutwest/cust_widget/editing_page_scaffold.dart';
import 'package:flutwest/cust_widget/in_text_button.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/payee.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/loading_page.dart';
import 'package:flutwest/ui_page/payment_finish_page.dart';
import 'package:flutwest/ui_page/schedule_pay_page.dart';
import 'package:flutwest/ui_page/transfer_from_page.dart';

class PaymentPage extends StatefulWidget {
  final List<Account> accounts;
  final Account currAccount;
  final Payee payee;
  final String memberId;
  const PaymentPage(
      {Key? key,
      required this.accounts,
      required this.currAccount,
      required this.payee,
      required this.memberId})
      : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _tecMoney = TextEditingController();
  final TextEditingController _tecDescReceiver = TextEditingController();
  final TextEditingController _tecDescSender = TextEditingController();
  final TextEditingController _tecReference = TextEditingController();

  late Account _currAccount;
  bool _enabledPayButton = false;
  DateTime _payDateTime = DateTime.now();

  @override
  void initState() {
    _currAccount = widget.currAccount;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditingPageScaffold(
        title: "Pay ${widget.payee.getNickName}",
        content: [
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // The receiver
          InTextButton.standard(
              leftLabel: "Pay ",
              label: widget.payee.getNickName,
              rightLabel: "",
              onTap: () {
                Navigator.pop(context);
              }),
          const SizedBox(height: Vars.gapBetweenTextVertical),
          Text(
              "${widget.payee.getAccountID.getBsb} ${widget.payee.accountID.getNumber}",
              style: const TextStyle(
                  fontSize: Vars.paragraphTextSize, color: Colors.black54)),
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // From which account
          widget.accounts.length > 1
              ? InTextButton.standard(
                  leftLabel: "From ",
                  label: _currAccount.getAccountName,
                  rightLabel: "",
                  onTap: () async {
                    Object? result = await Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                ((context, animation, secondaryAnimation) =>
                                    TransferFromPage(
                                        accounts: widget.accounts,
                                        requestResult: true)),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero));
                    if (result != null) {
                      setState(() {
                        _currAccount = result as Account;
                      });
                    }
                  },
                )
              : InTextButton.noButton(
                  leftLabel: "From ", rightLabel: _currAccount.getAccountName),
          const SizedBox(height: Vars.gapBetweenTextVertical),
          Text("\$${Utils.formatDecimalMoneyUS(_currAccount.getBalance)}",
              style: Vars.paragraphStyleGrey),
          const SizedBox(height: Vars.heightGapBetweenWidgets * 1.5),

          // Amount text field
          const Text("Amount", style: Vars.headingStyle2),
          CustTextField.moneyInput(
            controller: _tecMoney,
            onChanged: (String value) {
              Decimal? amount = Decimal.tryParse(value.replaceAll(r",", ""));

              if (amount == null) {
                if (_enabledPayButton) {
                  setState(() {
                    _enabledPayButton = false;
                  });
                }
              } else {
                if (!_enabledPayButton) {
                  setState(() {
                    _enabledPayButton = true;
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
          const SizedBox(height: Vars.heightGapBetweenWidgets * 2.5),

          // Schedule payment
          InTextButton.standard(
            leftLabel: "Schedule for ",
            label: Utils.getDateTimeWDDMYToday(_payDateTime),
            rightLabel: "",
            onTap: () async {
              Object? result = await Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: ((context, animation, secondaryAnimation) =>
                          SchedulePayPage(dateTime: _payDateTime)),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero));

              if (result != null) {
                DateTime newDateTime = result as DateTime;

                if (!Vars.isSameDay(newDateTime, _payDateTime)) {
                  setState(() {
                    _payDateTime = newDateTime;
                  });
                }
              }
            },
          ),
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // Input description for receiver
          CustTextField.standardSmall(
            controller: _tecDescReceiver,
            label: "Description for Test (optional)",
            maxLength: 280,
          ),
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // Input description for sender
          CustTextField.standardSmall(
            controller: _tecDescSender,
            label: "Description for you (optional)",
            maxLength: 35,
          ),
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // Input reference
          CustTextField.standardSmall(
            controller: _tecReference,
            label: "Description e.g. invoice number (optional)",
            maxLength: 35,
          ),
          const SizedBox(height: Vars.heightGapBetweenWidgets * 2),

          // Extra info
          ClickableText.standard(text: "Things you should know"),

          const SizedBox(height: 200)
        ],
        //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: !_enabledPayButton
            ? CustFloatingButton.disabled(title: "Pay")
            : CustFloatingButton.enabled(
                title: "Pay",
                onPressed: () async {
                  bool finishedPayment = false;

                  Decimal? amount =
                      Decimal.tryParse(_tecMoney.text.replaceAll(",", ""));

                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
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
                              title: const Text("Insufficent fund"),
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
                                "\$${Utils.formatDecimalMoneyUS(amount)}\n${Utils.getDateTimeWDDMYToday(_payDateTime)} (Perth Time)"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel")),
                              TextButton(
                                  child: const Text("Pay"),
                                  onPressed: () async {
                                    /*await Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                            pageBuilder: ((context, animation,
                                                    secondaryAnimation) =>
                                                LoadingPage(
                                                    futureObject: handlePayment(
                                                        amount,
                                                        widget.memberId,
                                                        widget.payee)))));*/
                                    finishedPayment = true;
                                    Navigator.pop(context);
                                  })
                            ],
                          );
                        }
                      });
                  if (amount != null && finishedPayment) {
                    Object? result = await Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                ((context, animation, secondaryAnimation) =>
                                    LoadingPage(
                                        futureObject: handlePayment(amount,
                                            widget.memberId, widget.payee)))));
                    if (result != null && result is Exception) {
                      setState(() {
                        _currAccount.balance;
                      });
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                title: const Text("Payment error"),
                                content: Text(result.toString()),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Ok"))
                                ]);
                          });
                    } else {
                      await Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: ((context, animation,
                                      secondaryAnimation) =>
                                  PaymentFinishPage(
                                      senderName: _currAccount.getAccountName,
                                      receiverName: widget.payee.getNickName,
                                      amount: _tecMoney.text))));
                      Navigator.pop(context, true);
                    }
                  }
                }));
  }

  Future<void> handlePayment(
      Decimal amount, String memberId, Payee payee) async {
    DateTime payDate = DateTime.now();
    await FirestoreController.instance.colTransaction.addPaymentTransaction(
        memberId: widget.memberId,
        payeeId: payee.docId,
        senderAccount: _currAccount,
        receiver: payee.accountID,
        receiverName: widget.payee.getNickName,
        senderDescription: _tecDescSender.text,
        receiverDescription: _tecDescReceiver.text,
        amount: amount,
        dateTime: payDate);
    /*await SQLiteController.instance.tablePayee
        .updatePayeeLastPayDate(memberId, payee.docId, payDate);*/
    payee.lastPayDate = payDate;
  }
}
