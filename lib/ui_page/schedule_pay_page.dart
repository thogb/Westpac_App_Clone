import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';

class SchedulePayPage extends StatefulWidget {
  static const String howOftenOnce = "Once";
  static const String repeatUntilFurtherNotice = "Until Further notice";
  static const String repeatNumberOfTimes = "Number of times";
  static const String repeatEndDate = "End date";
  static const String firstNumberOfTimes = "1";

  static const List<String> howOftens = [
    howOftenOnce,
    "Daily",
    "Weekly",
    "Every 2 weeks",
    "Every 3 weeks",
    "Every 4 weeks",
    "Monthly",
    "Every 2 months",
    "Quarterly",
    "Every 12 weeks",
    "Every 4 months",
    "Half yearly",
    "Yearly"
  ];

  static const List<String> repeats = [
    repeatUntilFurtherNotice,
    repeatNumberOfTimes,
    repeatEndDate
  ];

  static const int maxNOfRepeats = 99;

  final DateTime dateTime;

  const SchedulePayPage({Key? key, required this.dateTime}) : super(key: key);

  @override
  _SchedulePayPageState createState() => _SchedulePayPageState();
}

class _SchedulePayPageState extends State<SchedulePayPage> {
  late DateTime _dateTime;
  late String _howOften;
  late String _repeat;
  late String _numberOfTimes;
  late DateTime _endDateTime;

  @override
  void initState() {
    _dateTime = widget.dateTime;
    _howOften = SchedulePayPage.howOftenOnce;
    _repeat = SchedulePayPage.repeatUntilFurtherNotice;
    _numberOfTimes = SchedulePayPage.firstNumberOfTimes;
    _endDateTime = DateTime.now();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule"),
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.close, color: Vars.clickAbleColor),
        ),
      ),
      body: StandardPadding(
        child: Column(
          children: [
            CustTextButton.bigDescSmallHeading(
                heading: "Schedule for",
                paragraph: Utils.getDateTimeWDDMYToday(_dateTime),
                onTap: () async {
                  DateTime now = DateTime.now();
                  final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _dateTime,
                      firstDate: now,
                      lastDate: DateTime(now.year + 2, now.month, now.day));
                  if (picked != null && !Vars.isSameDay(picked, _dateTime)) {
                    setState(() {
                      _dateTime = picked;

                      if (_repeat == SchedulePayPage.repeatEndDate &&
                          _dateTime.compareTo(_endDateTime) > 0) {
                        _endDateTime = _dateTime;
                      }
                    });
                  }
                }),
            CustTextButton.bigDescSmallHeading(
              heading: "How often?",
              paragraph: _howOften.toString(),
              onTap: () {
                showDialogForInput(
                    context, SchedulePayPage.howOftens, "How often?", _howOften,
                    (String? value) {
                  if (value != null && value != _howOften) {
                    setState(() {
                      _howOften = value;
                      if (value == SchedulePayPage.howOftenOnce) {
                        _repeat = SchedulePayPage.repeatUntilFurtherNotice;
                        _numberOfTimes = SchedulePayPage.firstNumberOfTimes;
                        _endDateTime = DateTime.now();
                      }
                    });
                  }
                });
              },
            ),
            _howOften != SchedulePayPage.howOftenOnce
                ? CustTextButton.bigDescSmallHeading(
                    heading: "Repeat",
                    paragraph: _repeat,
                    onTap: () {
                      showDialogForInput(
                          context, SchedulePayPage.repeats, "Repeat", _repeat,
                          (String? value) {
                        if (value != null && value != _repeat) {
                          _numberOfTimes = SchedulePayPage.firstNumberOfTimes;
                          _endDateTime = _dateTime;
                          setState(() {
                            _repeat = value;
                          });
                        }
                      });
                    })
                : const SizedBox(),
            _repeat == SchedulePayPage.repeatNumberOfTimes
                ? CustTextButton.bigDescSmallHeading(
                    heading: "Number of times",
                    paragraph: _numberOfTimes,
                    onTap: () {
                      showDialogForInput(
                          context,
                          List.generate(SchedulePayPage.maxNOfRepeats,
                              (index) => (index + 1).toString()),
                          "Repeat",
                          _numberOfTimes, (String? value) {
                        if (value != null && value != _numberOfTimes) {
                          setState(() {
                            _numberOfTimes = value;
                          });
                        }
                      });
                    })
                : const SizedBox(),
            _repeat == SchedulePayPage.repeatEndDate
                ? CustTextButton.bigDescSmallHeading(
                    heading: "Until",
                    paragraph: Utils.getDateTimeWDDMYToday(_endDateTime),
                    onTap: () async {
                      DateTime now = DateTime.now();
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _endDateTime,
                          firstDate: _dateTime,
                          lastDate: DateTime(now.year + 2, now.month, now.day));
                      if (picked != null &&
                          !Vars.isSameDay(picked, _endDateTime)) {
                        setState(() {
                          _endDateTime = picked;
                        });
                      }
                    })
                : const SizedBox()
          ],
        ),
      ),
      floatingActionButton: StandardPadding(
        child: TextButton(
          style: TextButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
              backgroundColor: Vars.clickAbleColor),
          onPressed: () {
            Navigator.pop(context, _dateTime);
          },
          child: const Center(
              heightFactor: 0,
              child: Text("Done", style: TextStyle(color: Colors.white))),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void showDialogForInput(BuildContext context, List<String> items,
      String title, String groupValue, void Function(String?) onChanged) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            contentPadding: EdgeInsets.zero,
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: items
                      .map((value) => RadioListTile(
                          activeColor: Colors.black,
                          title: Text(value),
                          value: value,
                          groupValue: groupValue,
                          onChanged: (String? value) {
                            /*setState(() {
                              if (value != null && value != _howOften) {
                                setState(() {
                                  _howOften = value;
                                });
                              }
                            });*/
                            onChanged(value);

                            Navigator.pop(context);
                          }))
                      .toList(),
                ),
              ),
            ),
          );
        });
  }
}
