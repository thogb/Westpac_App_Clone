import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class StandardPadding extends StatelessWidget {
  final Widget child;
  final bool showVerticalPadding;

  const StandardPadding(
      {Key? key, required this.child, this.showVerticalPadding = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Vars.standardPaddingSize,
          vertical: showVerticalPadding ? Vars.topBotPaddingSize : 0.0),
      child: child,
    );
  }
}
