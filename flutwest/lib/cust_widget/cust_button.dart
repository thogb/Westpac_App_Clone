import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class CustButton extends StatelessWidget {
  static const double buttonParaSize = Vars.paragraphTextSize;

  static const TextStyle buttonHeadingStyle = Vars.headingStyle2;

  static const TextStyle buttonParaStyle =
      TextStyle(fontSize: buttonParaSize, fontWeight: FontWeight.w300);

  static const double topBotPadding = Vars.topBotPaddingSize;
  static const double leftRightPadding = Vars.standardPaddingSize;

  static const EdgeInsets defaultPadding = EdgeInsets.symmetric(
      vertical: topBotPadding, horizontal: leftRightPadding);

  final String? heading;
  final String? paragraph;
  final Widget? leftWidget;
  final Widget? rightWidget;
  final TextStyle? headingStyle;
  final TextStyle? paragraphStyle;
  final VoidCallback? onTap;
  final bool? borderOn;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const CustButton(
      {Key? key,
      this.heading,
      this.paragraph,
      this.leftWidget,
      this.rightWidget,
      this.headingStyle,
      this.paragraphStyle,
      this.onTap,
      this.borderOn = true,
      this.padding,
      this.margin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
          border: borderOn == true
              ? Border.all(width: 0.5, color: Colors.black12)
              : null),
      child: Material(
        borderRadius: BorderRadius.circular(3.0),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? defaultPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftWidget ?? const SizedBox(),
                SizedBox(
                  width: leftWidget != null ? leftRightPadding : null,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading != null
                          ? Text(
                              heading!,
                              style: headingStyle ?? buttonHeadingStyle,
                            )
                          : const SizedBox(),
                      SizedBox(height: heading != null ? 4.0 : 0.0),
                      paragraph != null
                          ? Text(paragraph!,
                              style: paragraphStyle ?? buttonParaStyle)
                          : const SizedBox()
                    ],
                  ),
                ),
                const SizedBox(
                  width: leftRightPadding,
                ),
                rightWidget != null ? rightWidget! : const SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
