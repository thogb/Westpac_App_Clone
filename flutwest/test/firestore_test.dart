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
import 'package:flutwest/model/vars.dart';

void main() {
  test("fake firestore test", () async {
    String memberId = Vars.fakeMemberID;
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
        balance: Decimal.parse("4000"),
        cardNumber: cardNumber,
        memberID: Vars.fakeMemberID);
    Account account2 = Account(
        type: Account.typeChocie,
        bsb: "111-111",
        number: "111112",
        balance: Decimal.parse("8000"),
        cardNumber: "",
        memberID: Vars.fakeMemberID);
    Account account3 = Account(
        type: Account.typeChocie,
        bsb: "111-111",
        number: "111113",
        balance: Decimal.parse("1000"),
        cardNumber: "",
        memberID: Vars.fakeMemberID);

    Account account4 = Account(
        type: Account.typeChocie,
        bsb: "111-111",
        number: "111114",
        balance: Decimal.parse("8000"),
        cardNumber: "",
        memberID: "123123123");
    Account account5 = Account(
        type: Account.typeChocie,
        bsb: "111-111",
        number: "111115",
        balance: Decimal.parse("9000"),
        cardNumber: "",
        memberID: "123123123");

    Member member = Member(
        firstName: "Tao",
        middleName: "",
        surName: "Hu",
        id: memberId,
        cardNumber: cardNumber,
        accounts: [account1, account2, account3]);

    AccountTransaction accountTransaction1 = AccountTransaction.create(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2022, 4, 1),
        id: "",
        senderDescription: "account 1 to account 2",
        receiverDescription: "account 2 to account 1",
        amount: Decimal.fromInt(100));
    AccountTransaction accountTransaction2 = AccountTransaction.create(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2022, 4, 2),
        id: "",
        senderDescription: "account 1 to account 2",
        receiverDescription: "account 2 to account 1",
        amount: Decimal.fromInt(200));
    AccountTransaction accountTransaction3 = AccountTransaction.create(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2022, 4, 3),
        id: "",
        senderDescription: "account 1 to account 2",
        receiverDescription: "account 2 to account 1",
        amount: Decimal.fromInt(300));
    AccountTransaction accountTransaction4 = AccountTransaction.create(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2022, 4, 4),
        id: "",
        senderDescription: "account 1 to account 2",
        receiverDescription: "account 2 to account 1",
        amount: Decimal.fromInt(400));
    AccountTransaction accountTransaction5 = AccountTransaction.create(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2022, 4, 5),
        id: "",
        senderDescription: "account 1 to account 2",
        receiverDescription: "account 2 to account 1",
        amount: Decimal.fromInt(500));

    AccountTransaction accountTransaction6 = AccountTransaction.create(
        sender: account4.accountID,
        receiver: account1.accountID,
        dateTime: DateTime(2022, 4, 5),
        id: "",
        senderDescription: "account 1 to account 2",
        receiverDescription: "account 2 to account 1",
        amount: Decimal.fromInt(333));
    AccountTransaction accountTransaction7 = AccountTransaction.create(
        sender: account3.accountID,
        receiver: account1.accountID,
        dateTime: DateTime(2022, 4, 6),
        id: "",
        senderDescription: "account 1 to account 2",
        receiverDescription: "account 2 to account 1",
        amount: Decimal.fromInt(1000));
    AccountTransaction accountTransaction8 = AccountTransaction.create(
        sender: account5.accountID,
        receiver: account1.accountID,
        dateTime: DateTime(2022, 4, 3),
        id: "",
        senderDescription: "account 1 to account 2",
        receiverDescription: "account 2 to account 1",
        amount: Decimal.fromInt(700));
    AccountTransaction accountTransaction9 = AccountTransaction.create(
        sender: account5.accountID,
        receiver: account3.accountID,
        dateTime: DateTime(2022, 4, 3),
        id: "",
        senderDescription: "account 1 to account 2",
        receiverDescription: "account 2 to account 1",
        amount: Decimal.fromInt(1700));
    AccountTransaction accountTransaction10 = AccountTransaction.create(
        sender: account3.accountID,
        receiver: account2.accountID,
        dateTime: DateTime(2022, 4, 3),
        id: "",
        senderDescription: "account 1 to account 2",
        receiverDescription: "account 2 to account 1",
        amount: Decimal.fromInt(1300));

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
            .map((e) => Account.fromMap(e.data(), e.id))
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

    decimal = Decimal.parse("54.333");
    decimal2 = Decimal.parse("300.67891");

    print(decimal + decimal2);
    decimal = decimal + decimal2;
    print(decimal.round(scale: 2));
    decimal = -decimal;
    print(decimal);
    print(Decimal.parse("0"));

    readAccounts = (await FirestoreController.instance.getAccounts(memberId))
        .docs
        .map((e) => Account.fromMap(e.data(), e.id))
        .toList();

    print(
        "+++++++++++++++++++++++ Transaction test ++++++++++++++++++++++++++");
    print(
        "Before send 200.30 account 1 to acccount 2\nBalance: account 1: ${readAccounts[0].getBalance}, account 2: ${readAccounts[1].balance}");
    await FirestoreController.instance.addTransferTransaction(
        sender: account1,
        receiver: account2,
        transferDescription: "teasdasdasd",
        amount: Decimal.parse("200.30"));
    readAccounts = (await FirestoreController.instance.getAccounts(memberId))
        .docs
        .map((e) => Account.fromMap(e.data(), e.id))
        .toList();
    print(
        "After send 200.30, Account 1: ${readAccounts[0].getBalance}, account 2: ${readAccounts[1].balance}");
    await FirestoreController.instance.addPaymentTransaction(
        sender: account1,
        receiver: account2,
        receiverName: "Bob",
        senderDescription: "teasdasdaasdasdsadsd",
        receiverDescription: "asdasdashdasdas",
        amount: Decimal.parse("1000.57"));
    readAccounts = (await FirestoreController.instance.getAccounts(memberId))
        .docs
        .map((e) => Account.fromMap(e.data(), e.id))
        .toList();
    print(
        "After send another 1000.57 from accoutn 1 to acount 2 using addPaymentTransaction\nAccount 1: ${readAccounts[0].getBalance}, account 2: ${readAccounts[1].balance}");
  });
}
