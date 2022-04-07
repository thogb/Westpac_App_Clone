import 'package:flutter/material.dart';

class Vars {
  /// the padding size on most pages against the left and right side of screen
  static const double standardPaddingSize = 15.0;

  /// the space betwee nelements in height, used as padding for top, bot
  static const double topBotPaddingSize = 12.0;

  /// font size of paragraph inside button
  static const double buttonParagraphSize = 12.0;

  /// the gap between widgets of a page in height
  static const double heightGapBetweenWidgets = 17.0;

  static const double appbarTitleSize = 24.0;

  static const TextStyle buttonPragraphStyle =
      TextStyle(fontSize: buttonParagraphSize);

  static const TextStyle appbarTitleStyle = TextStyle(
      fontSize: appbarTitleSize,
      fontWeight: FontWeight.bold,
      color: Colors.black);
}
