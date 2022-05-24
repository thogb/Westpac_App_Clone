import 'dart:convert';

import 'package:flutwest/model/account_id.dart';

class Payee {
  static const String fnAccountNumber = "accountNumber";
  static const String fnAccountBsb = "accountBsb";

  final AccountID accountID;
  final String? nickName;
  final String accountName;
  final DateTime? lastPayDate;

  Payee(
      {required String accountNumber,
      required String accountBSB,
      required this.accountName,
      this.nickName,
      this.lastPayDate})
      : accountID = AccountID(number: accountName, bsb: accountBSB);

  AccountID get getAccountID => this.accountID;

  String get getNickName => nickName ?? accountName;

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
    if (nickName != null) {
      result.addAll({'nickName': nickName});
    }
    result.addAll({'accountName': accountName});

    return result;
  }

  factory Payee.fromMap(Map<String, dynamic> map) {
    return Payee(
        accountNumber: map[fnAccountNumber] ?? "",
        accountBSB: map[fnAccountBsb] ?? "",
        accountName: map['accountName'] ?? "",
        nickName: map['nickName']);
  }

  String toJson() => json.encode(toMap());

  factory Payee.fromJson(String source) => Payee.fromMap(json.decode(source));
}
