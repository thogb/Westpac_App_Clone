import 'package:flutter/material.dart';

class CustRadio<T> extends StatelessWidget {
  static final Color? typeOneSelectColor = Colors.blue[900];

  final T value;
  final T groupValue;
  final Widget unselectedChild;
  final Widget selectedChild;
  final ValueSetter onChanged;

  const CustRadio(
      {Key? key,
      required this.value,
      required this.groupValue,
      required this.unselectedChild,
      required this.selectedChild,
      required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: value == groupValue ? selectedChild : unselectedChild,
    );
  }

  factory CustRadio.typeOne(
      {required T value,
      required T groupValue,
      required ValueSetter onChanged,
      required String name}) {
    return CustRadio(
        value: value,
        groupValue: groupValue,
        unselectedChild: _getTypeOneUnS(name),
        selectedChild: _getTypeOneS(name),
        onChanged: onChanged);
  }

  static Widget _getTypeOneUnS(String name) {
    return _getTypeOne(name, typeOneSelectColor!, Colors.black);
  }

  static Widget _getTypeOneS(String name) {
    return _getTypeOne(name, typeOneSelectColor!, Colors.white);
  }

  static Widget _getTypeOne(
      String name, Color backGroundColor, Color fontColor) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
          color: backGroundColor,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: backGroundColor)),
      child: Center(
          child:
              Text(name, style: TextStyle(fontSize: 18.0, color: fontColor))),
    );
  }
}
