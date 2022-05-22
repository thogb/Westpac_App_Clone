import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/cust_widget/clickable_text.dart';
import 'package:flutwest/cust_widget/cust_text_field.dart';
import 'package:flutwest/cust_widget/in_text_button.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/loading_page.dart';
import 'package:flutwest/ui_page/schedule_pay_page.dart';
import 'package:flutwest/ui_page/transfer_from_page.dart';

class PaymentPage extends StatefulWidget {
  final List<Account> accounts;
  final Account currAccount;
  const PaymentPage(
      {Key? key, required this.accounts, required this.currAccount})
      : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _tecMoney = TextEditingController();
  final TextEditingController _tecDescReceiver = TextEditingController();
  final TextEditingController _tecDescSender = TextEditingController();
  final TextEditingController _tecReference = TextEditingController();

  late Account _currAccount;
  bool _enabledPayButton = false;
  DateTime _payDateTime = DateTime.now();
  String _appbarTitle = "";

  @override
  void initState() {
    _scrollController.addListener(_onScroll);

    _currAccount = widget.currAccount;

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(_appbarTitle),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.close, color: Vars.clickAbleColor),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Vars.standardPaddingSize * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Vars.heightGapBetweenWidgets),

              // The receiver
              InTextButton.standard(
                  leftLabel: "Pay ", label: "Test", rightLabel: ""),
              const SizedBox(height: Vars.gapBetweenTextVertical),
              Text("123123123123123123\n123123123123123123",
                  style: TextStyle(
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
                      leftLabel: "From ",
                      rightLabel: _currAccount.getAccountName),
              const SizedBox(height: Vars.gapBetweenTextVertical),
              Text("\$${Utils.formatDecimalMoneyUS(_currAccount.getBalance)}",
                  style: Vars.paragraphStyleGrey),
              const SizedBox(height: Vars.heightGapBetweenWidgets * 1.5),

              // Amount text field
              const Text("Amount", style: Vars.headingStyle2),
              CustTextField.moneyInput(
                controller: _tecMoney,
                onChanged: (String value) {
                  Decimal? amount =
                      Decimal.tryParse(value.replaceAll(r",", ""));

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
                          pageBuilder:
                              ((context, animation, secondaryAnimation) =>
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
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.all(Vars.standardPaddingSize),
        color: Colors.white,
        child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor:
                  _enabledPayButton ? Vars.clickAbleColor : Colors.grey,
              splashFactory: NoSplash.splashFactory),
          child: const Center(
            heightFactor: 2.0,
            child: Text(
              "Pay",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
            ),
          ),
          onPressed: !_enabledPayButton
              ? null
              : () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        Decimal? amount = Decimal.tryParse(_tecMoney.text);

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
                                  child: Text("Pay"),
                                  onPressed: () async {
                                    await Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                            pageBuilder: ((context, animation,
                                                    secondaryAnimation) =>
                                                LoadingPage(
                                                    futureObject: FirestoreController
                                                        .instance
                                                        .addPaymentTransaction(
                                                            sender: _currAccount
                                                                .accountID,
                                                            senderDocId:
                                                                _currAccount
                                                                    .docID!,
                                                            receiver: AccountID(
                                                                number:
                                                                    "number",
                                                                bsb: "bsb"),
                                                            receiverName:
                                                                "test",
                                                            senderDescription:
                                                                _tecDescSender
                                                                    .text,
                                                            receiverDescription:
                                                                _tecDescReceiver
                                                                    .text,
                                                            amount: amount)))));

                                    Navigator.of(context)..pop();
                                  })
                            ],
                          );
                        }
                      });
                },
        ),
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.offset > 10) {
      if (_appbarTitle.isEmpty) {
        setState(() {
          _appbarTitle = "Pay";
        });
      }
    } else {
      if (_appbarTitle.isNotEmpty) {
        setState(() {
          _appbarTitle = "";
        });
      }
    }
  }
}
