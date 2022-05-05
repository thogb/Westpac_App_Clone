import 'dart:convert';

import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/vars.dart';

class BankCard {
  static const String fnAccountNumber = "account_number";
  static const String fnAccountBSB = "account_bsb";
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

  get number => this._number;

  set number(value) => this._number = value;

  get name => this._name;

  set name(value) => this._name = value;

  get expiry => this._expiry;

  set expiry(value) => this._expiry = value;

  get cvc => this._cvc;

  set cvc(value) => this._cvc = value;

  get dynamicCVC => this._dynamicCVC;

  set dynamicCVC(value) => this._dynamicCVC = value;

  get locked => this._locked;

  set locked(value) => this._locked = value;

  get linkedAccountID => this._linkedAccountID;

  set linkedAccountID(value) => this._linkedAccountID = value;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'number': _number});
    result.addAll({'name': _name});
    result.addAll({'expiry': _expiry.millisecondsSinceEpoch});
    result.addAll({'cvc': _cvc});
    result.addAll({'dynamicCVC': _dynamicCVC});
    result
        .addAll({"dynamicCVCExpiry": _dynamicCVCExpiry.millisecondsSinceEpoch});
    result.addAll({'locked': _locked});
    result.addAll({fnAccountNumber: _linkedAccountID.getNumber});
    result.addAll({fnAccountBSB: _linkedAccountID.getBsb});

    return result;
  }

  factory BankCard.fromMap(Map<String, dynamic> map) {
    return BankCard(
        number: map['number'] ?? "",
        name: map['name'] ?? "",
        expiry: map['expiry'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['expiry'])
            : Vars.invalidDateTime,
        cvc: map['cvc'] ?? "",
        dynamicCVC: map['dynamicCVC'] ?? "",
        dynamicCVCExpiry:
            DateTime.fromMillisecondsSinceEpoch(map['dynamicCVCExpiry']),
        locked: map['locked'] ?? "",
        accountNumber: map[fnAccountNumber] ?? "",
        accountBSB: map[fnAccountBSB] ?? "");
  }

  String toJson() => json.encode(toMap());

  factory BankCard.fromJson(String source) =>
      BankCard.fromMap(json.decode(source));
}
