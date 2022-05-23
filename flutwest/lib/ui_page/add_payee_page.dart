import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_floating_button.dart';
import 'package:flutwest/cust_widget/cust_text_field.dart';
import 'package:flutwest/cust_widget/editing_page_scaffold.dart';
import 'package:flutwest/cust_widget/in_text_button.dart';
import 'package:flutwest/model/vars.dart';

class AddPayeePage extends StatefulWidget {
  const AddPayeePage({Key? key}) : super(key: key);

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
            onChanged: onTextFieldChanged,
          ),
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // Input BSB
          CustTextField.standardSmall(
              maxLength: 6,
              label: "BSB",
              controller: _tecBSB,
              keyboardType: TextInputType.number,
              onChanged: onTextFieldChanged),
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // Input Account Number
          CustTextField.standardSmall(
              maxLength: 9,
              label: "Account number",
              controller: _tecAccountNumber,
              keyboardType: TextInputType.number,
              onChanged: onTextFieldChanged),
          const SizedBox(
            height: Vars.heightGapBetweenWidgets,
          ),

          // Input Nickname
          CustTextField.standardSmall(
              label: "Nickname",
              controller: _tecNickName,
              onChanged: onTextFieldChanged),
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // To not get blocked by floating text button
          const SizedBox(height: 80)
        ],
        floatingActionButton: !_enableFloatingButton
            ? CustFloatingButton.disabled(title: "Next")
            : CustFloatingButton.enabled(title: "Next", onPressed: () {}));
  }

  void onTextFieldChanged(String value) {
    if (_tecBSB.text.isNotEmpty &&
        _tecAccountName.text.isNotEmpty &&
        _tecAccountNumber.text.isNotEmpty) {
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
