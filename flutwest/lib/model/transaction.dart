import 'dart:convert';

import 'package:flutwest/model/account_id.dart';

class Transaction {
  static const String debits = "Debits";
  static const String credits = "Credits";
  static const String atimAndCash = "ATM and cash";
  static const String cheques = "Cheques";
  static const String deposits = "Deposits";
  static const String dividendPayments = "Dividend payments";
  static const String interestAdnFees = "Interest and fees";
  static const String paymentsAndTransfers = "Payments and transfers";

  static const List<String> types = [
    debits,
    credits,
    atimAndCash,
    cheques,
    deposits,
    dividendPayments,
    interestAdnFees,
    paymentsAndTransfers
  ];

  late final AccountID sender;
  late final AccountID receiver;
  late final DateTime dateTime;
  late final String id;
  late final String description;
  late final double amount;
  late final String type;

  Transaction(
      {required this.sender,
      required this.receiver,
      required this.dateTime,
      required this.id,
      required this.description,
      required this.amount,
      this.type = credits});

  get getSender => this.sender;

  set setSender(sender) => this.sender = sender;

  get getReceiver => this.receiver;

  set setReceiver(receiver) => this.receiver = receiver;

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

    result.addAll({'senderNumber': sender.number});
    result.addAll({'senderBsb': sender.bsb});
    result.addAll({'receiverNumber': receiver.number});
    result.addAll({'receiverBsb': receiver.bsb});
    result.addAll({'dateTime': dateTime.toString()});
    result.addAll({'id': id});
    result.addAll({'description': description});
    result.addAll({'amount': amount});

    return result;
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      sender: map['senderNumber'] != null && map["senderBsb"] != null
          ? AccountID(number: map["senderNumber"], bsb: map["senderBsb"])
          : AccountID(number: "", bsb: ""),
      receiver: map['receiverNumber'] != null && map["receiverBsb"] != null
          ? AccountID(number: map["receiverNumber"], bsb: map["receiverBsb"])
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
