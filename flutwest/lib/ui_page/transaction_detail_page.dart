import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';

class TransactionDetailPage extends StatefulWidget {
  final Account account;

  const TransactionDetailPage({Key? key, required this.account})
      : super(key: key);

  @override
  _TransactionDetailPageState createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getTransactionList(),
    );
    /*return Scaffold(
      body: Column(
        children: [_getFakeAppBar(), _getBody()],
      ),
    );*/
  }

  Widget _getFakeAppBar() {
    return StandardPadding(
        showVerticalPadding: true,
        child: Row(
          children: [
            StandardPadding(
                child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.red[900],
              ),
            )),
            StandardPadding(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "WestPac ${widget.account.type}",
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Transaction",
                  style: TextStyle(fontSize: 12.0),
                )
              ],
            ))
          ],
        ));
  }

  Widget _getBody() {
    return Column(
      children: [_getSerachBar(), _getFilters(), _getTransactionList()],
    );
  }

  Widget _getSerachBar() {
    return StandardPadding(child: TextField());
  }

  Widget _getFilters() {
    return StandardPadding(
      showVerticalPadding: true,
      child: Row(
        children: [],
      ),
    );
  }

  Widget _getTransactionList() {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
            floating: false, pinned: true, delegate: TheDelegate()),
        SliverFixedExtentList(
            itemExtent: 200,
            delegate: SliverChildListDelegate([
              _getRect(),
              _getRect(),
              _getRect(),
              _getRect(),
              _getRect(),
            ])),
        SliverPersistentHeader(
            floating: false, pinned: true, delegate: TheDelegate()),
        SliverFixedExtentList(
            itemExtent: 200,
            delegate: SliverChildListDelegate([
              _getRect(),
              _getRect(),
              _getRect(),
              _getRect(),
              _getRect(),
            ])),
        SliverPersistentHeader(
            floating: false, pinned: true, delegate: TheDelegate()),
        SliverFixedExtentList(
            itemExtent: 200,
            delegate: SliverChildListDelegate([
              _getRect(),
              _getRect(),
              _getRect(),
              _getRect(),
              _getRect(),
            ])),
      ],
    );
  }

  Widget _getRect() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      color: Colors.green,
      height: 80,
      width: double.infinity,
      child: Center(child: Text("12")),
    );
  }
}

class TheDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.grey[50],
      child: Text(
        "A Header",
        style: TextStyle(fontSize: 28.0),
      ),
    );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 40.0;

  @override
  // TODO: implement minExtent
  double get minExtent => 40.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
