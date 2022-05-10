import 'dart:math';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/controller/sqlite_controller.dart';
import 'package:flutwest/cust_widget/west_logo.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/account_transaction.dart';
import 'package:flutwest/model/bank_card.dart';
import 'package:flutwest/model/member.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/cards_page.dart';
import 'package:flutwest/ui_page/guest_page.dart';
import 'package:flutwest/ui_page/home_page.dart';

void main() async {
  Utils.hideSysNavBarColour();

  SQLiteController.instance.loadDB();

  // WidgetsFlutterBinding.ensureInitialized();
  FirestoreController.instance.setFirebaseFireStore(FakeFirebaseFirestore());
  putData();

  runApp(const MyApp());
}

void putData() async {
  AccountID accountID = AccountID(number: "111111", bsb: "111-111");
  Account account1 = Account(
      type: Account.typeChocie,
      bsb: accountID.getBsb,
      number: accountID.getNumber,
      balance: 15000,
      cardNumber: Vars.fakeCardNumber);
  Account account2 = Account(
      type: Account.typeBusiness,
      bsb: "111-111",
      number: "111112",
      balance: 18000,
      cardNumber: "");
  Account account3 = Account(
      type: Account.typeeSaver,
      bsb: "111-111",
      number: "111113",
      balance: 11000,
      cardNumber: "");
  Member member = Member(
      firstName: "Tao",
      middleName: "",
      surName: "Hu",
      id: Vars.fakeMemberID,
      cardNumber: Vars.fakeCardNumber,
      accounts: [account1, account2, account3]);
  Account account4 = Account(
      type: Account.typeChocie,
      bsb: "111-111",
      number: "111114",
      balance: 18000,
      cardNumber: "");
  Account account5 = Account(
      type: Account.typeChocie,
      bsb: "111-111",
      number: "111115",
      balance: 19000,
      cardNumber: "");

  BankCard bankCard = BankCard(
      number: Vars.fakeCardNumber,
      name: "Tao Hu",
      expiry: DateTime(2023, 5, 1),
      cvc: "800",
      dynamicCVC: "999",
      dynamicCVCExpiry: DateTime(2023, 4, 1),
      locked: false,
      accountBSB: accountID.getBsb,
      accountNumber: accountID.getNumber);

  AccountTransaction accountTransaction1 = AccountTransaction(
      sender: account1.accountID,
      receiver: account4.accountID,
      dateTime: DateTime(2021, 4, 1),
      id: "",
      description: "account 1 to account 2",
      amount: 100);
  AccountTransaction accountTransaction2 = AccountTransaction(
      sender: account1.accountID,
      receiver: account4.accountID,
      dateTime: DateTime(2021, 4, 2),
      id: "",
      description: "account 1 to account 2",
      amount: 200);
  AccountTransaction accountTransaction3 = AccountTransaction(
      sender: account1.accountID,
      receiver: account4.accountID,
      dateTime: DateTime(2021, 4, 3),
      id: "",
      description: "account 1 to account 2",
      amount: 300);
  AccountTransaction accountTransaction4 = AccountTransaction(
      sender: account1.accountID,
      receiver: account4.accountID,
      dateTime: DateTime(2021, 4, 4),
      id: "",
      description: "account 1 to account 2",
      amount: 400);
  AccountTransaction accountTransaction5 = AccountTransaction(
      sender: account1.accountID,
      receiver: account4.accountID,
      dateTime: DateTime(2021, 4, 5),
      id: "",
      description: "account 1 to account 2",
      amount: 500);

  AccountTransaction accountTransaction6 = AccountTransaction(
      sender: account4.accountID,
      receiver: account1.accountID,
      dateTime: DateTime(2021, 4, 5),
      id: "",
      description: "account 1 to account 2",
      amount: 333);
  AccountTransaction accountTransaction7 = AccountTransaction(
      sender: account3.accountID,
      receiver: account1.accountID,
      dateTime: DateTime(2021, 4, 6),
      id: "",
      description: "account 1 to account 2",
      amount: 1000);
  AccountTransaction accountTransaction8 = AccountTransaction(
      sender: account5.accountID,
      receiver: account1.accountID,
      dateTime: DateTime(2021, 4, 3),
      id: "",
      description: "account 1 to account 2",
      amount: 700);
  AccountTransaction accountTransaction9 = AccountTransaction(
      sender: account5.accountID,
      receiver: account3.accountID,
      dateTime: DateTime(2021, 4, 3),
      id: "",
      description: "account 1 to account 2",
      amount: 1700);
  AccountTransaction accountTransaction10 = AccountTransaction(
      sender: account3.accountID,
      receiver: account2.accountID,
      dateTime: DateTime(2021, 4, 3),
      id: "",
      description: "account 1 to account 2",
      amount: 1300);

  FirestoreController.instance.addAccount(Vars.fakeMemberID, account1);
  FirestoreController.instance.addAccount(Vars.fakeMemberID, account2);
  FirestoreController.instance.addAccount(Vars.fakeMemberID, account3);
  FirestoreController.instance.addMember(Vars.fakeMemberID, member);
  FirestoreController.instance.addBankCard(Vars.fakeCardNumber, bankCard);
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

  Random random = Random();

  for (int i = 0; i < 30; i++) {
    int num = random.nextInt(4) + 1;

    int count = 0;
    AccountID sender;
    AccountID receiver;

    for (int j = 0; j < num; j++) {
      double amount = (random.nextInt(50) + 1) * 1.0;
      count++;

      if (random.nextInt(100) > 50) {
        sender = account1.accountID;
        receiver = account3.accountID;
      } else {
        sender = account3.accountID;
        receiver = account1.accountID;
      }

      await FirestoreController.instance.addTransaction(AccountTransaction(
          sender: sender,
          receiver: receiver,
          dateTime: DateTime(2022, 1, 1 + i),
          id: "",
          description:
              "account 1 send to account 2, the ${count}th transaction",
          amount: amount));
      count++;

      if (i == 29 && j == num - 1) {
        for (int k = 0; k < 20; k++) {
          await FirestoreController.instance.addTransaction(AccountTransaction(
              sender: sender,
              receiver: receiver,
              dateTime: DateTime(2022, 1, 1 + i),
              id: "",
              description:
                  "account 1 send to account 2, the ${count}th transaction",
              amount: amount));
          count++;
        }
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            appBarTheme: AppBarTheme(
                foregroundColor: Colors.black,
                iconTheme: IconThemeData(color: Colors.red[900]),
                backgroundColor: Colors.grey[50]),
            primarySwatch: Colors.blue,
            highlightColor: Colors.grey[200],
            splashFactory: NoSplash.splashFactory),
        //home: const HomePage(),
        home: const GuestPage());
    //home: const HomePage());
    /*
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: const WestLogo(
              width: 200.0,
            ),
          ),
        ));*/
  }
}
