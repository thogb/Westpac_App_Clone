import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class CustRadio<T> extends StatelessWidget {
  static const EdgeInsets smallPaddingRight = EdgeInsets.only(right: 5);
  static const EdgeInsets normalPaddingRight = EdgeInsets.only(right: 10);
  static const EdgeInsets paddingRightBot =
      EdgeInsets.only(right: 10, bottom: 15);

  static const Color? typeOneSelectColor = Color.fromARGB(255, 2, 32, 73);
  static const Color unselectColor = Colors.white;

  final T value;
  final T groupValue;
  final Widget unselectedChild;
  final Widget selectedChild;
  final ValueSetter onChanged;
  final EdgeInsetsGeometry padding;

  const CustRadio(
      {Key? key,
      required this.value,
      required this.groupValue,
      required this.unselectedChild,
      required this.selectedChild,
      required this.onChanged,
      this.padding = normalPaddingRight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: value == groupValue ? selectedChild : unselectedChild,
      ),
    );
  }

  factory CustRadio.typeOne(
      {required T value,
      required T groupValue,
      required ValueSetter onChanged,
      required String name,
      EdgeInsets? padding}) {
    return CustRadio(
        padding: padding ?? normalPaddingRight,
        value: value,
        groupValue: groupValue,
        unselectedChild: _getTypeOneUnS(name: name),
        selectedChild: _getTypeOneS(name: name),
        onChanged: onChanged);
  }

  static Widget _getTypeOneUnS({required String name}) {
    return getTypeOne(
        name: name, backGroundColor: unselectColor, fontColor: Colors.black);
  }

  static Widget _getTypeOneS({required String name}) {
    return getTypeOne(
        name: name,
        backGroundColor: typeOneSelectColor!,
        fontColor: Colors.white);
  }

  static Widget getTypeOne(
      {required String name,
      required Color backGroundColor,
      required Color fontColor,
      Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      decoration: BoxDecoration(
          color: backGroundColor,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: typeOneSelectColor!)),
      child: Wrap(
        children: [
          Text(name, style: TextStyle(fontSize: 15.0, color: fontColor)),
          trailing ?? const SizedBox()
        ],
      ),
    );
  }
}
