import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class CustHeading extends StatelessWidget {
  final String heading;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  static const TextStyle headingStyle = Vars.headingStyle1;

  const CustHeading(
      {Key? key,
      required this.heading,
      required this.textStyle,
      required this.padding})
      : super(key: key);

  factory CustHeading.big(
      {required String heading,
      TextStyle textStyle = const TextStyle(
          fontSize: Vars.headingTextSize1, fontWeight: FontWeight.w600),
      EdgeInsetsGeometry padding =
          const EdgeInsets.symmetric(vertical: Vars.topBotPaddingSize)}) {
    return CustHeading(
        heading: heading, textStyle: textStyle, padding: padding);
  }

  factory CustHeading.medium(
      {required String heading,
      TextStyle textStyle = const TextStyle(
          fontSize: Vars.headingTextSize2, fontWeight: FontWeight.w600),
      EdgeInsetsGeometry padding =
          const EdgeInsets.symmetric(vertical: Vars.topBotPaddingSize)}) {
    return CustHeading(
        heading: heading, textStyle: textStyle, padding: padding);
  }

  factory CustHeading.small(
      {required String heading,
      TextStyle textStyle = const TextStyle(
          fontSize: Vars.headingTextSize3, fontWeight: FontWeight.w600),
      EdgeInsetsGeometry padding =
          const EdgeInsets.symmetric(vertical: Vars.topBotPaddingSize)}) {
    return CustHeading(
        heading: heading, textStyle: textStyle, padding: padding);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        heading,
        style: textStyle,
      ),
    );
  }
}
