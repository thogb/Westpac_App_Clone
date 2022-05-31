import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/cust_floating_button.dart';
import 'package:flutwest/cust_widget/cust_heading.dart';
import 'package:flutwest/cust_widget/cust_paragraph.dart';
import 'package:flutwest/cust_widget/cust_radio.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/transaction_filter.dart';
import 'package:flutwest/model/utils.dart';
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

  late DateTime _startDate;
  late DateTime _endDate;

  double? _startAmount;
  double? _endAmount;

  @override
  void initState() {
    _amountFilters = TransactionFilter.amounts.keys.toList();
    _typeFilters = TransactionFilter.types;
    _dateFilters = widget.datesFilters != null
        ? widget.datesFilters!.keys.toList()
        : TransactionFilter.dates.keys.toList();

    resetFilter(widget.filter);

    super.initState();
  }

  void resetFilter(TransactionFilter filter) {
    _dateSelected = filter.date;
    _amountSelected = filter.amount;
    _typeSelected = filter.type;

    DateTime now = DateTime.now();
    _startDate = filter.startDate ?? DateTime(now.year, now.month - 2, now.day);
    _endDate = filter.endDate ?? now;
  }

  bool isEqualToFilter(TransactionFilter filter) {
    return _dateSelected == filter.date &&
        _amountSelected == filter.amount &&
        _typeSelected == filter.type &&
        (_amountSelected != TransactionFilter.otherAmount ||
            _startAmount == filter.startAmount &&
                _endAmount == filter.endAmount) &&
        (_dateSelected != TransactionFilter.otherDate ||
            _startDate == filter.startDate && _endDate == filter.endDate);
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
          !isEqualToFilter(widget.resetFilter)
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      resetFilter(widget.resetFilter);
                    });
                  },
                  child: const Text("Reset"))
              : TextButton(
                  onPressed: () {},
                  child: const Text("Reset",
                      style: TextStyle(color: Vars.disabledClickableColor)))
        ],
      ),
      body: StandardPadding(
        child: SingleChildScrollView(
          child: SafeArea(
            top: false,
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
                              borderOn: false,
                              paragraph:
                                  "${widget.filter.selectedAccounts.length} accounts selected",
                              rightWidget: Text("Edit",
                                  style: Vars.headingStyle1
                                      .copyWith(color: Vars.clickAbleColor)),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                        pageBuilder: ((context, animation,
                                                secondaryAnimation) =>
                                            AccountFilteringPage(
                                                allAccounts:
                                                    widget.filter.allAccounts,
                                                selectedAccounts: widget.filter
                                                    .selectedAccounts))));
                              })
                        ],
                      ),
                // Date filtering
                !widget.filterDates
                    ? const SizedBox()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustHeading.big(
                              heading: "Date", textStyle: headingStyle),
                          Wrap(
                              children: List.generate(
                                  _dateFilters.length,
                                  (index) => CustRadio.typeOne(
                                      padding: CustRadio.paddingRightBot,
                                      value: _dateFilters[index],
                                      groupValue: _dateSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          _dateSelected = value;
                                        });
                                      },
                                      name: _dateFilters[index]))),
                          _dateSelected != TransactionFilter.otherDate
                              ? const SizedBox()
                              : GestureDetector(
                                  child: CustParagraph.normal(
                                      reversed: true,
                                      heading: "Start date - End date",
                                      paragraph:
                                          "${Utils.getDateTimeDMY(_startDate)} - ${Utils.getDateTimeDMY(_endDate)}"),
                                  onTap: () async {
                                    DateTime now = DateTime.now();
                                    DateTimeRange? result =
                                        await showDateRangePicker(
                                      context: context,
                                      initialDateRange: DateTimeRange(
                                          start: _startDate, end: _endDate),
                                      firstDate: _startDate = DateTime(
                                          now.year - 1, now.month, now.day),
                                      lastDate: now,
                                    );

                                    if (result != null) {
                                      setState(() {
                                        _startDate = result.start;
                                        _endDate = result.end;
                                      });
                                    }
                                  },
                                )
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
                                    padding: CustRadio.paddingRightBot,
                                    value: _amountFilters[index],
                                    groupValue: _amountSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        _amountSelected = value;
                                      });
                                    },
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
                          CustHeading.big(
                              heading: "Type", textStyle: headingStyle),
                          Wrap(
                              children: List.generate(
                                  _typeFilters.length,
                                  (index) => CustRadio.typeOne(
                                      padding: CustRadio.paddingRightBot,
                                      value: _typeFilters[index],
                                      groupValue: _typeSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          _typeSelected = value;
                                        });
                                      },
                                      name: _typeFilters[index])))
                        ],
                      ),
                const SizedBox(height: 100)
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustFloatingButton.enabled(
          title: "Done",
          onPressed: () {
            widget.filter.type = _typeSelected;
            widget.filter.date = _dateSelected;
            if (widget.filter.date == TransactionFilter.otherDate) {
              widget.filter.startDate = _startDate;
              widget.filter.endDate = _endDate;
            }
            widget.filter.amount = _amountSelected;
            if (widget.filter.amount == TransactionFilter.otherAmount) {
              widget.filter.startAmount = _startAmount;
              widget.filter.endAmount = _endAmount;
            }

            Navigator.pop(context, true);
          }),
    );
  }
}

class AccountFilteringPage extends StatefulWidget {
  final List<Account> allAccounts;
  final HashSet<Account> selectedAccounts;
  const AccountFilteringPage(
      {Key? key, required this.allAccounts, required this.selectedAccounts})
      : super(key: key);

  @override
  State<AccountFilteringPage> createState() => _AccountFilteringPageState();
}

class _AccountFilteringPageState extends State<AccountFilteringPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accounts"),
      ),
      body: SingleChildScrollView(
        child: StandardPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  "Select up to 20 accounts to search. We'll keep this for future searches"),
              CustHeading.big(heading: "Cash"),
              Column(
                  children: List.generate(
                      widget.allAccounts.length,
                      (index) => CheckboxListTile(
                          title: Text(widget.allAccounts[index].getAccountName),
                          subtitle: Text(
                              "${widget.allAccounts[index].getBsb} ${widget.allAccounts[index].getNumber}\n\$${Utils.formatDecimalMoneyUS(widget.allAccounts[index].getBalance)}available"),
                          value: widget.selectedAccounts
                              .contains(widget.allAccounts[index]),
                          onChanged: (value) {
                            setState(() {
                              if (value != null && value) {
                                widget.selectedAccounts
                                    .add(widget.allAccounts[index]);
                              } else {
                                widget.selectedAccounts
                                    .remove(widget.allAccounts[index]);
                              }
                            });
                          })))
            ],
          ),
        ),
      ),
    );
  }
}
