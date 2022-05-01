class AccountID {
  late String number;
  late String bsb;

  AccountID({required this.number, required this.bsb});

  get getNumber => this.number;

  set setNumber(number) => this.number = number;

  get getBsb => this.bsb;

  set setBsb(bsb) => this.bsb = bsb;
}

class AccountIDOrder {
  late AccountID accountID;
  late int order;

  AccountIDOrder({required number, required bsb, required this.order})
      : accountID = AccountID(number: number, bsb: bsb);

  get getAccountID => this.accountID;

  set setAccountID(accountID) => this.accountID = accountID;

  get getOrder => this.order;

  set setOrder(order) => this.order = order;
}
