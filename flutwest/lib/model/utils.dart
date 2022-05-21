import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/account_transaction.dart';
import 'package:flutwest/model/bank_card.dart';
import 'package:flutwest/model/member.dart';
import 'package:flutwest/model/vars.dart';

class Utils {
  Utils._();
  static void hideSysNavBarColour() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
        /*systemNavigationBarDividerColor: Color.fromARGB(1, 0, 1, 51),*/
        systemNavigationBarColor: Color.fromARGB(1, 0, 1, 51)));

    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [
      SystemUiOverlay.top,
    ]);
  }

  static void showSysNavBarColour() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white));

    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [
      SystemUiOverlay.top,
    ]);
  }

  static String getDateIntTwoSig(int val) {
    if (val < 10) {
      return "0$val";
    }

    return val.toString();
  }

  static String getDateTimeWDDMY(DateTime dateTime) {
    return "${Vars.days[dateTime.weekday]} ${dateTime.day} ${Vars.months[dateTime.month]} ${dateTime.year}";
  }

  static String getDateTimeWDDMYToday(DateTime dateTime) {
    return Vars.isSameDay(dateTime, DateTime.now())
        ? "Today"
        : getDateTimeWDDMY(dateTime);
  }

  static String formatDecimalMoneyUS(Decimal decimal) {
    return Vars.usFormatter.format(decimal.toDouble());
  }

  static void putData() async {
    AccountID accountID = AccountID(number: "111111", bsb: "111-111");
    Account account1 = Account(
        type: Account.typeChocie,
        bsb: accountID.getBsb,
        number: accountID.getNumber,
        balance: Decimal.parse("15000"),
        cardNumber: Vars.fakeCardNumber);
    Account account2 = Account(
        type: Account.typeBusiness,
        bsb: "111-111",
        number: "111112",
        balance: Decimal.parse("18000"),
        cardNumber: "");
    Account account3 = Account(
        type: Account.typeeSaver,
        bsb: "111-111",
        number: "111113",
        balance: Decimal.parse("11000"),
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
        balance: Decimal.parse("18000"),
        cardNumber: "");
    Account account5 = Account(
        type: Account.typeChocie,
        bsb: "111-111",
        number: "111115",
        balance: Decimal.parse("19000"),
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

    AccountTransaction accountTransaction1 = AccountTransaction.create(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2021, 4, 1),
        id: "",
        senderDescription: "account 1 send money to to account 2",
        receiverDescription: "account 2 received money from account 1",
        amount: Decimal.fromInt(100));
    AccountTransaction accountTransaction2 = AccountTransaction.create(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2021, 4, 2),
        id: "",
        senderDescription: "account 1 send money to to account 2",
        receiverDescription: "account 2 received money from account 1",
        amount: Decimal.fromInt(200));
    AccountTransaction accountTransaction3 = AccountTransaction.create(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2021, 4, 3),
        id: "",
        senderDescription: "account 1 send money to to account 2",
        receiverDescription: "account 2 received money from account 1",
        amount: Decimal.fromInt(300));
    AccountTransaction accountTransaction4 = AccountTransaction.create(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2021, 4, 4),
        id: "",
        senderDescription: "account 1 send money to to account 2",
        receiverDescription: "account 2 received money from account 1",
        amount: Decimal.fromInt(400));
    AccountTransaction accountTransaction5 = AccountTransaction.create(
        sender: account1.accountID,
        receiver: account4.accountID,
        dateTime: DateTime(2021, 4, 5),
        id: "",
        senderDescription: "account 1 send money to to account 2",
        receiverDescription: "account 2 received money from account 1",
        amount: Decimal.fromInt(500));

    AccountTransaction accountTransaction6 = AccountTransaction.create(
        sender: account4.accountID,
        receiver: account1.accountID,
        dateTime: DateTime(2021, 4, 5),
        id: "",
        senderDescription: "account 1 send money to to account 2",
        receiverDescription: "account 2 received money from account 1",
        amount: Decimal.fromInt(333));
    AccountTransaction accountTransaction7 = AccountTransaction.create(
        sender: account3.accountID,
        receiver: account1.accountID,
        dateTime: DateTime(2021, 4, 6),
        id: "",
        senderDescription: "account 1 send money to to account 2",
        receiverDescription: "account 2 received money from account 1",
        amount: Decimal.fromInt(1000));
    AccountTransaction accountTransaction8 = AccountTransaction.create(
        sender: account5.accountID,
        receiver: account1.accountID,
        dateTime: DateTime(2021, 4, 3),
        id: "",
        senderDescription: "account 1 send money to to account 2",
        receiverDescription: "account 2 received money from account 1",
        amount: Decimal.fromInt(700));
    AccountTransaction accountTransaction9 = AccountTransaction.create(
        sender: account5.accountID,
        receiver: account3.accountID,
        dateTime: DateTime(2021, 4, 3),
        id: "",
        senderDescription: "account 1 send money to to account 2",
        receiverDescription: "account 2 received money from account 1",
        amount: Decimal.fromInt(1700));
    AccountTransaction accountTransaction10 = AccountTransaction.create(
        sender: account3.accountID,
        receiver: account2.accountID,
        dateTime: DateTime(2021, 4, 3),
        id: "",
        senderDescription: "account 1 send money to to account 2",
        receiverDescription: "account 2 received money from account 1",
        amount: Decimal.fromInt(1300));

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

    List<String> methods = [
      "DEBIT CARD PURCHASE PAYPAL",
      "DEBIT CARD PURCHASE"
    ];
    List<String> payLocation = ["Bob", "John", "Dave", "Dylan"];
    List<String> atmLocation = [
      "CANNINGTON ATM",
      "RIVERTON ATM",
      "WILLETTON ATM",
      "CANNING VALE ATM",
      "PERTH ATM"
    ];
    List<String> location = [
      "CANNINGTON WOOLWORTHS",
      "STEAM GAMES",
      "KFC WILLETTON",
      "TAOBAO.COM Melbourne",
      "TERRYWHITE ROSTRATA",
      "MCDONALDS APP RIVERTON",
      "IGA ROSTRATA",
      "BIGW WILLETTON",
      "HUNGRY JACKS Myaree",
      "ebay xxxxxxx-xxxxx Sydney AUS",
      "EZI City Of Canning Welshpool Dc Aus",
      "Dominos Estore Willetton dominos.com AUS",
      "AMAZON MKTPLC AU SYDNEY SOUTH AUS"
    ];

    for (int i = 0; i < 40; i++) {
      int num = random.nextInt(5) + 1;

      int count = 0;
      Account sender;
      Account receiver;

      for (int j = 0; j < num; j++) {
        Decimal amount = Decimal.parse(((random.nextDouble() * 50)).toString())
            .round(scale: 4);
        count++;

        if (random.nextInt(100) > 50) {
          sender = account1;
          receiver = account3;
        } else {
          sender = account3;
          receiver = account1;
        }

        String description;
        String receiverDescription = "Test";

        int methodRand = random.nextInt(100);
        List<String> transactionTypes;

        if (methodRand <= 9) {
          description = "WITHDRAWAL ATM AT " +
              atmLocation[random.nextInt(atmLocation.length)];
          transactionTypes = [AccountTransaction.atmAndCash];
        } else if (methodRand >= 10 && methodRand <= 19) {
          description =
              "WITHDRAWAL-OSKA PAYMENT to ${receiver.getAccountName} transaction No: $count";
          receiverDescription =
              "DEPOSIT-OSKA PAYMENT to ${sender.getAccountName} transaction No: $count";
          transactionTypes = [
            AccountTransaction.credits,
            AccountTransaction.paymentsAndTransfers
          ];
        } else if (methodRand >= 20 && methodRand <= 29) {
          description =
              "WITHDRAWL MOBILE TFR ${receiver.getAccountName} transaction No: $count";
          receiverDescription =
              "DEPOSIT ONLINE TFR ${sender.getAccountName} transaction No: $count";
          transactionTypes = [
            AccountTransaction.credits,
            AccountTransaction.paymentsAndTransfers
          ];
        } else {
          sender = account1;
          receiver = account3;
          description = methods[random.nextInt(methods.length)] +
              " " +
              location[random.nextInt(location.length)];
          receiverDescription =
              "Merchant receiving money from account ${sender.accountID.getNumber}";
          transactionTypes = [
            AccountTransaction.debits,
            AccountTransaction.paymentsAndTransfers
          ];
        }

        await FirestoreController.instance
            .addTransaction(AccountTransaction.create(
                sender: sender.accountID,
                receiver: receiver.accountID,
                dateTime: DateTime(2022, 1, 1 + i, 0, 0, j),
                id: "",
                //description: "1 send to 2, the ${count}th",
                senderDescription: description,
                receiverDescription: receiverDescription,
                amount: amount,
                transactionTypes: transactionTypes));
        count++;

        /*
      if (i == 29 && j == num - 1) {
        for (int k = 0; k < 100; k++) {
          await FirestoreController.instance.addTransaction(AccountTransaction(
              sender: sender,
              receiver: receiver,
              dateTime: DateTime(2022, 1, 1 + i, 0, 0, k),
              id: "",
              description: "1 send to 2, the ${count}th",
              amount: amount));
          count++;
        }
      }*/
      }
    }
  }
}
