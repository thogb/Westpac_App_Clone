import 'package:flutter/material.dart';

class CustAppbar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? trailing;
  const CustAppbar({Key? key, this.leading, this.title, this.trailing})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;
  @override
  _CustAppbarState createState() => _CustAppbarState();
}

class _CustAppbarState extends State<CustAppbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[50],
      title: widget.title,
      leading: widget.leading,
      actions: widget.trailing,
    );
  }
}
