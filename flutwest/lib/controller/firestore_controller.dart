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
  late final FirebaseFirestore _firebaseFirestore;

  late final ColMember colMember;
  late final ColAccount colAccount;
  late final ColBankCard colBankCard;
  late final ColTransaction colTransaction;

  static final FirestoreController _firestoreController =
      FirestoreController._internal();

  FirestoreController._internal();

  static FirestoreController get instance => _firestoreController;

  FirebaseFirestore get fireBaseFireStore => _firebaseFirestore;

  void setFirebaseFireStore(FirebaseFirestore firebaseFirestore) {
    _firebaseFirestore = firebaseFirestore;
    colBankCard = ColBankCard(
        firestoreController: _firestoreController,
        firebaseFirestore: fireBaseFireStore);
    colAccount = ColAccount(
        firestoreController: _firestoreController,
        firebaseFirestore: fireBaseFireStore);
    colTransaction = ColTransaction(
        firestoreController: _firestoreController,
        firebaseFirestore: fireBaseFireStore);
    colMember = ColMember(
        firestoreController: _firestoreController,
        firebaseFirestore: fireBaseFireStore);
  }

  Future<void> enablePersistentData(bool enable) async {
    _firebaseFirestore.settings = Settings(persistenceEnabled: enable);
  }
}

class ColMember {
  static const String collectionName = "member";
  late final FirestoreController _firestoreController;
  late final FirebaseFirestore _firebaseFirestore;
  final ColPayee colPayee;

  ColMember({
    required FirestoreController firestoreController,
    required FirebaseFirestore firebaseFirestore,
  })  : _firestoreController = firestoreController,
        _firebaseFirestore = firebaseFirestore,
        colPayee = ColPayee(
            firestoreController: firestoreController,
            firebaseFirestore: firebaseFirestore);

  Future<void> addMember(String id, Member member) async {
    await _firebaseFirestore
        .collection(collectionName)
        .doc(id)
        .set(member.toMap());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getByDocId(String id) async {
    await Future.delayed(Duration(seconds: 2));
    return _firebaseFirestore.collection(collectionName).doc(id).get();
  }

  Future<void> updateRecentPayee(String id, DateTime dateTime) async {
    await _firebaseFirestore
        .collection(collectionName)
        .doc(id)
        .update({Member.fnRecentPayeeChange: dateTime.millisecondsSinceEpoch});
  }
}

class ColPayee {
  static const String collectionName = "payee";
  late final FirestoreController _firestoreController;
  late final FirebaseFirestore _firebaseFirestore;

  ColPayee(
      {required FirestoreController firestoreController,
      required FirebaseFirestore firebaseFirestore})
      : _firestoreController = firestoreController,
        _firebaseFirestore = firebaseFirestore;

  Future<String> addPayee(
      String memberId, Payee payee, DateTime addTime) async {
    var ref = await _firebaseFirestore
        .collection(ColMember.collectionName)
        .doc(memberId)
        .collection(collectionName)
        .add(payee.toMap());
    await _firestoreController.colMember.updateRecentPayee(memberId, addTime);

    return ref.id;
  }

  Future<List<Payee>> getAllByMemberId(String memberId) async {
    var snapshot = await _firebaseFirestore
        .collection(ColMember.collectionName)
        .doc(memberId)
        .collection(collectionName)
        .get();
    var docs = snapshot.docs;

    return List.generate(docs.length,
        (index) => Payee.fromMap(docs[index].data(), docs[index].id));
  }

  Future<void> deletePayee(
      String memberId, String docId, DateTime delDate) async {
    await _firebaseFirestore
        .collection(ColMember.collectionName)
        .doc(memberId)
        .collection(collectionName)
        .doc(docId)
        .delete();
    await _firestoreController.colMember.updateRecentPayee(memberId, delDate);
  }

  Future<void> updateLastPayDate(
      String memberId, String payeeDocId, DateTime lastPayDate) async {
    await _firebaseFirestore
        .collection(ColMember.collectionName)
        .doc(memberId)
        .collection(collectionName)
        .doc(payeeDocId)
        .update({Payee.fnLastPayDate: lastPayDate});
    await _firestoreController.colMember
        .updateRecentPayee(memberId, lastPayDate);
  }
}

class ColAccount {
  static const String collectionName = "account";
  late final FirestoreController _firestoreController;
  late final FirebaseFirestore _firebaseFirestore;

  ColAccount(
      {required FirestoreController firestoreController,
      required FirebaseFirestore firebaseFirestore})
      : _firestoreController = firestoreController,
        _firebaseFirestore = firebaseFirestore;

  Future<void> addAccount(String memberId, Account account) async {
    await _firebaseFirestore.collection(collectionName).add(account.toMap());
  }

  // Function #Accounts

  Future<QuerySnapshot<Map<String, dynamic>>> getAllByMemberId(
      String memberId) async {
    return _firebaseFirestore
        .collection(collectionName)
        .where(Account.fnMemberID, isEqualTo: memberId)
        .get();
  }

  /// Some random made up accounts, not updated to cloud firestore.
  /// So not found return null is one random account for paying
  /// Used by [addPaymentTransaction], because the person being paid is made up
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getByAccountNumber(
      {required String accountNumber}) async {
    var docs = (await _firebaseFirestore
            .collection(collectionName)
            .where(Account.fnAccountNumber, isEqualTo: accountNumber)
            .limit(1)
            .get())
        .docs;
    return docs.isNotEmpty ? docs[0] : null;
  }

  /// Should never return null, this is used by [addTransferTransaction].
  /// The payee and payer are both accounts of a user. Both account are read from
  /// the cloud firestore.
  Future<QueryDocumentSnapshot<Map<String, dynamic>>> getByAccountNumberNotNull(
      {required String accountNumber}) async {
    var docs = (await _firebaseFirestore
            .collection(collectionName)
            .where(Account.fnAccountNumber, isEqualTo: accountNumber)
            .limit(1)
            .get())
        .docs;
    return docs[0];
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getByDocId(
      {required String docID}) {
    return _firebaseFirestore.collection(collectionName).doc(docID).get();
  }

  Future<void> updateBalance(
      {required String docId, required Decimal newBalance}) async {
    await _firebaseFirestore
        .collection(collectionName)
        .doc(docId)
        .update({Account.fnBalance: newBalance.toString()});
  }
}

class ColTransaction {
  static const String collectionName = "transaction";
  late final FirestoreController _firestoreController;
  late final FirebaseFirestore _firebaseFirestore;
  late final List<VoidCallback> _onTransactionMadeObservers;

  ColTransaction(
      {required FirestoreController firestoreController,
      required FirebaseFirestore firebaseFirestore})
      : _firestoreController = firestoreController,
        _firebaseFirestore = firebaseFirestore,
        _onTransactionMadeObservers = [];

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

  Future<void> addTransferTransaction(
      {required Account senderAccount,
      required Account receiverAccount,
      required String transferDescription,
      required Decimal amount,
      DateTime? dateTime}) async {
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
      _firestoreController.colAccount
          .updateBalance(newBalance: senderNewBal, docId: senderAccount.docID!),
      _firestoreController.colAccount.updateBalance(
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
    QueryDocumentSnapshot<Map<String, dynamic>>? receiverDoc =
        await _firestoreController.colAccount
            .getByAccountNumber(accountNumber: receiver.getNumber);
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
      _firestoreController.colAccount
          .updateBalance(newBalance: senderNewBal, docId: senderAccount.docID!),
    ]);

    senderAccount.setBalance = senderNewBal;

    if (receiverAccount != null) {
      Decimal receiverNewBal = receiverAccount.getBalance + amount;
      await _firestoreController.colAccount.updateBalance(
          newBalance: receiverNewBal, docId: receiverAccount.docID!);
    }

    notifyOnTransactionMadebservers();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStreamLimitBy(
      String accountId, int limit,
      {String transactionType = AccountTransaction.allTypes, String? amount}) {
    Query<Map<String, dynamic>> query = _firebaseFirestore
        .collection(collectionName)
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

  Future<void> addTransaction(AccountTransaction transaction) async {
    await _firebaseFirestore
        .collection(collectionName)
        .add(transaction.toMap());
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAll(String accountId) {
    return _firebaseFirestore
        .collection(collectionName)
        .where(AccountTransaction.fnAccountNumbers, arrayContains: accountId)
        .orderBy(AccountTransaction.fnDateTime, descending: true)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllLimitBy(
      String accountNumber, int limit,
      {String transactionType = AccountTransaction.allTypes,
      String? description,
      double? amount}) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    Query<Map<String, dynamic>> query = _firebaseFirestore
        .collection(collectionName)
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
}

class ColBankCard {
  static const String collectionName = "bankCard";
  late final FirestoreController _firestoreController;
  late final FirebaseFirestore _firebaseFirestore;

  ColBankCard(
      {required FirestoreController firestoreController,
      required FirebaseFirestore firebaseFirestore})
      : _firestoreController = firestoreController,
        _firebaseFirestore = firebaseFirestore;

  Future<void> updateLockStatus(String cardNumber, bool lockStatus) async {
    await Future.delayed(Duration(seconds: 2));
    await _firebaseFirestore
        .collection(collectionName)
        .doc(cardNumber)
        .update({BankCard.fnLocked: lockStatus});
  }

  Future<void> addBankCard(String cardNumber, BankCard bankCard) async {
    await _firebaseFirestore
        .collection(collectionName)
        .doc(cardNumber)
        .set(bankCard.toMap());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getByCardNumber(
      String cardNumber) async {
    await Future.delayed(Duration(milliseconds: 3000));
    return _firebaseFirestore.collection(collectionName).doc(cardNumber).get();
  }
}
