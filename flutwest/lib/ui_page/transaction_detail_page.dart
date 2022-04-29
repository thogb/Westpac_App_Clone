import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_radio.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/transaction.dart';
import 'package:flutwest/model/vars.dart';

class TransactionDetailPage extends StatefulWidget {
  final Account account;
  final bool isInputting;

  const TransactionDetailPage(
      {Key? key, required this.account, this.isInputting = false})
      : super(key: key);

  @override
  _TransactionDetailPageState createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage>
    with TickerProviderStateMixin {
  late final AnimationController _fakeAppBarController = AnimationController(
      duration: const Duration(milliseconds: 300), vsync: this);
  /*
  late final Animation<double> _fakeAppBarFade =
      CurvedAnimation(parent: _fakeAppBarController, curve: Curves.linear);

  late final Animation<double> _fakeAppBarSize =
      CurvedAnimation(parent: _fakeAppBarController, curve: Curves.linear);*/

  late final Animation<double> _fakeAppBarFade =
      Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _fakeAppBarController, curve: Curves.linear));

  late final Animation<double> _fakeAppBarSize =
      Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _fakeAppBarController, curve: Curves.linear));

  String _transactionType = Transaction.types[0];

  bool _isInputting = false;
  bool _showElevation = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _isInputting = widget.isInputting;
    _scrollController.addListener(() {
      if (_scrollController.offset > 5.0) {
        if (_showElevation == false) {
          setState(() {
            _showElevation = true;
          });
        }
      } else {
        if (_showElevation == true) {
          setState(() {
            _showElevation = false;
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Material(
            elevation: _showElevation ? 4.0 : 0.0,
            child: Container(
              padding: const EdgeInsets.only(top: 30.0),
              child: Column(
                children: [
                  SizeTransition(
                    axisAlignment: -1,
                    sizeFactor: _fakeAppBarSize,
                    child: FadeTransition(
                      opacity: _fakeAppBarFade,
                      child: _getFakeAppBar(),
                    ),
                  ),
                  _getSearchBar(),
                  const SizedBox(height: Vars.topBotPaddingSize),
                  _getFilters(),
                  const SizedBox(
                    height: Vars.topBotPaddingSize,
                  )
                ],
              ),
            ),
          ),
          Expanded(child: _getTransactionList())
        ],
      ),
    );
  }

  Widget _getFakeAppBar() {
    return StandardPadding(
        showVerticalPadding: true,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.red[900],
              ),
            ),
            const SizedBox(width: Vars.standardPaddingSize),
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

  Widget _getSearchBar() {
    return StandardPadding(
        child: TextField(
      onTap: () {
        _fakeAppBarController.forward();
        setState(() {
          _isInputting = true;
        });
      },
      style: const TextStyle(fontSize: 18.0),
      decoration: InputDecoration(
          prefixIcon: !_isInputting
              ? const Icon(Icons.search, color: Colors.black54)
              : GestureDetector(
                  onTap: () {
                    _fakeAppBarController.reverse();
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    setState(() {
                      _isInputting = false;
                    });
                  },
                  child: const Icon(Icons.arrow_back, color: Colors.black54)),
          contentPadding: EdgeInsets.zero,
          hintText: "Search by name, date, amount",
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0)),
          border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0))),
    ));
  }

  Widget _getFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: List.generate(Transaction.types.length + 1, (index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(
                left: Vars.standardPaddingSize,
                right: Vars.heightGapBetweenWidgets / 2),
            child: GestureDetector(
              onTap: () {},
              child: CustRadio.getTypeOne("Filter", CustRadio.unselectColor,
                  Colors.black, const Icon(Icons.arrow_drop_down)),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Vars.heightGapBetweenWidgets / 2),
          child: CustRadio.typeOne(
              value: Transaction.types[index - 1],
              groupValue: _transactionType,
              onChanged: (value) {
                setState(() {
                  _transactionType = value;
                });
              },
              name: Transaction.types[index - 1]),
        );
      })),
    );
  }

  Widget _getTransactionList() {
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      itemCount: 20,
      itemBuilder: (BuildContext context, int index) {
        return Container(
            color: Colors.green, height: 50.0, margin: EdgeInsets.all(5.0));
      },
    );
  }
}
