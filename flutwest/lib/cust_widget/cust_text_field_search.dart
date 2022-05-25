import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class CustTextFieldSearch extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool autoFocus;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClearButtonTap;
  final VoidCallback? onPrefixButtonTap;
  final void Function(bool)? onFocus;

  const CustTextFieldSearch(
      {Key? key,
      required this.textEditingController,
      this.onFocus,
      this.onPrefixButtonTap,
      this.onClearButtonTap,
      this.onSubmitted,
      this.onChanged,
      this.hintText,
      this.autoFocus = false})
      : super(key: key);

  @override
  _CustTextFieldSearchState createState() => _CustTextFieldSearchState();
}

class _CustTextFieldSearchState extends State<CustTextFieldSearch> {
  static const double iconSize = 20.0;
  static const Color iconColor = Colors.black87;
  static const InputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(3.0)),
      borderSide: BorderSide(width: 0.3, color: Colors.black54));

  final FocusNode _focusNode = FocusNode();
  late bool _isFocused;
  late final TextEditingController _controller;

  bool _showClearButton = false;

  @override
  void initState() {
    _focusNode.addListener(onFucusChange);
    _controller = widget.textEditingController;
    _isFocused = widget.autoFocus;

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(onFucusChange);
    _focusNode.dispose();

    super.dispose();
  }

  void onFucusChange() {
    if (_focusNode.hasFocus) {
      if (!_isFocused) {
        setState(() {
          _isFocused = true;
        });
      }
    } else {
      if (_isFocused) {
        setState(() {
          _isFocused = false;
        });
      }
    }

    if (widget.onFocus != null) {
      widget.onFocus!(_focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.textEditingController,
      cursorColor: Vars.clickAbleColor,
      focusNode: _focusNode,
      style: const TextStyle(fontSize: Vars.headingTextSize1),
      decoration: InputDecoration(
          hintText: widget.hintText,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: Vars.standardPaddingSize, vertical: 10),
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: inputBorder,
          prefixIcon: _isFocused
              ? GestureDetector(
                  child: const Icon(
                    Icons.arrow_back,
                    size: iconSize,
                    color: iconColor,
                  ),
                  onTap: () {
                    _focusNode.unfocus();
                    _controller.clear();
                    setState(() {
                      _showClearButton = false;
                    });

                    if (widget.onPrefixButtonTap != null) {
                      widget.onPrefixButtonTap!();
                    }
                  },
                )
              : const Icon(
                  Icons.search,
                  size: iconSize,
                  color: iconColor,
                ),
          suffixIcon: _showClearButton
              ? GestureDetector(
                  child:
                      const Icon(Icons.close, size: iconSize, color: iconColor),
                  onTap: () {
                    _controller.clear();
                    setState(() {
                      _showClearButton = false;
                    });

                    if (widget.onClearButtonTap != null) {
                      widget.onClearButtonTap!();
                    }
                  },
                )
              : null),
      onChanged: (String value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }

        if (value.isEmpty && _showClearButton) {
          setState(() {
            _showClearButton = false;
          });
        } else if (value.isNotEmpty && !_showClearButton) {
          setState(() {
            _showClearButton = true;
          });
        }
      },
      onSubmitted: widget.onSubmitted,
    );
  }
}
