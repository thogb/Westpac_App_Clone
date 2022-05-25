import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/controller/sqlite_controller.dart';
import 'package:flutwest/cust_widget/cust_floating_button.dart';
import 'package:flutwest/cust_widget/cust_text_field.dart';
import 'package:flutwest/cust_widget/editing_page_scaffold.dart';
import 'package:flutwest/cust_widget/in_text_button.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/payee.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/loading_page.dart';
import 'package:flutwest/ui_page/payment_page.dart';

class AddPayeePage extends StatefulWidget {
  final List<Account> accounts;
  final Account currAccount;
  final String memberId;
  const AddPayeePage(
      {Key? key,
      required this.memberId,
      required this.accounts,
      required this.currAccount})
      : super(key: key);

  @override
  _AddPayeePageState createState() => _AddPayeePageState();
}

class _AddPayeePageState extends State<AddPayeePage> {
  final TextEditingController _tecAccountName = TextEditingController();
  final TextEditingController _tecBSB = TextEditingController();
  final TextEditingController _tecAccountNumber = TextEditingController();
  final TextEditingController _tecNickName = TextEditingController();

  bool _enableFloatingButton = false;

  @override
  Widget build(BuildContext context) {
    return EditingPageScaffold(
        title: "New BSB & Account",
        content: [
          // Change payee type
          const SizedBox(height: Vars.heightGapBetweenWidgets),
          InTextButton.standard(
              leftLabel: "New ", label: "BSB & Account", rightLabel: ""),
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // Input Account Name
          CustTextField.standardSmall(
            label: "Account name",
            controller: _tecAccountName,
            onChanged: _onTextFieldChanged,
            onFocusChange: (bool isFocus) {
              if (!isFocus &&
                  _tecAccountName.text.trim().isNotEmpty &&
                  _tecNickName.text.trim().isEmpty) {
                _tecNickName.text = _tecAccountName.text.trim();
              }
            },
          ),
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // Input BSB
          CustTextField.standardSmall(
              maxLength: 6,
              label: "BSB",
              controller: _tecBSB,
              keyboardType: TextInputType.number,
              onChanged: _onTextFieldChanged),
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // Input Account Number
          CustTextField.standardSmall(
              maxLength: 9,
              label: "Account number",
              controller: _tecAccountNumber,
              keyboardType: TextInputType.number,
              onChanged: _onTextFieldChanged),
          const SizedBox(
            height: Vars.heightGapBetweenWidgets,
          ),

          // Input Nickname
          CustTextField.standardSmall(
              label: "Nickname",
              controller: _tecNickName,
              onChanged: _onTextFieldChanged),
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // To not get blocked by floating text button
          const SizedBox(height: 80)
        ],
        floatingActionButton: !_enableFloatingButton
            ? CustFloatingButton.disabled(title: "Next")
            : CustFloatingButton.enabled(
                title: "Next",
                onPressed: () async {
                  if (_tecAccountName.text.trim().length < 2) {
                    _showAlertDialog("Invalid Input",
                        "Account name must consist of at least 2 character");
                    return;
                  }

                  if (_tecNickName.text.trim().length < 2) {
                    _showAlertDialog("Invalid Input",
                        "Nick name must conssit of at least 2 character");
                    return;
                  }

                  if (_tecBSB.text.length != 6) {
                    _showAlertDialog(
                        "Invalid Input", "BSB must consist of 6 digits");
                    return;
                  }

                  if (_tecAccountNumber.text.length < 6 ||
                      _tecAccountName.text.length > 9) {
                    _showAlertDialog("Invalid Input",
                        "Account number must consist of 6 to 9 digits");
                    return;
                  }

                  Payee payee = Payee.noId(
                      accountNumber: _tecAccountNumber.text,
                      accountBSB:
                          "${_tecBSB.text.substring(0, 3)}-${_tecBSB.text.substring(3, 6)}",
                      accountName:
                          Utils.getCapitalizedString(_tecAccountName.text),
                      nickName: Utils.getCapitalizedString(_tecNickName.text));

                  Object? result = await Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder: ((context, animation,
                                  secondaryAnimation) =>
                              LoadingPage(
                                  futureObject: SQLiteController.instance
                                      .doesPayeeExist(widget.memberId, payee))),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero));

                  bool doesPayeeExist = result as bool;

                  if (doesPayeeExist) {
                    _showAlertDialog("Payee already exist",
                        "Payee with the inputted information already exist in the payee list");
                    return;
                  }

                  DateTime addTime = DateTime.now();

                  Object? result2 = await Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder: ((context, animation,
                                  secondaryAnimation) =>
                              LoadingPage(
                                  futureObject: FirestoreController.instance
                                      .addPayee(
                                          widget.memberId, payee, addTime))),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero));

                  String docId = result2 as String;

                  payee = Payee(
                      docId: docId,
                      accountNumber: _tecAccountNumber.text,
                      accountBSB:
                          "${_tecBSB.text.substring(0, 3)}-${_tecBSB.text.substring(3, 6)}",
                      accountName:
                          Utils.getCapitalizedString(_tecAccountName.text),
                      nickName: Utils.getCapitalizedString(_tecNickName.text));

                  await Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder: ((context, animation,
                                  secondaryAnimation) =>
                              LoadingPage(
                                  futureObject: SQLiteController.instance
                                      .addPayee(
                                          widget.memberId, payee, addTime))),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero));
                  Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                          pageBuilder:
                              ((context, animation, secondaryAnimation) =>
                                  PaymentPage(
                                      memberId: widget.memberId,
                                      payee: payee,
                                      accounts: widget.accounts,
                                      currAccount: widget.currAccount)),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero),
                      result: payee);

                  /*
                  await FirestoreController.instance
                      .addPayee(widget.memberId, payee, addTime);
                  await SQLiteController.instance
                      .addPayee(widget.memberId, payee, addTime);*/
                }));
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Ok"))
              ],
            ));
  }

  void _onTextFieldChanged(String value) {
    if (_tecBSB.text.isNotEmpty &&
        _tecAccountName.text.isNotEmpty &&
        _tecAccountNumber.text.isNotEmpty &&
        _tecNickName.text.isNotEmpty) {
      if (!_enableFloatingButton) {
        setState(() {
          _enableFloatingButton = true;
        });
      }
    } else {
      if (_enableFloatingButton) {
        setState(() {
          _enableFloatingButton = false;
        });
      }
    }
  }
}
