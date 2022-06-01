import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutwest/model/account_id.dart';

class Account {
  static const String fnMemberID = "memberID";
  static const String fnBalance = "balance";
  static const String fnAccountNumber = "number";

  static const String typeLife = "Life";
  static const String typeChocie = "Choice";
  static const String typeeSaver = "eSaver";
  static const String typeBusiness = "Business";

  final String type;
  final String? docID;
  final AccountID accountID;
  Decimal balance;
  final String cardNumber;
  final String memberID;

  Account(
      {required this.type,
      required bsb,
      required number,
      required this.balance,
      required this.cardNumber,
      required this.memberID,
      this.docID})
      : accountID = AccountID(number: number, bsb: bsb);

  String get getType => this.type;

  String get getBsb => this.accountID.bsb;

  String get getNumber => this.accountID.number;

  get getBalance => this.balance;

  set setBalance(balance) => this.balance = balance;

  String get getCardNumber => this.cardNumber;

  String get getBalanceUSDToString => "\$${balance.round(scale: 2)}";

  String get getAccountName => "Westpac $type";

  bool hasCard() {
    return cardNumber != "";
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'type': type});
    result.addAll({'bsb': accountID.bsb});
    result.addAll({fnAccountNumber: accountID.number});
    result.addAll({fnBalance: balance.toString()});
    result.addAll({'cardNumber': cardNumber});
    result.addAll({fnMemberID: memberID});

    return result;
  }

  factory Account.fromMap(Map<String, dynamic> map, String docID) {
    return Account(
        type: map['type'] ?? '',
        bsb: map['bsb'] ?? '',
        number: map[fnAccountNumber] ?? '',
        balance: Decimal.parse(map[fnBalance] ?? "0"),
        cardNumber: map['cardNumber'] ?? '',
        memberID: map[fnMemberID] ?? "",
        docID: docID);
  }

  String toJson() => json.encode(toMap());

  factory Account.fromJson(String source, String docID) =>
      Account.fromMap(json.decode(source), docID);
}

class AccountOrderInfo {
  late Account account;
  late int order;
  late int hidden;

  AccountOrderInfo(
      {required this.account, required this.order, required this.hidden});

  get getOrder => this.order;

  set setOrder(order) => this.order = order;

  get getHidden => this.hidden;

  set setHidden(hidden) => this.hidden = hidden;

  get isHidden => hidden == 1 ? true : false;

  @override
  String toString() {
    return account.type;
  }

  Account getAccount() {
    return account;
  }

  AccountIDOrder getAccountIDOrder() {
    return AccountIDOrder(
        number: account.accountID.number,
        bsb: account.accountID.bsb,
        order: order,
        hidden: hidden);
  }
}
