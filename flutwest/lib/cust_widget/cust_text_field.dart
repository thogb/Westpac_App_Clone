import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutwest/model/vars.dart';
import 'package:intl/intl.dart';

class CustTextField extends StatefulWidget {
  static const double moneyInputFontSize = 30.0;
  static final NumberFormat usMoneyFormatter = NumberFormat("#,###", "en_US");

  final TextEditingController? controller;
  final InputDecoration decoration;
  final int? maxLength;
  final Color? cursorColor;
  final double? cursorHeight;
  final double cursorWidth;
  final TextStyle? textStyle;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function(bool)? onFocusChange;
  final Widget? Function(BuildContext,
      {required int currentLength,
      required bool isFocused,
      required int? maxLength})? buildCounter;
  final String? Function(String value)? getErrorMsg;

  const CustTextField(
      {Key? key,
      this.controller,
      this.decoration = const InputDecoration(),
      this.maxLength,
      this.keyboardType,
      this.onChanged,
      this.onSubmitted,
      this.textStyle,
      this.cursorColor,
      this.cursorHeight,
      this.cursorWidth = 1.5,
      this.inputFormatters,
      this.buildCounter,
      this.getErrorMsg,
      this.onFocusChange})
      : super(key: key);

  factory CustTextField.moneyInput(
      {TextEditingController? controller,
      String? errorText,
      String? Function(String value)? getErrorMsg,
      void Function(String)? onChanged}) {
    controller ??= TextEditingController();

    return CustTextField(
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.,]"))],
      cursorHeight: moneyInputFontSize + 5,
      cursorColor: Vars.clickAbleColor,
      controller: controller,
      getErrorMsg: getErrorMsg,
      textStyle:
          const TextStyle(fontSize: moneyInputFontSize, color: Colors.black),
      onChanged: (value) {
        if (controller != null) {
          if (value.isNotEmpty) {
            int offset = controller.selection.baseOffset;
            String temp;
            String newChar = offset != 0 ? value[offset - 1] : "";

            if (newChar == ",") {
              value = value.replaceRange(offset - 1, offset, "");
              offset--;
              newChar = offset != 0 ? value[offset - 1] : "";
            }

            temp = value;

            int dotLocation = temp.indexOf(".");

            if (newChar == ".") {
              if (temp.length == 1) {
                controller.text = temp;
                controller.selection = const TextSelection.collapsed(offset: 1);
                return;
              }
              // If the new char was dot and there is already a dot in old string
              // Make sure input money is valid only one decimal dot
              if ((temp.substring(offset, temp.length).contains(".") ||
                  temp.substring(0, offset - 1).contains("."))) {
                temp = temp.replaceFirst(RegExp(r'.'), '', offset - 1);
              } else if (temp.substring(offset).length > 2) {
                // If inserted dot but right sided has more than 2 chars
                // Ensure only two decimal palces
                temp = temp.replaceRange(offset - 1, offset, "");
              }
            } else if (dotLocation != -1 &&
                dotLocation < (offset - 1) &&
                (temp.length - 1 - dotLocation) > 2) {
              // If new char is not dot and there is already a dot and new char is
              // behind the dot position.
              // Make sure to only input money no more than 2 decimal places
              temp = temp.replaceRange(offset - 1, offset, "");
            }

            if (temp == ".") {
              controller.text = temp;
              controller.selection = const TextSelection.collapsed(offset: 1);
              return;
            }

            dotLocation = temp.indexOf(".");

            // Split integer part and decimal part into two
            String leftSide =
                dotLocation != -1 ? temp.substring(0, dotLocation) : temp;
            String rightSide =
                dotLocation != -1 ? temp.substring(dotLocation + 1) : "";

            // Parse the integer part
            int? leftAmount = int.tryParse(leftSide.replaceAll(r",", ""));
            // case where temp = .xx,
            leftAmount ??= 0;

            // Reformat the new String
            controller.text = dotLocation != -1
                ? usMoneyFormatter.format(leftAmount) + "." + rightSide
                : usMoneyFormatter.format(leftAmount);

            // New cursor position
            controller.selection = TextSelection.collapsed(
                offset: min(
                    max(offset + controller.text.length - value.length, 0),
                    controller.text.length));
          }
          if (onChanged != null) {
            onChanged(controller.text);
          }
        }
      },
      decoration: InputDecoration(
          errorText: errorText,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.5)),
          suffixIcon: errorText != null
              ? const Icon(Icons.error, color: Vars.errorColor)
              : null,
          prefix: const Padding(
            padding: EdgeInsets.only(right: 4.0),
            child: Text(
              "\$",
              style: TextStyle(color: Colors.black),
            ),
          ),
          hintText: "0.00"),
      keyboardType: TextInputType.number,
    );
  }

  factory CustTextField.standardSmall(
      {TextEditingController? controller,
      String? label,
      int? maxLength,
      void Function(String)? onChanged,
      TextInputType? keyboardType,
      void Function(bool)? onFocusChange}) {
    controller ??= TextEditingController();
    return CustTextField(
      onFocusChange: onFocusChange,
      keyboardType: keyboardType,
      onChanged: onChanged,
      controller: controller,
      maxLength: maxLength,
      buildCounter: maxLength != null
          ? (BuildContext context,
              {required int currentLength,
              required bool isFocused,
              required int? maxLength}) {
              return isFocused
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text("${maxLength! - currentLength} remaining",
                          style: const TextStyle(
                              fontSize: Vars.paragraphTextSize,
                              color: Colors.black54)),
                    )
                  : null;
            }
          : null,
      decoration: InputDecoration(
          isDense: true,
          labelText: label,
          floatingLabelStyle: const TextStyle(
              fontSize: Vars.paragraphTextSize + 4, color: Colors.black54),
          labelStyle: const TextStyle(
              fontSize: Vars.headingTextSize3, color: Colors.black)),
    );
  }

  @override
  _CustTextFieldState createState() => _CustTextFieldState();
}

class _CustTextFieldState extends State<CustTextField> {
  final FocusNode _focusNode = FocusNode();
  String? _errorMsg;
  bool _showClearButton = false;

  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(onFocusChange);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(onFocusChange);
    _focusNode.dispose();

    super.dispose();
  }

  void onFocusChange() {
    if (_focusNode.hasFocus == false) {
      _controller.text = _controller.text.trim();
    }

    checkClearButton(_controller.text);

    if (widget.onFocusChange != null) {
      widget.onFocusChange!(_focusNode.hasFocus);
    }
  }

  void checkClearButton(String value) {
    if (_focusNode.hasFocus) {
      if (!_showClearButton && value.isNotEmpty) {
        setState(() {
          _showClearButton = true;
        });
      } else if (_showClearButton && value.isEmpty) {
        setState(() {
          _showClearButton = false;
        });
      }
    } else {
      if (_showClearButton) {
        setState(() {
          _showClearButton = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,
      inputFormatters: widget.inputFormatters,
      cursorColor: widget.cursorColor,
      cursorHeight: widget.cursorHeight,
      cursorWidth: widget.cursorWidth,
      style: widget.textStyle,
      controller: _controller,
      buildCounter: widget.buildCounter,
      decoration: widget.decoration.copyWith(
          errorText: _errorMsg,
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.5)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.5)),
          suffixIconConstraints: const BoxConstraints(),
          suffixIcon: _showClearButton
              ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    if (widget.onChanged != null) {
                      widget.onChanged!(_controller.text);
                    }

                    setState(() {
                      _errorMsg = null;
                      _showClearButton = false;
                    });
                  },
                  child: const Icon(
                    Icons.cancel,
                    color: Colors.black54,
                  ))
              : null),
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }

        if (widget.getErrorMsg != null) {
          setState(() {
            _errorMsg = widget.getErrorMsg!(_controller.text);
          });
        }

        checkClearButton(value);
      },
      onSubmitted: widget.onSubmitted,
    );
  }
}
