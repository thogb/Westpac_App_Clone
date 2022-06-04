import 'dart:convert';

import 'package:flutwest/model/account_id.dart';

class Payee {
  static const String fnAccountNumber = "accountNumber";
  static const String fnAccountBsb = "accountBsb";
  static const String fnLastPayDate = "lastPayDate";

  final String docId;
  final AccountID accountID;
  final String nickName;
  final String accountName;
  DateTime? lastPayDate;

  Payee(
      {required this.docId,
      required String accountNumber,
      required String accountBSB,
      required this.accountName,
      required this.nickName,
      this.lastPayDate})
      : accountID = AccountID(number: accountNumber, bsb: accountBSB);

  /// Payee without an doc Id that should only exist temporarily locally after
  /// creating a payee from add page page. Then immediately send to cloud and
  /// with the returned Id to create the [Payee] object with the docId.
  factory Payee.noId(
      {required String accountNumber,
      required String accountBSB,
      required String accountName,
      required String nickName,
      DateTime? lastPayDate}) {
    return Payee(
        docId: "",
        accountNumber: accountNumber,
        accountBSB: accountBSB,
        accountName: accountName,
        nickName: nickName);
  }

  AccountID get getAccountID => this.accountID;

  String get getNickName => nickName;

  String get getAccountName => this.accountName;

  bool isAllEqual(Payee other) {
    return this.accountID.getNumber == other.accountID.getNumber &&
        this.accountID.getBsb == other.accountID.getBsb &&
        this.accountName == other.accountName &&
        this.nickName == other.nickName;
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({fnAccountNumber: accountID.getNumber});
    result.addAll({fnAccountBsb: accountID.getBsb});

    result.addAll({'nickName': nickName});

    result.addAll({'accountName': accountName});

    if (lastPayDate != null) {
      result.addAll({fnLastPayDate: lastPayDate!.millisecondsSinceEpoch});
    }

    return result;
  }

  factory Payee.fromMap(Map<String, dynamic> map, String docId) {
    return Payee(
        docId: docId,
        accountNumber: map[fnAccountNumber] ?? "",
        accountBSB: map[fnAccountBsb] ?? "",
        accountName: map['accountName'] ?? "",
        nickName: map['nickName'] ?? "",
        lastPayDate: map[fnLastPayDate] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map[fnLastPayDate]));
  }

  String toJson() => json.encode(toMap());

  factory Payee.fromJson(String source, String docId) =>
      Payee.fromMap(json.decode(source), docId);
}
