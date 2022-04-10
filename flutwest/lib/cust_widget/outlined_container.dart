import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class OutlinedContainer extends StatelessWidget {
  static const EdgeInsetsGeometry defaultPadding = EdgeInsets.symmetric(
      vertical: Vars.topBotPaddingSize, horizontal: Vars.standardPaddingSize);

  final EdgeInsetsGeometry? padding;
  final Widget child;

  const OutlinedContainer({Key? key, this.padding, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: padding ?? defaultPadding,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.0),
            border: Border.all(width: 0.5, color: Colors.black12)),
        child: child);
  }
}
