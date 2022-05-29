import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/cust_floating_button.dart';
import 'package:flutwest/cust_widget/cust_heading.dart';
import 'package:flutwest/cust_widget/cust_radio.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/transaction_filter.dart';
import 'package:flutwest/model/vars.dart';

class FilteringPage extends StatefulWidget {
  final bool filterDates;
  final bool filterAmount;
  final bool filterType;
  final Map<String, List<DateTime?>>? datesFilters;
  final TransactionFilter filter;
  final TransactionFilter resetFilter;
  const FilteringPage(
      {Key? key,
      required this.filter,
      required this.resetFilter,
      this.filterDates = true,
      this.filterAmount = true,
      this.filterType = true,
      this.datesFilters})
      : super(key: key);

  @override
  _FilteringPageState createState() => _FilteringPageState();
}

class _FilteringPageState extends State<FilteringPage> {
  static final TextStyle headingStyle =
      CustHeading.bigHeadingStyle.copyWith(color: Vars.radioFilterColor);

  late final List<String> _amountFilters;
  late final List<String> _typeFilters;
  late final List<String> _dateFilters;

  late String _dateSelected;
  late String _amountSelected;
  late String _typeSelected;

  @override
  void initState() {
    _amountFilters = TransactionFilter.amounts.keys.toList();
    _typeFilters = TransactionFilter.types;
    _dateFilters = widget.datesFilters != null
        ? widget.datesFilters!.keys.toList()
        : TransactionFilter.dates.keys.toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          child: const Icon(Icons.close),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Filter"),
        actions: [
          widget.filter.isFilterEqual(widget.resetFilter)
              ? TextButton(onPressed: () {}, child: const Text("Reset"))
              : TextButton(
                  onPressed: () {},
                  child: const Text("Rest",
                      style: TextStyle(color: Vars.disabledClickableColor)))
        ],
      ),
      body: StandardPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account filtering
            widget.filter.allAccounts.isEmpty
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustHeading.big(
                          heading: "Accounts", textStyle: headingStyle),
                      CustButton(
                          paragraph:
                              "${widget.filter.selectedAccount.length} accounts selected",
                          rightWidget: GestureDetector(
                              child: Text("Edit",
                                  style: Vars.headingStyle1
                                      .copyWith(color: Vars.clickAbleColor)),
                              onTap: () {}))
                    ],
                  ),
            // Date filtering
            !widget.filterDates
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustHeading.big(heading: "Date", textStyle: headingStyle),
                      Wrap(
                          children: List.generate(
                              _dateFilters.length,
                              (index) => CustRadio.typeOne(
                                  value: _dateFilters[index],
                                  groupValue: _dateSelected,
                                  onChanged: (value) {},
                                  name: _dateFilters[index]))),
                    ],
                  ),

            // Amount filtering
            !widget.filterAmount
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustHeading.big(
                          heading: "Amount", textStyle: headingStyle),
                      Wrap(
                        children: List.generate(
                            _amountFilters.length,
                            (index) => CustRadio.typeOne(
                                value: _amountFilters[index],
                                groupValue: _amountSelected,
                                onChanged: (value) {},
                                name: _amountFilters[index])),
                      )
                    ],
                  ),

            // Type filtering
            !widget.filterType
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustHeading.big(heading: "Type", textStyle: headingStyle),
                      Wrap(
                          children: List.generate(
                              _typeFilters.length,
                              (index) => CustRadio.typeOne(
                                  value: _typeFilters[index],
                                  groupValue: _typeSelected,
                                  onChanged: (value) {},
                                  name: _typeFilters[index])))
                    ],
                  )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          CustFloatingButton.enabled(title: "Done", onPressed: () {}),
    );
  }
}
