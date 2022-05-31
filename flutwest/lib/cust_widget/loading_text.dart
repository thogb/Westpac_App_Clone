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
                  Padding(
                    padding: const EdgeInsets.only(
                        left: Vars.standardPaddingSize,
                        right: Vars.standardPaddingSize,
                        top: Vars.heightGapBetweenWidgets,
                        bottom: Vars.heightGapBetweenWidgets / 2),
                    child:
                        _getContainer(MediaQuery.of(context).size.width * 0.3),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: Vars.standardPaddingSize,
                        right: Vars.standardPaddingSize,
                        top: Vars.heightGapBetweenWidgets / 2,
                        bottom: Vars.heightGapBetweenWidgets),
                    child: _getContainer(double.infinity),
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

  static Widget getLoadingWithMessage(String msg) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(msg,
            style: const TextStyle(
                fontSize: Vars.headingTextSize3, color: Vars.loadingColor)),
        const SizedBox(width: Vars.heightGapBetweenWidgets / 2),
        const SizedBox(
            height: Vars.headingTextSize3,
            width: Vars.headingTextSize3,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Vars.loadingColor,
            )),
      ],
    );
  }
}
