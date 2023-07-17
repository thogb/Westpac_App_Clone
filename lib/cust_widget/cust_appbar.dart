import 'package:flutter/material.dart';

class CustAppbar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String? title;
  final String? subTitle;
  final List<Widget>? trailing;
  final double showTitleOffset;
  final ScrollController scrollController;
  final List<ScrollController>? scrollControllers;

  const CustAppbar(
      {Key? key,
      this.leading,
      this.title,
      this.subTitle,
      this.trailing,
      this.showTitleOffset = kToolbarHeight,
      required this.scrollController,
      this.scrollControllers})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;
  @override
  _CustAppbarState createState() => _CustAppbarState();
}

class _CustAppbarState extends State<CustAppbar> {
  double _elevationLevel = 0;
  bool _showTitle = false;

  @override
  void initState() {
    widget.scrollController.addListener(_onScroll);
    if (widget.scrollControllers != null) {
      for (ScrollController scrollController in widget.scrollControllers!) {
        if (scrollController != widget.scrollController) {
          scrollController.addListener(_onScroll);
        }
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    if (widget.scrollControllers != null) {
      for (ScrollController scrollController in widget.scrollControllers!) {
        scrollController.removeListener(_onScroll);
      }
    }

    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController.hasClients &&
        widget.scrollController.offset > widget.showTitleOffset) {
      if (_elevationLevel == 0) {
        setState(() {
          _showTitle = true;
          _elevationLevel = 3;
        });
      }
    } else {
      if (_elevationLevel != 0) {
        setState(() {
          _showTitle = false;
          _elevationLevel = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _onScroll();
    return AppBar(
      elevation: _elevationLevel,
      backgroundColor: Colors.grey[50],
      title: _showTitle
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.title != null
                    ? Text(
                        widget.title!,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      )
                    : const SizedBox(),
                widget.subTitle != null
                    ? Text(widget.subTitle!,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12.0))
                    : const SizedBox()
              ],
            )
          : null,
      leading: widget.leading,
      actions: widget.trailing,
    );
  }
}
