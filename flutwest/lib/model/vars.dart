import 'package:flutter/material.dart';
import 'package:flutwest/model/account_id.dart';

class Vars {
  Vars._();

  /// the padding size on most pages against the left and right side of screen
  static const double standardPaddingSize = 15.0;

  /// the space betwee nelements in height, used as padding for top, bot
  static const double topBotPaddingSize = 17.0;

  /// font size of paragraph inside button
  static const double buttonParagraphSize = 12.0;

  /// the gap between widgets of a page in height
  static const double heightGapBetweenWidgets = 17.0;

  static const double appbarTitleSize = 24.0;

  /// the font size of heading text for h1
  static const double headingTextSize1 = 20.0;

  /// the font size of heading text for h2
  static const double headingTextSize2 = 16.0;

  /// the font size of paragraph text
  static const double paragraphTextSize = 12.0;

  static const TextStyle headingStyle1 =
      TextStyle(fontSize: headingTextSize1, fontWeight: FontWeight.bold);

  static const TextStyle headingStyle2 =
      TextStyle(fontSize: headingTextSize2, fontWeight: FontWeight.bold);

  static const TextStyle buttonPragraphStyle =
      TextStyle(fontSize: buttonParagraphSize);

  static const TextStyle appbarTitleStyle = TextStyle(
      fontSize: appbarTitleSize,
      fontWeight: FontWeight.bold,
      color: Colors.black);

  static const String fakeMemberID = "22222222";

  static const List<String> days = [
    "",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun"
  ];

  static const List<String> months = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  static bool isSameDay(DateTime dateTime, DateTime otherDateTime) {
    return dateTime.year == otherDateTime.year &&
        dateTime.month == otherDateTime.month &&
        dateTime.day == otherDateTime.day;
  }

  static final invalidDateTime = DateTime(1000);
  static final invalidAccountID = AccountID(number: "", bsb: "");
}
