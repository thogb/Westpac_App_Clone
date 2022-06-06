import 'dart:convert';

import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';

class BankCard {
  static const String fnAccountNumber = "account_number";
  static const String fnAccountBSB = "account_bsb";
  static const String fnLocked = "locked";
  late String _number;
  late String _name;
  late DateTime _expiry;
  late String _cvc;
  late String _dynamicCVC;
  late DateTime _dynamicCVCExpiry;
  late bool _locked;
  late AccountID _linkedAccountID;

  BankCard(
      {required String number,
      required String name,
      required DateTime expiry,
      required String cvc,
      required String dynamicCVC,
      required DateTime dynamicCVCExpiry,
      required bool locked,
      required String accountNumber,
      required String accountBSB})
      : _number = number,
        _name = name,
        _expiry = expiry,
        _cvc = cvc,
        _dynamicCVC = dynamicCVC,
        _dynamicCVCExpiry = dynamicCVCExpiry,
        _locked = locked,
        _linkedAccountID = AccountID(number: accountNumber, bsb: accountBSB);

  get number => _number;

  set number(value) => _number = value;

  get name => _name;

  set name(value) => _name = value;

  get expiry => _expiry;

  set expiry(value) => _expiry = value;

  get cvc => _cvc;

  set cvc(value) => _cvc = value;

  get dynamicCVC => _dynamicCVC;

  set dynamicCVC(value) => _dynamicCVC = value;

  get locked => _locked;

  set locked(value) => _locked = value;

  get linkedAccountID => _linkedAccountID;

  set linkedAccountID(value) => _linkedAccountID = value;

  get firstFourDigit => _number.substring(0, 4);

  get secondFourDigit => _number.substring(4, 8);

  get thirdFourDigit => _number.substring(8, 12);

  get fourthFourDigit => _number.substring(12, 16);

  get expiryString =>
      "${Utils.getDateIntTwoSig(_expiry.month)}/${Utils.getDateIntTwoSig(_expiry.year)}";

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'number': _number});
    result.addAll({'name': _name});
    result.addAll({'expiry': _expiry.millisecondsSinceEpoch});
    result.addAll({'cvc': _cvc});
    result.addAll({'dynamicCVC': _dynamicCVC});
    result
        .addAll({"dynamicCVCExpiry": _dynamicCVCExpiry.millisecondsSinceEpoch});
    result.addAll({fnLocked: _locked});
    result.addAll({fnAccountNumber: _linkedAccountID.getNumber});
    result.addAll({fnAccountBSB: _linkedAccountID.getBsb});

    return result;
  }

  factory BankCard.fromMap(Map<String, dynamic> map) {
    return BankCard(
        number: map['number'] ?? "",
        name: map['name'] ?? "",
        expiry: map['expiry'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['expiry'] as int)
            : Vars.invalidDateTime,
        cvc: map['cvc'] ?? "",
        dynamicCVC: map['dynamicCVC'] ?? "",
        dynamicCVCExpiry:
            DateTime.fromMillisecondsSinceEpoch(map['dynamicCVCExpiry'] as int),
        locked: map[fnLocked] ?? "",
        accountNumber: map[fnAccountNumber] ?? "",
        accountBSB: map[fnAccountBSB] ?? "");
  }

  String toJson() => json.encode(toMap());

  factory BankCard.fromJson(String source) =>
      BankCard.fromMap(json.decode(source));
}
