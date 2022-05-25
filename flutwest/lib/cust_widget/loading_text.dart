import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/vars.dart';

class LoadingText extends StatelessWidget {
  final int repeats;
  const LoadingText({Key? key, this.repeats = 1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
          repeats,
          (index) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardPadding(
                    child:
                        _getContainer(MediaQuery.of(context).size.width * 0.3),
                    showVerticalPadding: true,
                  ),
                  StandardPadding(
                    child: _getContainer(double.infinity),
                    showVerticalPadding: true,
                  )
                ],
              )),
    );
  }

  Container _getContainer(double width) {
    return Container(
      height: Vars.topBotPaddingSize * 1,
      width: width,
      decoration: BoxDecoration(
          color: Vars.loadingDummyColor,
          borderRadius: BorderRadius.circular(3.0)),
    );
  }
}
