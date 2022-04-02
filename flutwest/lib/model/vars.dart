import 'package:flutter/material.dart';

class Vars {
  /// the padding size on most pages against the left and right side of screen
  static const double standardPaddingSize = 12.0;

  /// the space betwee nelements in height, used as padding for top, bot
  static const double topBotPaddingSize = 17.0;

  /// font size of paragraph inside button
  static const double buttonParagraphSize = 12.0;

  /// font size of heading inside button
  static const double buttonHeadingSize = 16.0;

  static const double appbarTitleSize = 24.0;

  static const TextStyle buttonPragraphStyle =
      TextStyle(fontSize: buttonParagraphSize);

  static const TextStyle buttonHeadingStyle =
      TextStyle(fontSize: buttonHeadingSize);

  static const TextStyle appbarTitleStyle = TextStyle(
      fontSize: appbarTitleSize,
      fontWeight: FontWeight.bold,
      color: Colors.black);
}
