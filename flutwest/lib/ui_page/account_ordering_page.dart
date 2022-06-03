import 'package:flutter/material.dart';
import 'package:flutwest/controller/sqlite_controller.dart';
import 'package:flutwest/cust_widget/cust_appbar.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/vars.dart';

class AccountOrderingPage extends StatefulWidget {
  final List<AccountOrderInfo> accountOrderInfos;

  const AccountOrderingPage({Key? key, required this.accountOrderInfos})
      : super(key: key);

  @override
  _AccountOrderingPageState createState() => _AccountOrderingPageState();
}

class _AccountOrderingPageState extends State<AccountOrderingPage> {
  bool _groupAccounts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: const Text("Edit"),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              for (int i = 0; i < widget.accountOrderInfos.length; i++) {
                widget.accountOrderInfos[i].setOrder = i;
              }
              SQLiteController.instance.tableAccountOrder.replaceAccountOrder(
                  widget
                      .accountOrderInfos
                      .map((e) => AccountIDOrder(
                          number: e.getAccount().getNumber,
                          bsb: e.getAccount().getBsb,
                          order: e.getOrder,
                          hidden: e.getHidden))
                      .toList());
              Navigator.pop(context);
            },
            child: const Text("Done",
                style: TextStyle(color: Vars.clickAbleColor)),
          )
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _getInstruction(),
          _getSwitchTileAndCash(),
          _getAccountsOrderList()
        ],
      ),
    );
  }

  Widget _getInstruction() {
    return const StandardPadding(
        showVerticalPadding: true,
        child: Text(
          "Group and select the accounts you'd like to see on your home dashboard",
          style: TextStyle(fontSize: 12.0),
        ));
  }

  Widget _getSwitchTile() {
    return SwitchListTile(
        title: const Text("Group accounts"),
        subtitle: const Text("By product type"),
        value: _groupAccounts,
        onChanged: (value) {
          setState(() {
            _groupAccounts = value;
          });
        });
  }

  Widget _getSwitchTileAndCash() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _getSwitchTile(),
        const StandardPadding(
            showVerticalPadding: true,
            child: Text("Cash", style: Vars.headingStyle1))
      ],
    );
  }

  Widget _getAccountsOrderList() {
    return ReorderableListView(
        buildDefaultDragHandles: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (int index = 0; index < widget.accountOrderInfos.length; index++)
            _getListItem(index, widget.accountOrderInfos[index])
        ],
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex--;
            }

            final AccountOrderInfo item =
                widget.accountOrderInfos.removeAt(oldIndex);
            widget.accountOrderInfos.insert(newIndex, item);
          });
        });
  }

  Widget _getListItem(int index, AccountOrderInfo accountOrderInfo) {
    return CheckboxListTile(
      activeColor: Vars.radioFilterColor,
      contentPadding: const EdgeInsets.fromLTRB(
          Vars.standardPaddingSize - 8,
          Vars.topBotPaddingSize - 8,
          Vars.standardPaddingSize,
          Vars.topBotPaddingSize),
      controlAffinity: ListTileControlAffinity.leading,
      value: accountOrderInfo.getHidden == 1 ? false : true,
      onChanged: (bool? value) {
        setState(() {
          accountOrderInfo.setHidden = value! ? 0 : 1;
        });
      },
      key: Key("$index"),
      title: Text("Westpac ${accountOrderInfo.getAccount().type}"),
      subtitle: Text(
          "${accountOrderInfo.getAccount().getBsb} ${accountOrderInfo.getAccount().getNumber}\n\$${accountOrderInfo.getAccount().getBalance} available"),
      secondary: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle),
      ),
    );
  }
}
