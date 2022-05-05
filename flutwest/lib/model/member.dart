import 'dart:convert';

import 'package:flutwest/model/account.dart';

class Member {
  String firstName;
  String middleName;
  String surName;
  String id;
  String cardNumber;
  List<Account> accounts;
  int nOfUnreadInbox;
  int nOfUnreadRewards;

  Member({
    required this.firstName,
    required this.middleName,
    required this.surName,
    required this.id,
    required this.cardNumber,
    required this.accounts,
    this.nOfUnreadInbox = -1,
    this.nOfUnreadRewards = -1,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'firstName': firstName});
    result.addAll({'middleName': middleName});
    result.addAll({'surName': surName});
    result.addAll({'id': id});
    result.addAll({'cardNumber': cardNumber});

    return result;
  }

  factory Member.fromMap(Map<String, dynamic> map, List<Account> inAccounts) {
    return Member(
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      surName: map['surName'] ?? '',
      id: map['id'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      accounts: inAccounts,
    );
  }

  String toJson() => json.encode(toMap());

  factory Member.fromJson(String source, List<Account> inAccounts) =>
      Member.fromMap(json.decode(source), inAccounts);
}
