import 'dart:convert';

import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/payee.dart';

class Member {
  static const String fnRecentPayeeChange = "recentPayeeChange";

  static String? lastLoginMemberId;

  String firstName;
  String middleName;
  String surName;
  String id;
  String? cardNumber;
  List<Account> accounts;
  int nOfUnreadInbox;
  int nOfUnreadRewards;
  DateTime? recentPayeeChange;
  List<Payee>? payees;

  Member({
    required this.firstName,
    required this.middleName,
    required this.surName,
    required this.id,
    this.cardNumber,
    required this.accounts,
    this.nOfUnreadInbox = -1,
    this.nOfUnreadRewards = -1,
    this.recentPayeeChange,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'firstName': firstName});
    result.addAll({'middleName': middleName});
    result.addAll({'surName': surName});
    //result.addAll({'id': id});
    if (cardNumber != null && cardNumber!.isNotEmpty) {
      result.addAll({'cardNumber': cardNumber});
    }

    if (recentPayeeChange != null) {
      result.addAll({fnRecentPayeeChange: recentPayeeChange});
    }

    return result;
  }

  factory Member.fromMap(
      Map<String, dynamic> map, List<Account> inAccounts, String docId) {
    return Member(
        firstName: map['firstName'] ?? '',
        middleName: map['middleName'] ?? '',
        surName: map['surName'] ?? '',
        id: docId,
        //id: map['id'] ?? '',
        cardNumber: map['cardNumber'],
        accounts: inAccounts,
        recentPayeeChange: map[fnRecentPayeeChange] != null
            ? DateTime.fromMillisecondsSinceEpoch(map[fnRecentPayeeChange])
            : null);
  }

  String toJson() => json.encode(toMap());

  factory Member.fromJson(
          String source, List<Account> inAccounts, String docId) =>
      Member.fromMap(json.decode(source), inAccounts, docId);
}
