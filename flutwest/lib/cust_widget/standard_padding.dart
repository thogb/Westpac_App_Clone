import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class StandardPadding extends StatelessWidget {
  final Widget? child;
  const StandardPadding({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          Vars.standardPaddingSize, 0, Vars.standardPaddingSize, 0),
      child: child,
    );
  }
}
