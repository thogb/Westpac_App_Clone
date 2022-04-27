import 'dart:convert';

import 'package:flutwest/model/account_id.dart';

class Transaction {
  late AccountID accountID;
  late DateTime dateTime;
  late String id;
  late String description;
  late double amount;

  Transaction({
    required this.accountID,
    required this.dateTime,
    required this.id,
    required this.description,
    required this.amount,
  });

  get getAccountID => this.accountID;

  set setAccountID(accountID) => this.accountID = accountID;

  get getDateTime => this.dateTime;

  set setDateTime(dateTime) => this.dateTime = dateTime;

  get getId => this.id;

  set setId(id) => this.id = id;

  get getDescription => this.description;

  set setDescription(description) => this.description = description;

  get getAmount => this.amount;

  set setAmount(amount) => this.amount = amount;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'number': accountID.number});
    result.addAll({'bsb': accountID.bsb});
    result.addAll({'dateTime': dateTime.toString()});
    result.addAll({'id': id});
    result.addAll({'description': description});
    result.addAll({'amount': amount});

    return result;
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      accountID: map['number'] != null && map["bsb"] != null
          ? AccountID(number: map["number"], bsb: map["bsb"])
          : AccountID(number: "", bsb: ""),
      dateTime:
          map['dateTime'] != null ? DateTime(map["dateTime"]) : DateTime(1000),
      id: map['id'] ?? "",
      description: map['description'] ?? "",
      amount: map['amount'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source));
}
