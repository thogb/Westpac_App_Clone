import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class CustFakeAppbar extends StatefulWidget {
  final ScrollController scrollController;
  final Widget content;
  final double bottomspaceHeight;
  const CustFakeAppbar(
      {Key? key,
      required this.scrollController,
      required this.content,
      this.bottomspaceHeight = Vars.heightGapBetweenWidgets})
      : super(key: key);

  @override
  _CustFakeAppbarState createState() => _CustFakeAppbarState();
}

class _CustFakeAppbarState extends State<CustFakeAppbar> {
  double _elevationLevel = 0.0;

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
    if (widget.scrollController.offset > 10) {
      if (_elevationLevel == 0) {
        setState(() {
          _elevationLevel = 3;
        });
      }
    } else {
      setState(() {
        if (_elevationLevel != 0) {
          setState(() {
            _elevationLevel = 0;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          elevation: _elevationLevel,
          child: widget.content,
        ),
        SizedBox(height: widget.bottomspaceHeight)
      ],
    );
  }
}
