import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class CustHeading extends StatelessWidget {
  final String heading;

  static const TextStyle headingStyle = Vars.headingStyle1;

  const CustHeading({Key? key, required this.heading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Vars.standardPaddingSize,
          Vars.topBotPaddingSize + 10.0,
          Vars.standardPaddingSize,
          Vars.topBotPaddingSize),
      child: Text(
        heading,
        style: headingStyle,
      ),
    );
  }
}
