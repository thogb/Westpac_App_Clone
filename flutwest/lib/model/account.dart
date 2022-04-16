import 'dart:convert';

class Account {
  static const String typeLife = "Life";
  static const String typeChocie = "Choice";
  static const String typeeSaver = "eSaver";
  static const String typeBusiness = "Business";

  late String type;
  late String bsb;
  late String number;
  late double balance;

  Account(this.type, this.bsb, this.number, this.balance);

  get getType => this.type;

  get getBsb => this.bsb;

  get getNumber => this.number;

  get getBalance => this.balance;

  set setBalance(balance) => this.balance = balance;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'type': type});
    result.addAll({'bsb': bsb});
    result.addAll({'number': number});
    result.addAll({'balance': balance});

    return result;
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      map['type'] ?? '',
      map['bsb'] ?? '',
      map['number'] ?? '',
      map['balance']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Account.fromJson(String source) =>
      Account.fromMap(json.decode(source));
}
