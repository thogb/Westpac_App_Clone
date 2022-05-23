import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/clickable_text.dart';
import 'package:flutwest/cust_widget/cust_floating_button.dart';
import 'package:flutwest/cust_widget/cust_radio.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';
import 'package:flutwest/cust_widget/cust_text_field_search.dart';
import 'package:flutwest/cust_widget/editing_page_scaffold.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/add_payee_page.dart';

class ChoosePayeePage extends StatefulWidget {
  final List<Account> accounts;
  const ChoosePayeePage({Key? key, required this.accounts}) : super(key: key);

  @override
  _ChoosePayeePageState createState() => _ChoosePayeePageState();
}

class _ChoosePayeePageState extends State<ChoosePayeePage>
    with TickerProviderStateMixin {
  late final AnimationController _fakeAppBarController = AnimationController(
      duration: const Duration(milliseconds: 300), vsync: this);

  late final Animation<double> _fakeAppBarFade =
      Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
          parent: _fakeAppBarController, curve: Curves.decelerate));

  late final Animation<double> _fakeAppBarSize =
      Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
          parent: _fakeAppBarController, curve: Curves.decelerate));

  static const List<String> payeeFilters = [
    "All",
    "Payees",
    "Billers",
    "Internationals"
  ];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _tecSearch = TextEditingController();

  String _currFilter = payeeFilters[1];
  double _elevationLevel = 0;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [_getFakeAppBar(), Expanded(child: _getPayeeList())],
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.offset > 10) {
      setState(() {
        if (_elevationLevel == 0) {
          _elevationLevel = 3;
        }
      });
    } else {
      setState(() {
        if (_elevationLevel != 0) {
          _elevationLevel = 0;
        }
      });
    }
  }

  Widget _getFakeAppBar() {
    return Container(
      padding: const EdgeInsets.only(top: Vars.gapAtTop - 5, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fake app bar heading part
          SizeTransition(
            axisAlignment: -1,
            sizeFactor: _fakeAppBarSize,
            child: FadeTransition(
              opacity: _fakeAppBarFade,
              child: StandardPadding(
                  showVerticalPadding: true,
                  child: Row(
                    children: [
                      GestureDetector(
                        child:
                            const Icon(Icons.close, color: Vars.clickAbleColor),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      const Expanded(
                          child: Text("Choose who to pay",
                              style: Vars.headingStyle1)),
                      ClickableText(
                        text: "Add",
                        textStyle: const TextStyle(
                            fontSize: Vars.headingTextSize2,
                            color: Vars.clickAbleColor),
                        onTap: _showBottomSheet,
                      )
                    ],
                  )),
            ),
          ),

          // Search text field
          StandardPadding(
              child: CustTextFieldSearch(
            textEditingController: _tecSearch,
            onFocus: () {
              _fakeAppBarController.forward();
            },
            onPrefixButtonTap: () {
              _fakeAppBarController.reverse();
            },
          )),
          const SizedBox(height: Vars.heightGapBetweenWidgets),

          // Payee filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                  payeeFilters.length,
                  (index) => Padding(
                        padding: EdgeInsets.only(
                            left: index == 0
                                ? Vars.standardPaddingSize
                                : Vars.standardPaddingSize / 2,
                            right: Vars.standardPaddingSize / 2),
                        child: CustRadio.typeOne(
                            value: payeeFilters[index],
                            groupValue: _currFilter,
                            onChanged: (value) {
                              setState(() {
                                _currFilter = value;
                              });
                            },
                            name: payeeFilters[index]),
                      )),
            ),
          ),
          Material(
            elevation: _elevationLevel,
            child: Container(
              height: Vars.heightGapBetweenWidgets,
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet() {
    TextStyle headingButtonStyle = const TextStyle(
        fontSize: Vars.headingTextSize3, fontWeight: FontWeight.w600);
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              const CustTextButton(
                heading: "Add new",
                headingTextStyle: TextStyle(
                    fontSize: Vars.headingTextSize3, color: Colors.black54),
              ),
              CustTextButton(
                headingTextStyle: headingButtonStyle,
                heading: "BSB & Account",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder:
                              ((context, animation, secondaryAnimation) =>
                                  const AddPayeePage())));
                },
              ),
              CustTextButton(
                headingTextStyle: headingButtonStyle,
                heading: "BPAY Biller",
              ),
              CustTextButton(
                headingTextStyle: headingButtonStyle,
                heading: "BSB & Account",
              ),
              CustTextButton(
                headingTextStyle: headingButtonStyle,
                heading: "International",
              ),
              CustTextButton(
                headingTextStyle: headingButtonStyle,
                heading: "Other PayID",
              )
            ],
          );
        });
  }

  Widget _getPayeeList() {
    return ListView.builder(
        padding: EdgeInsets.zero,
        controller: _scrollController,
        itemCount: 60,
        itemBuilder: ((context, index) => Container(
              height: 40,
              margin: const EdgeInsets.all(Vars.standardPaddingSize),
              color: Colors.red,
            )));
  }
}
