import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/vars.dart';

class AccountTransaction {
  static const String fnAccountNumbers = "accountNumbers";
  static const String fnAccountBSBs = "accountBSBs";
  static const String fnDateTime = "dateTime";
  static const String fnTransactionTtypes = "transactionTypes";
  static const String fnAmount = "amount";
  static const String fnDescription = "description";
  static const String fnDoubleTypeAmount = "doubleTypeAmount";
  static const int senderIndex = 0;
  static const int receiverIndex = 1;

  static const String allTypes = "All types";
  static const String debits = "Debits";
  static const String credits = "Credits";
  static const String atmAndCash = "ATM and cash";
  static const String cheques = "Cheques";
  static const String deposits = "Deposits";
  static const String dividendPayments = "Dividend payments";
  static const String interestAdnFees = "Interest and fees";
  static const String paymentsAndTransfers = "Payments and transfers";

  static const List<String> types = [
    allTypes,
    debits,
    credits,
    atmAndCash,
    cheques,
    deposits,
    dividendPayments,
    interestAdnFees,
    paymentsAndTransfers
  ];

  final AccountID sender;
  final AccountID receiver;
  final DateTime dateTime;
  final String id;
  final Map<String, String> description;
  final Decimal amount;
  final List<String> transactionTypes;

  AccountTransaction(
      {required this.sender,
      required this.receiver,
      required this.dateTime,
      required this.id,
      required this.amount,
      required this.description,
      this.transactionTypes = const []});

  factory AccountTransaction.create(
      {required AccountID sender,
      required AccountID receiver,
      required DateTime dateTime,
      required String id,
      required Decimal amount,
      required String senderDescription,
      required receiverDescription,
      List<String> transactionTypes = const []}) {
    return AccountTransaction(
        sender: sender,
        receiver: receiver,
        dateTime: dateTime,
        id: id,
        amount: amount,
        description: {
          sender.getNumber: senderDescription,
          receiver.number: receiverDescription
        },
        transactionTypes: transactionTypes);
  }

  AccountID get getSender => this.sender;

  AccountID get getReceiver => this.receiver;

  get getDateTime => this.dateTime;

  get getId => this.id;

  Map<String, String> get getDescription => this.description;

  get getAmount => this.amount;

  Decimal getAmountPerspReceiver(String subjectNumber) {
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
    result.addAll({fnDescription: description});
    result.addAll({fnAmount: amount.toString()});
    result.addAll({fnDoubleTypeAmount: amount.toDouble()});
    if (transactionTypes.isNotEmpty) {
      Map<String, bool> map = {};
      for (String type in transactionTypes) {
        map.addAll({type: true});
      }
      result.addAll({fnTransactionTtypes: map});
    }

    return result;
  }

  factory AccountTransaction.fromMap(Map<String, dynamic> map, String inId) {
    List<String> numbers = List<String>.from(map[fnAccountNumbers] ?? const []);
    List<String> bsbs = List<String>.from(map[fnAccountBSBs] ?? const []);
    Map<String, bool> readTypesMap = map[fnTransactionTtypes] != null
        ? Map.from(map[fnTransactionTtypes] as Map)
        : {};
    List<String> readTransactionTypes = readTypesMap.keys.toList();
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
            ? AccountID(
                number: numbers[receiverIndex], bsb: bsbs[receiverIndex])
            : Vars.invalidAccountID,
        dateTime: map[fnDateTime] != null
            ? DateTime.fromMillisecondsSinceEpoch(map[fnDateTime] as int)
            : Vars.invalidDateTime,
        //id: map['id'] ?? "",
        id: inId,
        description: Map<String, String>.from(map[fnDescription] ?? {}),
        amount: Decimal.parse(map[fnAmount] ?? ""),
        transactionTypes: readTransactionTypes);
  }

  String toJson() => json.encode(toMap());

  factory AccountTransaction.fromJson(String source, String inId) =>
      AccountTransaction.fromMap(json.decode(source), inId);
}

class AccountTransactionBinded {
  final AccountTransaction accountTransaction;
  final Account account;

  AccountTransactionBinded(
      {required this.accountTransaction, required this.account});
}
