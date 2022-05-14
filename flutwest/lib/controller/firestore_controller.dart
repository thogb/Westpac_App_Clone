//import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_transaction.dart';
import 'package:flutwest/model/bank_card.dart';
import 'package:flutwest/model/member.dart';

class FirestoreController {
  static const String colMember = "member";
  static const String colCard = "card";
  static const String colTransaction = "transaction";

  static const String subColAccount = "account";

  late final FirebaseFirestore _firebaseFirestore;

  static final FirestoreController firestoreController =
      FirestoreController._internal();

  FirestoreController._internal() {}

  static FirestoreController get instance => firestoreController;

  void setFirebaseFireStore(FirebaseFirestore firebaseFirestore) {
    _firebaseFirestore = firebaseFirestore;
  }

  Future<void> addMember(String id, Member member) async {
    await _firebaseFirestore.collection(colMember).doc(id).set(member.toMap());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getMember(String id) async {
    return _firebaseFirestore.collection(colMember).doc(id).get();
  }

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
    await _firebaseFirestore
        .collection(colMember)
        .doc(memberId)
        .collection(subColAccount)
        .doc(account.accountID.number)
        .set(account.toMap());
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAccounts(
      String memberId) async {
    return _firebaseFirestore
        .collection(colMember)
        .doc(memberId)
        .collection(subColAccount)
        .get();
  }

  Future<void> addTransaction(AccountTransaction transaction) async {
    _firebaseFirestore.collection(colTransaction).add(transaction.toMap());
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
      String accountId, int limit,
      {String transactionType = AccountTransaction.allTypes,
      double amount = double.infinity}) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    Query<Map<String, dynamic>> query = _firebaseFirestore
        .collection(colTransaction)
        .where(AccountTransaction.fnAccountNumbers, arrayContains: accountId);

    if (amount != double.infinity) {
      query = query.where(AccountTransaction.fnAmount, isEqualTo: amount.abs());
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
      {String transactionType = AccountTransaction.allTypes,
      double amount = double.infinity}) {
    Query<Map<String, dynamic>> query = _firebaseFirestore
        .collection(colTransaction)
        .where(AccountTransaction.fnAccountNumbers, arrayContains: accountId);
    if (amount != double.infinity) {
      query = query.where(AccountTransaction.fnAmount, isEqualTo: amount.abs());
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
}
