import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class CustTextButton extends StatelessWidget {
  /// font size of heading inside text button
  static const double buttonHeadingSize = 16.0;
  static const double buttonParaSize = 12.0;

  static const TextStyle textButtonHeadingStyle =
      TextStyle(fontSize: buttonHeadingSize, fontWeight: FontWeight.w400);

  static const TextStyle textButtonParaStyle =
      TextStyle(fontSize: buttonParaSize, fontWeight: FontWeight.w300);

  final double topBotPadding = Vars.topBotPaddingSize;
  final double rightLeftPadding = Vars.standardPaddingSize;
  final TextStyle headingTextStyle;
  final TextStyle paragraphTextStyle;
  final String? heading;
  final String? paragraph;
  final Color? highlightColor;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;
  final InteractiveInkFeatureFactory? splashFactory;

  const CustTextButton(
      {Key? key,
      this.heading,
      this.paragraph,
      this.highlightColor,
      this.onTap,
      this.contentPadding,
      this.headingTextStyle = textButtonHeadingStyle,
      this.paragraphTextStyle = textButtonParaStyle,
      this.splashFactory})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
          highlightColor: highlightColor,
          splashFactory: splashFactory,
          onTap: onTap,
          child: Container(
            padding: contentPadding ??
                EdgeInsets.fromLTRB(rightLeftPadding, topBotPadding,
                    rightLeftPadding, topBotPadding),
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading != null
                    ? Text(heading!, style: headingTextStyle)
                    : const SizedBox(),
                const SizedBox(height: 4.0),
                paragraph != null
                    ? Text(
                        paragraph!,
                        style: paragraphTextStyle,
                      )
                    : const SizedBox(),
              ],
            ),
          )),
    );
  }

  factory CustTextButton.bigDescSmallHeading(
      {required String heading,
      required String paragraph,
      VoidCallback? onTap}) {
    return CustTextButton(
      onTap: onTap,
      heading: heading,
      paragraph: paragraph,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: Vars.standardPaddingSize,
          vertical: Vars.heightGapBetweenWidgets / 2),
      headingTextStyle: const TextStyle(
          color: Colors.black54, fontSize: Vars.paragraphTextSize),
      paragraphTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: Vars.headingTextSize2,
          fontWeight: FontWeight.w500),
    );
  }
}
