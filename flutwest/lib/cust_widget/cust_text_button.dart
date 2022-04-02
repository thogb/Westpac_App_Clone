import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class CustTextButton extends StatelessWidget {
  final double topBotPadding = Vars.topBotPaddingSize;
  final double rightLeftPadding = Vars.standardPaddingSize;
  final String? heading;
  final String? paragraph;

  const CustTextButton({
    Key? key,
    this.heading,
    this.paragraph,
  })  : assert(heading != null || paragraph != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.fromLTRB(
              rightLeftPadding, topBotPadding, rightLeftPadding, topBotPadding),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading != null
                  ? Text(heading!, style: Vars.buttonHeadingStyle)
                  : const SizedBox(),
              paragraph != null ? Text(paragraph!) : const SizedBox(),
            ],
          ),
        ));
  }
}
