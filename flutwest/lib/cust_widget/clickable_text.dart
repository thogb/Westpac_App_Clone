import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class ClickableText extends StatelessWidget {
  static const defaultTextStyle =
      TextStyle(fontSize: Vars.paragraphTextSize, color: Vars.clickAbleColor);

  final String text;
  final TextStyle textStyle;
  final VoidCallback? onTap;

  const ClickableText(
      {Key? key,
      required this.text,
      this.textStyle = defaultTextStyle,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }

  factory ClickableText.standard({required String text, VoidCallback? onTap}) {
    return ClickableText(onTap: onTap, text: text);
  }

  factory ClickableText.heading3({required String text, VoidCallback? onTap}) {
    return ClickableText(
        onTap: onTap,
        text: text,
        textStyle: const TextStyle(
            fontSize: Vars.headingTextSize3,
            fontWeight: Vars.medBold,
            color: Vars.clickAbleColor));
  }
}
