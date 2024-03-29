import 'package:flutter/material.dart';

class CustSilverAppbar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const CustSilverAppbar({Key? key, required this.title, this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.grey[50],
      elevation: 1.5,
      shadowColor: Colors.black45,
      pinned: true,
      floating: true,
      snap: false,
      expandedHeight: 80.0,
      actions: actions,
      title: const SizedBox(),
      leading: const SizedBox(),
      flexibleSpace: FlexibleSpaceBar(
          title: Text(
            title,
            style: const TextStyle(color: Colors.black),
          ),
          titlePadding: const EdgeInsets.only(bottom: 12.0, left: 15.0),
          expandedTitleScale: 1.2),
    );
  }
}
