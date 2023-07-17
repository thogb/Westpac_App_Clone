import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class CustFloatingButton extends StatelessWidget {
  final Color buttonColor;
  final String title;
  final VoidCallback? onPressed;

  const CustFloatingButton(
      {Key? key,
      required this.title,
      required this.buttonColor,
      this.onPressed})
      : super(key: key);

  factory CustFloatingButton.enabled(
      {required String title, required VoidCallback onPressed}) {
    return CustFloatingButton(
        title: title, buttonColor: Vars.clickAbleColor, onPressed: onPressed);
  }

  factory CustFloatingButton.disabled({required String title}) {
    return CustFloatingButton(
        title: title, buttonColor: Vars.disabledClickableColor);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Vars.standardPaddingSize),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            backgroundColor: buttonColor),
        child: Center(
            heightFactor: 2.0,
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.normal),
            )),
      ),
    );
  }
}
