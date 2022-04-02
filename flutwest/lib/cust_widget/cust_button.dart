import 'package:flutter/material.dart';

class CustButton extends StatelessWidget {
  final String heading;
  final String paragraph;
  final Widget? leftWidget;
  final Widget? rightWidget;

  const CustButton(
      {Key? key,
      required this.heading,
      required this.paragraph,
      this.leftWidget,
      this.rightWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
