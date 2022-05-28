import 'package:flutter/material.dart';

class CustAppbar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? trailing;
  final double showTitleOffset;
  final ScrollController scrollController;

  const CustAppbar(
      {Key? key,
      this.leading,
      this.title,
      this.trailing,
      this.showTitleOffset = kToolbarHeight,
      required this.scrollController})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;
  @override
  _CustAppbarState createState() => _CustAppbarState();
}

class _CustAppbarState extends State<CustAppbar> {
  double _elevationLevel = 0;
  Widget? _title;

  @override
  void initState() {
    widget.scrollController.addListener(_onScroll);

    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);

    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController.offset > widget.showTitleOffset) {
      if (_title == null) {
        setState(() {
          _title = widget.title;
          _elevationLevel = 3;
        });
      }
    } else {
      if (_title != null) {
        setState(() {
          _title = null;
          _elevationLevel = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: _elevationLevel,
      backgroundColor: Colors.grey[50],
      title: _title,
      leading: widget.leading,
      actions: widget.trailing,
    );
  }
}
