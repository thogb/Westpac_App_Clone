import 'package:flutwest/model/account_id.dart';

class Payee {
  final AccountID accountID;
  final String? nickName;
  final String accountName;

  Payee(
      {required String accountNumber,
      required String accountBSB,
      required this.accountName,
      this.nickName})
      : accountID = AccountID(number: accountName, bsb: accountBSB);

  AccountID get getAccountID => this.accountID;

  String get getNickName => nickName ?? accountName;

  String get getAccountName => this.accountName;
}
