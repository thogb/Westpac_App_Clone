import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class CustButton extends StatelessWidget {
  /// font size of heading inside button
  static const double buttonHeadingSize = 16.0;
  static const double buttonParaSize = 12.0;

  static const TextStyle buttonHeadingStyle =
      TextStyle(fontSize: buttonHeadingSize, fontWeight: FontWeight.bold);

  static const TextStyle buttonParaStyle =
      TextStyle(fontSize: buttonParaSize, fontWeight: FontWeight.w300);

  final double topBotPadding = Vars.topBotPaddingSize;
  final double leftRightPadding = Vars.standardPaddingSize;

  final String? heading;
  final String? paragraph;
  final Widget? leftWidget;
  final Widget? rightWidget;
  final VoidCallback? onTap;

  const CustButton(
      {Key? key,
      this.heading,
      this.paragraph,
      this.leftWidget,
      this.rightWidget,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: topBotPadding, horizontal: leftRightPadding),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.0),
            border: Border.all(width: 0.5, color: Colors.black12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leftWidget ?? const SizedBox(),
            SizedBox(
              width: leftRightPadding,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heading != null
                      ? Text(
                          heading!,
                          style: buttonHeadingStyle,
                        )
                      : const SizedBox(),
                  const SizedBox(height: 4.0),
                  paragraph != null
                      ? Text(paragraph!, style: buttonParaStyle)
                      : const SizedBox()
                ],
              ),
            ),
            SizedBox(
              width: leftRightPadding,
            ),
            rightWidget != null ? rightWidget! : const SizedBox()
          ],
        ),
      ),
    );
  }
}
