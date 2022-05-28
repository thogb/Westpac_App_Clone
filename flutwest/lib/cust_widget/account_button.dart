import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class AccountButton extends StatelessWidget {
  final VoidCallback? ontap;
  final BoxBorder? border;
  final String leftTitle;
  final String rightTitle;

  const AccountButton(
      {Key? key,
      this.ontap,
      this.border,
      required this.leftTitle,
      required this.rightTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 3,
                offset: const Offset(0, 3))
          ],
          border: border ?? Border.all(width: 0.5, color: Colors.black12)),
      child: Material(
        borderRadius: BorderRadius.circular(4.0),
        child: InkWell(
          onTap: ontap,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Vars.standardPaddingSize,
                  Vars.topBotPaddingSize,
                  Vars.standardPaddingSize,
                  Vars.topBotPaddingSize * 2.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    leftTitle,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  Text(rightTitle,
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold))
                ],
              )),
        ),
      ),
    );
  }
}
