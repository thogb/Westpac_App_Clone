import 'package:flutter/cupertino.dart';
import 'package:flutwest/model/payee.dart';
import 'package:flutwest/model/vars.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/account_id.dart';

class AccountOrder {
  static const String tableName = "accounts";
  static const String order = "order_val";
  static const String number = "number";
  static const String bsb = "bsb";
  static const String hidden = "hidden";
  static const String memberID = "member_id";

  AccountOrder._() {}
}

class TablePayee {
  TablePayee._();

  static const String tableName = "payee";
  static const String docId = "doc_id";
  static const String memberId = "member_id";
  static const String accountName = "account_name";
  static const String nickName = "nick_name";
  static const String accountNumber = "account_number";
  static const String accountBsb = "account_bsb";
  static const String lastPayDate = "last_pay_date";
}

class TableMember {
  TableMember._();

  static const String tableName = "member_info";
  static const String memberId = "member_id";
  static const String lastLogin = "last_login";
  static const String recentPayee = "recent_payee";
}

class SQLiteController {
  static const int invalidDateIntValue = -1;
  static const String invalidString = "";
  static const String dbName = "flutWest.db";
  static const String testID = Vars.fakeMemberID;

  //static SQLiteController? _controller;
  static final SQLiteController _controller = SQLiteController._internal();

  late final Database dataBase;

  SQLiteController._internal() {}

  static SQLiteController get instance => _controller;

  factory SQLiteController() {
    return _controller;
  }

  /*
  static SQLiteController getInstance() {
    /*if (_controller == null) {
      _controller = SQLiteController._();
    }*/
    _controller ??= SQLiteController._();
    //_controller = SQLiteController._();

    return _controller!;
  }*/

  Future<void> loadDB() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);

    dataBase = await openDatabase(path, onCreate: ((db, version) {
      var batch = db.batch();
      batch.execute(
          'CREATE TABLE ${AccountOrder.tableName}(${AccountOrder.memberID} TEXT NOT NULL, ${AccountOrder.order} INTEGER NOT NULL, ${AccountOrder.number} TEXT NOT NULL, ${AccountOrder.bsb} TEXT NOT NULL,  ${AccountOrder.hidden} INTEGER, PRIMARY KEY (${AccountOrder.memberID}, ${AccountOrder.order}))');
      batch.execute(
          "CREATE TABLE ${TablePayee.tableName}(${TablePayee.memberId} TEXT NOT NULL, ${TablePayee.docId} TEXT NOT NULL, ${TablePayee.accountNumber} TEXT NOT NULL, ${TablePayee.accountBsb} TEXT NOT NULL, ${TablePayee.accountName} TEXT NO NULL, ${TablePayee.nickName} TEXT NOT NULL, ${TablePayee.lastPayDate} INTEGER NOT NULL, PRIMARY KEY(${TablePayee.memberId}, ${TablePayee.docId}))");
      batch.execute(
          "CREATE TABLE ${TableMember.tableName}(${TableMember.memberId} TEXT NOT NULL PRIMARY KEY, ${TableMember.lastLogin} INTEGER NOT NULL, ${TableMember.recentPayee} INTEGER NOT NULL)");
      batch.commit();
    }), version: 1);
  }

  // Member info
  Future<void> updateRecentPayeeEditDate(
      String memberId, DateTime dateTime) async {
    await dataBase.update(TableMember.tableName,
        {TableMember.recentPayee: dateTime.millisecondsSinceEpoch},
        where: "${TableMember.memberId} = ?", whereArgs: [memberId]);
  }

  Future<void> insertMemberIfNotExist(
      String memberId, DateTime lastLogin) async {
    var member = await getMember(memberId);

    if (member == null) {
      await insertMember(getMemberMap(memberId, lastLogin, null));
    }
  }

  Future<void> insertMember(Map<String, Object?> memberMap) async {
    await dataBase.insert(TableMember.tableName, memberMap);
  }

  Future<Map<String, Object?>?> getMember(String memberId) async {
    var query = await dataBase.query(TableMember.tableName,
        where: "${TableMember.memberId} = ?", whereArgs: [memberId], limit: 1);
    return query.isNotEmpty ? query[0] : null;
  }

  /// This will get the date time of member [memberId]'s recent payee add or
  /// delete stored locally.
  /// null is returned if no record of member
  Future<DateTime?> getRecentPayeeEditDate(String memberId) async {
    final List<Map<String, dynamic>> query = await dataBase.query(
        TableMember.tableName,
        where: "${TableMember.memberId} = ?",
        whereArgs: [memberId]);

    if (query.isEmpty) {
      return null;
    }

    Map<String, dynamic> memberInfo = query[0];

    int dateValue = memberInfo[TableMember.recentPayee] as int;

    return dateValue != invalidDateIntValue
        ? DateTime.fromMillisecondsSinceEpoch(dateValue)
        : null;
  }

  /// This will get the member id of the last member who logged in with this app
  /// on this device
  /// null returned when no records of member logged in is found
  Future<String?> getRcentLoggedMemberId() async {
    final List<Map<String, dynamic>> query = await dataBase.query(
        TableMember.tableName,
        orderBy: "${TableMember.lastLogin} DESC",
        limit: 1);

    if (query.isEmpty) {
      return null;
    }

    Map<String, dynamic> memberInfo = query[0];

    return memberInfo[TableMember.memberId];
  }

  Map<String, Object?> getMemberMap(
      String memberId, DateTime lastLogin, DateTime? recentPayeeDate) {
    return {
      TableMember.memberId: memberId,
      TableMember.lastLogin: lastLogin.millisecondsSinceEpoch,
      TableMember.recentPayee: recentPayeeDate != null
          ? recentPayeeDate.millisecondsSinceEpoch
          : invalidDateIntValue
    };
  }

  // Payee
  Future<List<Payee>> getPayees(String memberId) async {
    final List<Map<String, dynamic>> readPayees = await dataBase.query(
        TablePayee.tableName,
        where: "${TablePayee.memberId} = ?",
        whereArgs: [memberId],
        orderBy: "${TablePayee.lastPayDate} DESC");

    return List.generate(readPayees.length, (index) {
      int lastPayeeInt = readPayees[index][TablePayee.lastPayDate] as int;
      String nickNameRaw = readPayees[index][TablePayee.nickName] as String;
      return Payee(
          docId: readPayees[index][TablePayee.docId],
          accountNumber: readPayees[index][TablePayee.accountNumber],
          accountBSB: readPayees[index][TablePayee.accountBsb],
          accountName: readPayees[index][TablePayee.accountName],
          nickName: nickNameRaw,
          lastPayDate: lastPayeeInt != invalidDateIntValue
              ? DateTime.fromMillisecondsSinceEpoch(lastPayeeInt)
              : null);
    });
  }

  Future<bool> doesPayeeExist(String memberId, Payee payee) async {
    await Future.delayed(Duration(milliseconds: 1000));
    var query = await dataBase.query(TablePayee.tableName,
        where:
            "${TablePayee.memberId} = ? AND ${TablePayee.accountNumber} = ? AND ${TablePayee.accountBsb} = ?",
        whereArgs: [
          memberId,
          payee.accountID.getNumber,
          payee.accountID.getBsb
        ],
        limit: 1);
    return query.isEmpty ? false : true;
  }

  Future<void> addPayee(String memberId, Payee payee, DateTime addTime) async {
    await dataBase.insert(TablePayee.tableName, getPayeeMap(memberId, payee));
    await updateRecentPayeeEditDate(memberId, addTime);
  }

  Future<void> delPayee(
      String memberId, String payeeId, DateTime delTime) async {
    await dataBase.delete(TablePayee.tableName,
        where: "${TablePayee.memberId} = ? AND ${TablePayee.docId} = ?",
        whereArgs: [memberId, payeeId]);
    await updateRecentPayeeEditDate(memberId, delTime);
  }

  Future<void> updatePayeeLastPayDate(
      String memberId, String docId, DateTime payDate) async {
    await dataBase.update(TablePayee.tableName,
        {TablePayee.lastPayDate: payDate.millisecondsSinceEpoch},
        where: "${TablePayee.memberId} = ? AND ${TablePayee.docId} = ?",
        whereArgs: [memberId, docId]);
  }

  Future<void> syncPayees(
      {required String memberId,
      required List<Payee> remotePayees,
      required List<Payee> localPayees,
      required DateTime recentPayeeDate}) async {
    var batch = dataBase.batch();

    /*
    List<Payee?> remotePayeesClone = List.from(remotePayees);
    List<Payee?> localPayeesClone = List.from(localPayees);

    for (int i = 0; i < remotePayeesClone.length; i++) {
      for (int j = 0; j < localPayeesClone.length; j++) {
        if (localPayeesClone[j] != null) {
          if (remotePayeesClone[i]!.isAllEqual(localPayeesClone[j]!)) {
            remotePayeesClone[i] = null;
            localPayeesClone[j] = null;
            break;
          }
        }
      }
    }

    for (Payee? payee in remotePayeesClone) {
      if (payee != null) {
        batch.insert(TablePayee.tableName, getPayeeMap(memberId, payee));
      }
    }

    for (Payee? payee in localPayeesClone) {
      if (payee != null) {
        batch.delete(TablePayee.tableName,
            where: "${TablePayee.memberId} = ? AND ${TablePayee.docId} = ?",
            whereArgs: [memberId, payee.docId]
            /*
            where:
                "${TablePayee.memberId} = ? AND ${TablePayee.accountNumber} = ? AND ${TablePayee.accountBsb} = ? AND ${TablePayee.accountName} = ? AND ${TablePayee.nickName} = ?",
            whereArgs: [
              memberId,
              payee.accountID.getNumber,
              payee.accountID.getBsb,
              payee.accountName,
              payee.nickName
            ]*/
            );
      }
    }*/

    batch.delete(TablePayee.tableName,
        where: "${TablePayee.memberId} = ?", whereArgs: [memberId]);

    for (Payee payee in remotePayees) {
      batch.insert(TablePayee.tableName, getPayeeMap(memberId, payee));
    }

    await batch.commit();
    await updateRecentPayeeEditDate(memberId, recentPayeeDate);
  }

  Map<String, Object?> getPayeeMap(String memberId, Payee payee) {
    return {
      TablePayee.docId: payee.docId,
      TablePayee.memberId: memberId,
      TablePayee.accountNumber: payee.accountID.getNumber,
      TablePayee.accountBsb: payee.accountID.getBsb,
      TablePayee.accountName: payee.accountName,
      TablePayee.nickName: payee.nickName,
      TablePayee.lastPayDate: payee.lastPayDate != null
          ? payee.lastPayDate!.millisecondsSinceEpoch
          : invalidDateIntValue
    };
  }

  // AccountIDOrder
  Future<void> insertAccountID(AccountIDOrder accountIDOrder) async {
    await dataBase.insert(
        AccountOrder.tableName, getAccountIDOrderMap(accountIDOrder));
  }

  Future<List<AccountIDOrder>> getAccountIDs() async {
    final List<Map<String, dynamic>> accountIDs = await dataBase.query(
        AccountOrder.tableName,
        where: "${AccountOrder.memberID} = ?",
        whereArgs: [/*TODO: memberid*/ testID]);

    List<AccountIDOrder> accountIDOrders = List.generate(
        accountIDs.length,
        (index) => AccountIDOrder(
            number: accountIDs[index][AccountOrder.number],
            bsb: accountIDs[index][AccountOrder.bsb],
            order: accountIDs[index][AccountOrder.order],
            hidden: accountIDs[index][AccountOrder.hidden]));

    return accountIDOrders;
  }

  Future<List<AccountIDOrder>> getAccountIDsOrdered() async {
    List<AccountIDOrder> accountIDOrders = await getAccountIDs();

    accountIDOrders.sort(((a, b) => a.order.compareTo(b.order)));

    return accountIDOrders;
  }

  Future<void> replaceAccountOrder(List<AccountIDOrder> accountIDOrders) async {
    Batch batch = dataBase.batch();

    batch.delete(AccountOrder.tableName,
        where: "${AccountOrder.memberID} = ?",
        whereArgs: [/* TODO: member id */ testID]);
    for (AccountIDOrder accountIDOrder in accountIDOrders) {
      batch.insert(
          AccountOrder.tableName, getAccountIDOrderMap(accountIDOrder));
    }

    batch.commit();
  }

  Map<String, Object?> getAccountIDOrderMap(AccountIDOrder accountIDOrder) {
    return {
      //TODO: member id
      AccountOrder.memberID: testID,
      AccountOrder.order: accountIDOrder.order,
      AccountOrder.number: accountIDOrder.getAccountID.getNumber,
      AccountOrder.bsb: accountIDOrder.getAccountID.getBsb,
      AccountOrder.hidden: accountIDOrder.getHidden
    };
  }
}
