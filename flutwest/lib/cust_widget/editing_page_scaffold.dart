import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

class EditingPageScaffold extends StatefulWidget {
  static const leadingIconDefault =
      Icon(Icons.close, color: Vars.clickAbleColor);
  static const leadingIconArrowBack =
      Icon(Icons.arrow_back, color: Vars.clickAbleColor);

  final String? title;
  final Icon leadingIcon;
  final VoidCallback? leadingOnTap;
  final List<Widget> content;
  final Widget? floatingActionButton;

  const EditingPageScaffold(
      {Key? key,
      this.title,
      required this.content,
      this.floatingActionButton,
      this.leadingIcon = leadingIconDefault,
      this.leadingOnTap})
      : super(key: key);

  @override
  _EditingPageScaffoldState createState() => _EditingPageScaffoldState();
}

class _EditingPageScaffoldState extends State<EditingPageScaffold> {
  final ScrollController _scrollController = ScrollController();

  Widget? title;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (widget.title != null) {
      if (_scrollController.offset > 20) {
        if (title == null) {
          setState(() {
            title = Text(widget.title!);
          });
        }
      } else {
        if (title != null) {
          setState(() {
            title = null;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          child: widget.leadingIcon,
          onTap: widget.leadingOnTap ??
              () {
                Navigator.pop(context);
              },
        ),
        title: title,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Vars.standardPaddingSize * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.content,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
