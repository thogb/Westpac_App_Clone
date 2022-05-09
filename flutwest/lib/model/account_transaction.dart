import 'dart:convert';

import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/vars.dart';

class AccountTransaction {
  static const String fnAccountNumbers = "accountNumbers";
  static const String fnAccountBSBs = "accountBSBs";
  static const String fnDateTime = "dateTime";
  static const int senderIndex = 0;
  static const int receiverIndex = 1;

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

  AccountTransaction(
      {required this.sender,
      required this.receiver,
      required this.dateTime,
      required this.id,
      required this.description,
      required this.amount,
      this.type = credits});

  AccountID get getSender => this.sender;

  set setSender(sender) => this.sender = sender;

  AccountID get getReceiver => this.receiver;

  set setReceiver(receiver) => this.receiver = receiver;

  get getDateTime => this.dateTime;

  set setDateTime(dateTime) => this.dateTime = dateTime;

  get getId => this.id;

  set setId(id) => this.id = id;

  get getDescription => this.description;

  set setDescription(description) => this.description = description;

  get getAmount => this.amount;

  set setAmount(amount) => this.amount = amount;

  double getAmountPerspReceiver(String subjectNumber) {
    return receiver.number == subjectNumber ? amount : -amount;
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    // result.addAll({'senderNumber': sender.number});
    // result.addAll({'senderBsb': sender.bsb});
    // result.addAll({'receiverNumber': receiver.number});
    // result.addAll({'receiverBsb': receiver.bsb});
    result.addAll({
      fnAccountNumbers: [sender.number, receiver.number]
    });
    result.addAll({
      fnAccountBSBs: [sender.bsb, receiver.bsb]
    });
    result.addAll({fnDateTime: dateTime.millisecondsSinceEpoch});
    //result.addAll({'id': id});
    result.addAll({'description': description});
    result.addAll({'amount': amount});

    return result;
  }

  factory AccountTransaction.fromMap(Map<String, dynamic> map, String inId) {
    List<String> numbers = List<String>.from(map[fnAccountNumbers] ?? []);
    List<String> bsbs = List<String>.from(map[fnAccountBSBs] ?? []);
    // print(map["dateTime"] as int);
    // print(DateTime.fromMillisecondsSinceEpoch(map["dateTime"] as int).year);
    return AccountTransaction(
      /*
      sender: map['senderNumber'] != null && map["senderBsb"] != null
          ? AccountID(number: map["senderNumber"], bsb: map["senderBsb"])
          : Vars.invalidAccountID,
      receiver: map['receiverNumber'] != null && map["receiverBsb"] != null
          ? AccountID(number: map["receiverNumber"], bsb: map["receiverBsb"])
          : Vars.invalidAccountID,
      */
      sender: numbers.length == 2 && bsbs.length == 2
          ? AccountID(number: numbers[senderIndex], bsb: numbers[senderIndex])
          : Vars.invalidAccountID,
      receiver: numbers.length == 2 && bsbs.length == 2
          ? AccountID(number: numbers[receiverIndex], bsb: bsbs[receiverIndex])
          : Vars.invalidAccountID,
      dateTime: map[fnDateTime] != null
          ? DateTime.fromMillisecondsSinceEpoch(map[fnDateTime] as int)
          : Vars.invalidDateTime,
      //id: map['id'] ?? "",
      id: inId,
      description: map['description'] ?? "",
      amount: map['amount'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory AccountTransaction.fromJson(String source, String inId) =>
      AccountTransaction.fromMap(json.decode(source), inId);
}
