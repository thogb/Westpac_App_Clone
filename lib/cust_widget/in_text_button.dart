import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class InTextButton extends StatelessWidget {
  static const defaultLeftLabelStyle = Vars.headingStyle1;
  static const defaultLabelStyle = TextStyle(
      fontSize: Vars.headingTextSize1,
      color: Vars.clickAbleColor,
      fontWeight: FontWeight.bold);
  static const defaultRightLabelStyle = Vars.headingStyle1;

  final String leftLabel;
  final String label;
  final String rightLabel;
  final Widget icon;
  final TextStyle? leftLabelStyle;
  final TextStyle? labelStyle;
  final TextStyle? rightLabelStyle;
  final VoidCallback? ontap;

  const InTextButton(
      {Key? key,
      required this.leftLabel,
      required this.label,
      required this.rightLabel,
      required this.icon,
      this.leftLabelStyle = defaultLeftLabelStyle,
      this.labelStyle = defaultLabelStyle,
      this.rightLabelStyle = defaultRightLabelStyle,
      this.ontap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(leftLabel, style: leftLabelStyle),
        label.isNotEmpty
            ? GestureDetector(
                onTap: ontap,
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: label, style: labelStyle),
                  WidgetSpan(child: icon),
                ])),
              )
            : const SizedBox(),
        Text(rightLabel, style: rightLabelStyle)
      ],
    );
  }

  factory InTextButton.standard(
      {required String leftLabel,
      required String label,
      required String rightLabel,
      VoidCallback? onTap}) {
    return InTextButton(
        leftLabel: leftLabel,
        label: label,
        rightLabel: rightLabel,
        ontap: onTap,
        icon: Icon(Icons.expand_more,
            color: defaultLabelStyle.color, size: defaultLabelStyle.fontSize));
  }

  factory InTextButton.noButton(
      {required String leftLabel, required String rightLabel}) {
    return InTextButton(
        leftLabel: leftLabel,
        label: "",
        rightLabel: rightLabel,
        icon: Icon(Icons.expand_more,
            color: defaultLabelStyle.color, size: defaultLabelStyle.fontSize));
  }
}
