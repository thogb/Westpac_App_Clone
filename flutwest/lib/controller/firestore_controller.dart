//import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/account_transaction.dart';
import 'package:flutwest/model/bank_card.dart';
import 'package:flutwest/model/member.dart';
import 'package:flutwest/model/payee.dart';
import 'package:flutwest/model/vars.dart';

class FirestoreController {
  static const String colMember = "member";
  static const String colMemberColPayee = "payee";
  static const String colCard = "card";
  static const String colTransaction = "transaction";

  //static const String subColAccount = "account";

  static const String colAccount = "account";

  late final FirebaseFirestore _firebaseFirestore;
  late final List<VoidCallback> _onTransactionMadeObservers;

  static final FirestoreController firestoreController =
      FirestoreController._internal();

  FirestoreController._internal() : _onTransactionMadeObservers = [];

  static FirestoreController get instance => firestoreController;

  void addOnTransactionMadeObserver(VoidCallback callback) {
    _onTransactionMadeObservers.add(callback);
  }

  void removeOnTransactionMadeObserver(VoidCallback callback) {
    _onTransactionMadeObservers.remove(callback);
  }

  void notifyOnTransactionMadebservers() {
    for (VoidCallback element in _onTransactionMadeObservers) {
      element();
    }
  }

  void setFirebaseFireStore(FirebaseFirestore firebaseFirestore) {
    _firebaseFirestore = firebaseFirestore;
  }

  Future<void> enablePersistentData(bool enable) async {
    _firebaseFirestore.settings = Settings(persistenceEnabled: enable);
  }

  Future<void> addMember(String id, Member member) async {
    await _firebaseFirestore.collection(colMember).doc(id).set(member.toMap());
  }

  // Member
  Future<DocumentSnapshot<Map<String, dynamic>>> getMember(String id) async {
    await Future.delayed(Duration(seconds: 2));
    return _firebaseFirestore.collection(colMember).doc(id).get();
  }

  Future<void> updateMemberRecentPayee(String id, DateTime dateTime) async {
    await _firebaseFirestore
        .collection(colMember)
        .doc(id)
        .update({Member.fnRecentPayeeChange: dateTime.millisecondsSinceEpoch});
  }

  // Member payees
  Future<String> addPayee(
      String memberId, Payee payee, DateTime addTime) async {
    var ref = await _firebaseFirestore
        .collection(colMember)
        .doc(memberId)
        .collection(colMemberColPayee)
        .add(payee.toMap());
    await updateMemberRecentPayee(memberId, addTime);

    return ref.id;
  }

  Future<List<Payee>> getPayees(String memberId) async {
    var snapshot = await _firebaseFirestore
        .collection(colMember)
        .doc(memberId)
        .collection(colMemberColPayee)
        .get();
    var docs = snapshot.docs;

    return List.generate(docs.length,
        (index) => Payee.fromMap(docs[index].data(), docs[index].id));
  }

  Future<void> deletePayee(
      String memberId, String docId, DateTime delDate) async {
    await _firebaseFirestore
        .collection(colMember)
        .doc(memberId)
        .collection(colMemberColPayee)
        .doc(docId)
        .delete();
    await updateMemberRecentPayee(memberId, delDate);
  }

  // Bank Card
  Future<void> addBankCard(String cardNumber, BankCard bankCard) async {
    await _firebaseFirestore
        .collection(colCard)
        .doc(cardNumber)
        .set(bankCard.toMap());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getBankCard(
      String cardNumber) async {
    await Future.delayed(Duration(milliseconds: 3000));
    return _firebaseFirestore.collection(colCard).doc(cardNumber).get();
  }

  Future<void> addAccount(String memberId, Account account) async {
    /*await _firebaseFirestore
        .collection(colMember)
        .doc(memberId)
        .collection(subColAccount)
        .doc(account.accountID.number)
        .set(account.toMap());*/
    await _firebaseFirestore.collection(colAccount).add(account.toMap());
  }

  // Function #Accounts

  Future<QuerySnapshot<Map<String, dynamic>>> getAccounts(
      String memberId) async {
    /*return _firebaseFirestore
        .collection(colMember)
        .doc(memberId)
        .collection(subColAccount)
        .get();*/
    return _firebaseFirestore
        .collection(colAccount)
        .where(Account.fnMemberID, isEqualTo: memberId)
        .get();
  }

  /// Some random made up accounts, not updated to cloud firestore.
  /// So not found return null is one random account for paying
  /// Used by [addPaymentTransaction], because the person being paid is made up
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getAccountByNumber(
      {required String accountNumber}) async {
    var docs = (await _firebaseFirestore
            .collection(colAccount)
            .where(Account.fnAccountNumber, isEqualTo: accountNumber)
            .limit(1)
            .get())
        .docs;
    return docs.isNotEmpty ? docs[0] : null;
  }

  /// Should never return null, this is used by [addTransferTransaction].
  /// The payee and payer are both accounts of a user. Both account are read from
  /// the cloud firestore.
  Future<QueryDocumentSnapshot<Map<String, dynamic>>> getAccountByNumberNotNull(
      {required String accountNumber}) async {
    var docs = (await _firebaseFirestore
            .collection(colAccount)
            .where(Account.fnAccountNumber, isEqualTo: accountNumber)
            .limit(1)
            .get())
        .docs;
    return docs[0];
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getAccountByDocId(
      {required String docID}) {
    return _firebaseFirestore.collection(colAccount).doc(docID).get();
  }

  Future<void> updateAccountBalance(
      {required String docId, required Decimal newBalance}) async {
    await _firebaseFirestore
        .collection(colAccount)
        .doc(docId)
        .update({Account.fnBalance: newBalance.toString()});
  }

  // Function #Transactions

  Future<void> addTransaction(AccountTransaction transaction) async {
    await _firebaseFirestore
        .collection(colTransaction)
        .add(transaction.toMap());
  }

  Future<void> addTransferTransaction(
      {required Account senderAccount,
      required Account receiverAccount,
      required String transferDescription,
      required Decimal amount,
      DateTime? dateTime}) async {
    /*Account senderAccount = Account.fromMap(
        (await getAccountByDocId(docID: senderDocId)).data()!, senderDocId);*/
    /*QueryDocumentSnapshot<Map<String, dynamic>> receiverDoc =
        await getAccountByNumberNotNull(accountNumber: receiver.getNumber);
    Account receiverAccount =
        Account.fromMap(receiverDoc.data(), receiverDoc.id);*/
    /*Account receiverAccount = Account.fromMap(
        (await getAccountByDocId(docID: receiverDocId)).data()!, receiverDocId);*/

    AccountTransaction transaction = AccountTransaction.create(
        sender: senderAccount.accountID,
        receiver: receiverAccount.accountID,
        dateTime: dateTime ?? DateTime.now(),
        id: "",
        amount: amount,
        senderDescription:
            "WITHDRAWL MOBILE ****** TFR ${receiverAccount.getAccountName} $transferDescription",
        receiverDescription: "DEPOSIT ONLINE ****** TFR ${senderAccount.getAccountName} $transferDescription",
        transactionTypes: [
          AccountTransaction.paymentsAndTransfers,
          AccountTransaction.credits
        ]);
    Decimal senderNewBal = senderAccount.getBalance - amount;
    Decimal receiverNewBal = receiverAccount.getBalance + amount;
    await Future.wait([
      addTransaction(transaction),
      updateAccountBalance(
          newBalance: senderNewBal, docId: senderAccount.docID!),
      updateAccountBalance(
          newBalance: receiverNewBal, docId: receiverAccount.docID!)
    ]);

    senderAccount.setBalance = senderNewBal;
    receiverAccount.setBalance = receiverNewBal;

    notifyOnTransactionMadebservers();
  }

  Future<void> addPaymentTransaction(
      {required Account senderAccount,
      required AccountID receiver,
      required String receiverName,
      required String senderDescription,
      required String receiverDescription,
      required Decimal amount,
      DateTime? dateTime}) async {
    /* Account senderAccount = Account.fromMap(
        (await getAccountByDocId(docID: senderDocId)).data()!, senderDocId);*/
    QueryDocumentSnapshot<Map<String, dynamic>>? receiverDoc =
        await getAccountByNumber(accountNumber: receiver.getNumber);
    Account? receiverAccount = receiverDoc != null
        ? Account.fromMap(receiverDoc.data(), receiverDoc.id)
        : null;
    AccountTransaction transaction = AccountTransaction.create(
        sender: senderAccount.accountID,
        receiver: receiverAccount != null
            ? receiverAccount.accountID
            : Vars.invalidAccountID,
        dateTime: dateTime ?? DateTime.now(),
        id: "",
        amount: amount,
        senderDescription:
            "WITHDRAWL-OSKO PAYMENT ****** $receiverName $senderDescription",
        receiverDescription:
            "DEPOSIT-OSKO PAYMENT ****** ${senderAccount.accountID.getNumber} $receiverDescription",
        transactionTypes: [
          AccountTransaction.paymentsAndTransfers,
          AccountTransaction.credits
        ]);
    Decimal senderNewBal = senderAccount.getBalance - amount;
    await Future.wait([
      addTransaction(transaction),
      updateAccountBalance(
          newBalance: senderNewBal, docId: senderAccount.docID!),
    ]);

    senderAccount.setBalance = senderNewBal;

    if (receiverAccount != null) {
      Decimal receiverNewBal = receiverAccount.getBalance + amount;
      await updateAccountBalance(
          newBalance: receiverNewBal, docId: receiverAccount.docID!);
    }

    notifyOnTransactionMadebservers();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllTransactions(
      String accountId) {
    return _firebaseFirestore
        .collection(colTransaction)
        .where(AccountTransaction.fnAccountNumbers, arrayContains: accountId)
        .orderBy(AccountTransaction.fnDateTime, descending: true)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTransactionLimitBy(
      String accountNumber, int limit,
      {String transactionType = AccountTransaction.allTypes,
      String? description,
      double? amount}) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    Query<Map<String, dynamic>> query = _firebaseFirestore
        .collection(colTransaction)
        .where(AccountTransaction.fnAccountNumbers,
            arrayContains: accountNumber);

    if (amount != null) {
      query = query.where(AccountTransaction.fnDoubleTypeAmount,
          isGreaterThan: (amount - 0.050));
      query = query.where(AccountTransaction.fnDoubleTypeAmount,
          isLessThan: (amount + 0.050));
    }

    if (description != null && description.length > 2) {
      query = query.where(
        "${AccountTransaction.fnDescription}.$accountNumber",
        isGreaterThan: description,
      );
      query = query.where("${AccountTransaction.fnDescription}.$accountNumber",
          isLessThan: description + 'z');
    }

    if (transactionType != AccountTransaction.allTypes) {
      query = query.where(AccountTransaction.fnTransactionTtypes,
          arrayContains: transactionType);
    }

    return query
        .orderBy(AccountTransaction.fnDateTime, descending: true)
        .limit(limit)
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactionLimitByStream(
      String accountId, int limit,
      {String transactionType = AccountTransaction.allTypes, String? amount}) {
    Query<Map<String, dynamic>> query = _firebaseFirestore
        .collection(colTransaction)
        .where(AccountTransaction.fnAccountNumbers, arrayContains: accountId);
    if (amount != null && amount.length >= 2) {
      query = query.where(AccountTransaction.fnAmount,
          isGreaterThanOrEqualTo: amount, isLessThan: amount + 'Z');
    }

    if (transactionType != AccountTransaction.allTypes) {
      query = query.where(AccountTransaction.fnTransactionTtypes,
          arrayContains: transactionType);
    }

    return query
        .orderBy(AccountTransaction.fnDateTime, descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> updateBankCardLockStatus(
      String cardNumber, bool lockStatus) async {
    await Future.delayed(Duration(seconds: 2));
    await _firebaseFirestore
        .collection(colCard)
        .doc(cardNumber)
        .update({BankCard.fnLocked: lockStatus});
  }

  /*
  Future<void> updateAccountBalance(
      {String? docID,
      required String accountNumber,
      required Decimal newBalance}) async {
    try {
      if (docID != null) {
        await _firebaseFirestore
            .collection(colAccount)
            .doc(docID)
            .update({Account.fnBalance: newBalance.toString()});
      } else {
        // Retrieved from https://stackoverflow.com/questions/70569124/flutter-firestore-update-where
        // 21/04/2022
        final accountRef = await _firebaseFirestore
            .collection(colAccount)
            .where(Account.fnAccountNumber, isEqualTo: accountNumber)
            .limit(1)
            .get()
            .then((QuerySnapshot snapshot) => snapshot.docs[0].reference);
        WriteBatch batch = _firebaseFirestore.batch();
        batch.update(accountRef, {Account.fnBalance: newBalance.toString()});
        await batch.commit();
      }
    } catch (e) {
      print(e);
    }
  }*/
}
