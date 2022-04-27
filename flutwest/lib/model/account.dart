import 'dart:convert';

import 'package:flutwest/model/account_id.dart';

class Account {
  static const String typeLife = "Life";
  static const String typeChocie = "Choice";
  static const String typeeSaver = "eSaver";
  static const String typeBusiness = "Business";

  late String type;
  late AccountID accountID;
  late double balance;
  late String cardNumber;

  Account(
      {required this.type,
      required bsb,
      required number,
      required this.balance,
      required this.cardNumber})
      : accountID = AccountID(number: number, bsb: bsb);

  get getType => this.type;

  get getBsb => this.accountID.bsb;

  get getNumber => this.accountID.number;

  get getBalance => this.balance;

  set setBalance(balance) => this.balance = balance;

  get getCardNumber => this.cardNumber;

  set setCardNumber(cardNumber) => this.cardNumber = cardNumber;

  bool hasCard() {
    return cardNumber != "";
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'type': type});
    result.addAll({'bsb': accountID.bsb});
    result.addAll({'number': accountID.number});
    result.addAll({'balance': balance});
    result.addAll({'cardNumber': cardNumber});

    return result;
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
        type: map['type'] ?? '',
        bsb: map['bsb'] ?? '',
        number: map['number'] ?? '',
        balance: map['balance']?.toDouble() ?? 0.0,
        cardNumber: map['cardNumber'] ?? '');
  }

  String toJson() => json.encode(toMap());

  factory Account.fromJson(String source) =>
      Account.fromMap(json.decode(source));
}
