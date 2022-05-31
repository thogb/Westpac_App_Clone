import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/cust_fake_appbar.dart';
import 'package:flutwest/cust_widget/cust_heading.dart';
import 'package:flutwest/cust_widget/cust_radio.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';
import 'package:flutwest/cust_widget/cust_text_field_search.dart';
import 'package:flutwest/cust_widget/loading_text.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/member.dart';
import 'package:flutwest/model/payee.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/choose_payee_page.dart';
import 'package:flutwest/ui_page/payment_page.dart';

class HomeSearchPage extends StatefulWidget {
  final List<Account> rawAccounts;
  final Member member;
  const HomeSearchPage(
      {Key? key, required this.member, required this.rawAccounts})
      : super(key: key);

  @override
  _HomeSearchPageState createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> {
  static const String filterTop = "Top";
  static const String filterSelfServe = "Self-serve";
  static const String filterTransactions = "Transactions";
  static const String filterPayeeAndBillers = "Payees & billers";
  static const String filterProducts = "Products";
  static const String filterFQAAndTopics = "FQA & topics";

  static const List<String> filters = [
    filterTop,
    filterSelfServe,
    filterTransactions,
    filterPayeeAndBillers,
    filterProducts,
    filterFQAAndTopics
  ];

  final TextEditingController _tecSearch = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _currFilter = filterTop;
  String _prevFilter = filterTop;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          CustFakeAppbar(
            bottomspaceHeight: 0,
            scrollController: _scrollController,
            content: Column(
              children: [
                // Serach text field
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Vars.standardPaddingSize,
                      vertical: Vars.standardPaddingSize / 2),
                  child: CustTextFieldSearch(
                    textEditingController: _tecSearch,
                    autoFocus: true,
                    onPrefixButtonTap: () {
                      Navigator.pop(context);
                    },
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _currFilter;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: Vars.standardPaddingSize / 2),
                // filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: List.generate(
                          filters.length,
                          (index) => CustRadio.typeOne(
                              padding: CustRadio.smallPaddingRight.copyWith(
                                  left: index == 0
                                      ? Vars.standardPaddingSize
                                      : 0.0),
                              value: filters[index],
                              groupValue: _currFilter,
                              onChanged: (value) async {
                                if (_scrollController.positions.isNotEmpty) {
                                  await _scrollController.animateTo(0,
                                      duration: const Duration(microseconds: 1),
                                      curve: Curves.easeIn);
                                }
                                if (value != _currFilter) {
                                  setState(() {
                                    _prevFilter = _currFilter;
                                    _currFilter = value;
                                  });
                                }
                              },
                              name: filters[index]))),
                ),
                const SizedBox(height: Vars.standardPaddingSize)
              ],
            ),
          ),
          Expanded(
              child: _tecSearch.text.isNotEmpty && _tecSearch.text.length < 2
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                          SizedBox(height: Vars.heightGapBetweenWidgets),
                          Text("No result found."),
                          Text("We need 2 or more characters to search.")
                        ])
                  : _getContent())
        ],
      ),
    ));
  }

  Widget _getMessageWidget(String msg) {
    return LoadingText.getLoadingWithMessage(msg, loading: false);
  }

  Widget _getLoadingMessage(String msg) {
    return LoadingText.getLoadingWithMessage(msg);
  }

  Widget _getContent() {
    if (_currFilter == filterTop) {
      return ListView.builder(
          controller: _scrollController,
          itemCount: 60,
          itemBuilder: ((context, index) => Container(
                margin: const EdgeInsets.all(Vars.standardPaddingSize),
                color: Colors.green,
                height: 60,
              )));
    } else if (_currFilter == filterSelfServe) {
      return ListView.builder(
          controller: _scrollController,
          itemCount: 60,
          itemBuilder: ((context, index) => Container(
                margin: const EdgeInsets.all(Vars.standardPaddingSize),
                color: Colors.yellow,
                height: 60,
              )));
    } else if (_currFilter == filterTransactions) {
      return ListView.builder(
          controller: _scrollController,
          itemCount: 60,
          itemBuilder: ((context, index) => Container(
                margin: const EdgeInsets.all(Vars.standardPaddingSize),
                color: Colors.red,
                height: 60,
              )));
    } else if (_currFilter == filterPayeeAndBillers) {
      return _getPayeesAndBillers();
    } else if (_currFilter == filterProducts) {
      return _getMessageWidget("Error");
    } else if (_currFilter == filterFQAAndTopics) {
      return _getMessageWidget("Error");
    } else {
      return _getMessageWidget("Error");
    }
  }

  Widget _getPayeesAndBillers() {
    String nickNameSearch = _tecSearch.text.trim();
    Future<List<Payee>> futurePayees;

    if (nickNameSearch.isNotEmpty) {
      if (nickNameSearch.length > 2 &&
          nickNameSearch.substring(0, 3).toLowerCase() == "pay") {
        nickNameSearch == nickNameSearch.substring(3);
      }
      futurePayees = FirestoreController.instance.colMember.colPayee
          .getQueriedLocal(
              memberId: widget.member.id,
              recentPayee: widget.member.recentPayeeChange,
              nickNameSearch: nickNameSearch);
    } else if (_prevFilter != filterPayeeAndBillers) {
      print("local recent");
      futurePayees = FirestoreController.instance.colMember.colPayee
          .getRecentPayLocal(
              memberId: widget.member.id,
              recentPayee: widget.member.recentPayeeChange);
    } else {
      futurePayees = Future.delayed(Duration.zero);
    }

    return FutureBuilder(
        future: futurePayees,
        builder: (context, AsyncSnapshot<List<Payee>?> snapshot) {
          if (snapshot.hasError) {
            return _getMessageWidget("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _getLoadingMessage("Loading");
          }

          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            List<Payee> payees = snapshot.data!;

            return ListView(
              children: [
                payees.isEmpty
                    ? const SizedBox()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                            payees.length + 1,
                            (index) => index == 0
                                ? _getHeading("Recently paid")
                                : _getPayeeButton(payees[index - 1]))),
                _getHeading("Make a payment"),
                CustTextButton(
                    heading: "See all payees & billers",
                    onTap: () async {
                      Object? result = await Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: ((context, animation,
                                      secondaryAnimation) =>
                                  ChoosePayeePage(
                                      accounts: widget.rawAccounts,
                                      memberId: widget.member.id,
                                      recentPayeeEdit:
                                          widget.member.recentPayeeChange))));
                      if (result != null && (result as bool)) {
                        setState(() {
                          _currFilter;
                        });
                      }
                    })
              ],
            );
          }

          return _getMessageWidget("Error");
        });
  }

  Widget _getPayeeButton(Payee payee) {
    return CustButton(
      borderOn: false,
      leftWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              const Text("Pay ", style: Vars.headingStyle2),
              Text(payee.getNickName,
                  style:
                      Vars.headingStyle2.copyWith(color: Vars.clickAbleColor))
            ],
          ),
          const SizedBox(height: Vars.gapBetweenTextVertical),
          Text("${payee.accountID.getBsb} ${payee.accountID.getNumber}",
              style: Vars.paragraphStyleGrey)
        ],
      ),
      rightWidget: Column(
        children: [
          const SizedBox(height: Vars.headingTextSize2),
          Text(
              payee.lastPayDate != null
                  ? Utils.getDateTimeWDDM(payee.lastPayDate!)
                  : "N/A",
              style: const TextStyle(fontSize: Vars.headingTextSize2)),
        ],
      ),
      onTap: () async {
        Object? result = await Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: ((context, animation, secondaryAnimation) =>
                    PaymentPage(
                        accounts: widget.rawAccounts,
                        currAccount: widget.rawAccounts[0],
                        payee: payee,
                        memberId: widget.member.id))));
        if (result != null && (result as bool)) {
          setState(() {
            _currFilter;
          });
        }
      },
    );
  }

  Widget _getHeading(String text) {
    return CustHeading.big(
        showHorPadding: true,
        heading: text,
        textStyle:
            CustHeading.bigHeadingStyle.copyWith(color: Vars.radioFilterColor));
  }
}
