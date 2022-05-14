import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/account_transaction.dart';
import 'package:flutwest/model/bank_card.dart';
import 'package:flutwest/model/member.dart';
import 'package:decimal/decimal.dart';

void main() {
  test("fake firestore test", () async {
    String memberId = "12345678";
    String cardNumber = "5166623996788864";

    AccountID accountID = AccountID(number: "22222222", bsb: "222-333");

    BankCard bankCard = BankCard(
        number: "22223333",
        name: "Tao Hu",
        expiry: DateTime(2023, 5, 1),
        cvc: "800",
        dynamicCVC: "999",
        dynamicCVCExpiry: DateTime(2023, 4, 1),
        locked: false,
        accountBSB: accountID.getBsb,
        accountNumber: accountID.getNumber);

    //dynamic bankcardMap = bankCard.toMap();

    Account account1 = Account(
        type: Account.typeChocie,
        bsb: "111-111",
        number: "111111",
        balance: 4000,
        cardNumber: cardNumber);
    Account account2 = Account(
        type: Account.typeChocie,
        bsb: "111-111",
        number: "111112",
        balance: 8000,
        cardNumber: "");
    Account account3 = Account(
        type: Account.typeChocie,
        bsb: "111-111",
        number: "111113",
        balance: 1000,
        cardNumber: "");

    Account account4 = Account(
        type: Account.typeChocie,
        bsb: "111-111",
        number: "111114",
        balance: 8000,
        cardNumber: "");
    Account account5 = Account(
        type: Account.typeChocie,
        bsb: "111-111",
        number: "111115",
        balance: 9000,
        cardNumber: "");

    Member member = Member(
        firstName: "Tao",
        middleName: "",
        surName: "Hu",
        id: memberId,
        cardNumber: cardNumber,
        accounts: [account1, account2, account3]);

    AccountTransaction accountTransaction1 = AccountTransaction(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2022, 4, 1),
        id: "",
        description: "account 1 to account 2",
        amount: 100);
    AccountTransaction accountTransaction2 = AccountTransaction(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2022, 4, 2),
        id: "",
        description: "account 1 to account 2",
        amount: 200);
    AccountTransaction accountTransaction3 = AccountTransaction(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2022, 4, 3),
        id: "",
        description: "account 1 to account 2",
        amount: 300);
    AccountTransaction accountTransaction4 = AccountTransaction(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2022, 4, 4),
        id: "",
        description: "account 1 to account 2",
        amount: 400);
    AccountTransaction accountTransaction5 = AccountTransaction(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2022, 4, 5),
        id: "",
        description: "account 1 to account 2",
        amount: 500);

    AccountTransaction accountTransaction6 = AccountTransaction(
        sender: account4.accountID,
        receiver: account1.accountID,
        dateTime: DateTime(2022, 4, 5),
        id: "",
        description: "account 1 to account 2",
        amount: 333);
    AccountTransaction accountTransaction7 = AccountTransaction(
        sender: account3.accountID,
        receiver: account1.accountID,
        dateTime: DateTime(2022, 4, 6),
        id: "",
        description: "account 1 to account 2",
        amount: 1000);
    AccountTransaction accountTransaction8 = AccountTransaction(
        sender: account5.accountID,
        receiver: account1.accountID,
        dateTime: DateTime(2022, 4, 3),
        id: "",
        description: "account 1 to account 2",
        amount: 700);
    AccountTransaction accountTransaction9 = AccountTransaction(
        sender: account5.accountID,
        receiver: account3.accountID,
        dateTime: DateTime(2022, 4, 3),
        id: "",
        description: "account 1 to account 2",
        amount: 1700);
    AccountTransaction accountTransaction10 = AccountTransaction(
        sender: account3.accountID,
        receiver: account2.accountID,
        dateTime: DateTime(2022, 4, 3),
        id: "",
        description: "account 1 to account 2",
        amount: 1300);

    //print(bankcardMap);

    FirestoreController.instance.setFirebaseFireStore(FakeFirebaseFirestore());
    FirestoreController.instance.addMember(memberId, member);
    //FakeFirebaseFirestore fakeFirebaseFirestore = FakeFirebaseFirestore();
    FirestoreController.instance.addAccount(memberId, account1);
    FirestoreController.instance.addAccount(memberId, account2);
    FirestoreController.instance.addAccount(memberId, account3);
    FirestoreController.instance.addBankCard(cardNumber, bankCard);
    FirestoreController.instance.addTransaction(accountTransaction1);
    FirestoreController.instance.addTransaction(accountTransaction2);
    FirestoreController.instance.addTransaction(accountTransaction3);
    FirestoreController.instance.addTransaction(accountTransaction4);
    FirestoreController.instance.addTransaction(accountTransaction5);
    FirestoreController.instance.addTransaction(accountTransaction6);
    FirestoreController.instance.addTransaction(accountTransaction7);
    FirestoreController.instance.addTransaction(accountTransaction8);
    FirestoreController.instance.addTransaction(accountTransaction9);
    FirestoreController.instance.addTransaction(accountTransaction10);

    Member readMember = Member.fromMap(
        (await FirestoreController.instance.getMember(memberId)).data()
            as Map<String, dynamic>,
        []);
    print(readMember.toMap());

    expect(member.toMap(), readMember.toMap());
    //FirestoreController.instance.getMember("123");

    BankCard readCard = BankCard.fromMap(
        (await FirestoreController.instance.getBankCard(cardNumber)).data()
            as Map<String, dynamic>);
    print(readCard.toMap());

    List<Account> readAccounts =
        (await FirestoreController.instance.getAccounts(memberId))
            .docs
            .map((e) => Account.fromMap(e.data()))
            .toList();
    for (var element in readAccounts) {
      print(element.toMap());
    }

    print("-----------------------all trasnactions------------------");
    List<AccountTransaction> readTransactions = (await FirestoreController
            .instance
            .getAllTransactions(account1.getNumber))
        .docs
        .map((e) => AccountTransaction.fromMap(e.data(), e.id))
        .toList();
    for (var element in readTransactions) {
      print(element.toMap());
    }

    print("-----------------------5 trasnactions------------------");
    List<AccountTransaction> readTransactions2 = (await FirestoreController
            .instance
            .getTransactionLimitBy(account1.getNumber, 3))
        .docs
        .map((e) => AccountTransaction.fromMap(e.data(), e.id))
        .toList();
    for (var element in readTransactions2) {
      print(element.toMap());
    }

    DateTime dateTime = DateTime(2022, 2, 400);
    print(dateTime.toString());

    Decimal decimal = Decimal.parse("0.2");
    Decimal decimal2 = Decimal.parse("0.3");
    Decimal decimal3 = decimal + decimal2;
    print(decimal);
    print(decimal3);
    print(decimal3.toString());
  });
}
