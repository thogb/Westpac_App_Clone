import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class CustParagraph extends StatelessWidget {
  final List<Text> content;
  final EdgeInsetsGeometry padding;

  const CustParagraph._(
      {Key? key, required this.content, required this.padding})
      : super(key: key);

  factory CustParagraph.normal(
      {required String heading,
      required String paragraph,
      bool reversed = false,
      EdgeInsets padding = const EdgeInsets.symmetric(
          vertical: Vars.heightGapBetweenWidgets / 2)}) {
    return CustParagraph._(content: [
      Text(heading,
          style: !reversed ? Vars.headingStyle2 : Vars.paragraphStyleGrey),
      Text(paragraph,
          style: !reversed ? Vars.paragraphStyleGrey : Vars.headingStyle2)
    ], padding: padding);
  }

  factory CustParagraph.php(
      {required String paragraph1,
      required String heading,
      required String paragraph2,
      EdgeInsets padding = const EdgeInsets.symmetric(
          vertical: Vars.heightGapBetweenWidgets / 2)}) {
    return CustParagraph._(content: [
      Text(paragraph1, style: Vars.paragraphStyleGrey),
      Text(heading, style: Vars.headingStyle2),
      Text(paragraph2, style: Vars.paragraphStyleGrey)
    ], padding: padding);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      ),
    );
  }
}
