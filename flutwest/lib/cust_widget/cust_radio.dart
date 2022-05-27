import 'package:flutter/material.dart';

class CustRadio<T> extends StatelessWidget {
  static const Color? typeOneSelectColor = Color.fromARGB(255, 2, 32, 73);
  static const Color unselectColor = Colors.white;

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
    return getTypeOne(name, unselectColor, Colors.black);
  }

  static Widget _getTypeOneS(String name) {
    return getTypeOne(name, typeOneSelectColor!, Colors.white);
  }

  static Widget getTypeOne(String name, Color backGroundColor, Color fontColor,
      [Widget? trailing]) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      decoration: BoxDecoration(
          color: backGroundColor,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: typeOneSelectColor!)),
      child: Row(
        children: [
          Text(name, style: TextStyle(fontSize: 15.0, color: fontColor)),
          trailing ?? const SizedBox()
        ],
      ),
    );
  }
}
