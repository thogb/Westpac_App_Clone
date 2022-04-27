class AccountID {
  late String number;
  late String bsb;

  AccountID({required this.number, required this.bsb});

  get getNumber => this.number;

  set setNumber(number) => this.number = number;

  get getBsb => this.bsb;

  set setBsb(bsb) => this.bsb = bsb;
}
