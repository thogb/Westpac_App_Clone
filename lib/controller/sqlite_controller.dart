import 'package:flutwest/model/payee.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/account_id.dart';

class SQLiteController {
  static const int invalidDateIntValue = -1;
  static const String invalidString = "";
  static const String dbName = "flutWest.db";

  //static SQLiteController? _controller;
  static final SQLiteController _controller = SQLiteController._internal();

  late final Database _database;

  late final TableAccountOrder tableAccountOrder;
  late final TablePayee tablePayee;
  late final TableMember tableMember;

  SQLiteController._internal();

  static SQLiteController get instance => _controller;

  factory SQLiteController() {
    return _controller;
  }

  Future<void> loadDB() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);

    _database = await openDatabase(path, onCreate: ((db, version) {
      var batch = db.batch();
      batch.execute(
          'CREATE TABLE ${TableAccountOrder.tableName}(${TableAccountOrder.colMemberId} TEXT NOT NULL, ${TableAccountOrder.colOrder} INTEGER NOT NULL, ${TableAccountOrder.colNumber} TEXT NOT NULL, ${TableAccountOrder.colBsb} TEXT NOT NULL,  ${TableAccountOrder.colHidden} INTEGER, PRIMARY KEY (${TableAccountOrder.colMemberId}, ${TableAccountOrder.colOrder}))');
      batch.execute(
          "CREATE TABLE ${TablePayee.tableName}(${TablePayee.colMemberId} TEXT NOT NULL, ${TablePayee.colDocId} TEXT NOT NULL, ${TablePayee.colAccountNumber} TEXT NOT NULL, ${TablePayee.colAccountBsb} TEXT NOT NULL, ${TablePayee.colAccountName} TEXT NO NULL, ${TablePayee.colNickName} TEXT NOT NULL, ${TablePayee.colLastPayDate} INTEGER NOT NULL, PRIMARY KEY(${TablePayee.colMemberId}, ${TablePayee.colDocId}))");
      batch.execute(
          "CREATE TABLE ${TableMember.tableName}(${TableMember.colMemberId} TEXT NOT NULL PRIMARY KEY, ${TableMember.colLastLogin} INTEGER NOT NULL, ${TableMember.colRecentPayee} INTEGER NOT NULL, ${TableMember.colNotifyLocalAuth} INTEGER NOT NULL)");
      batch.commit();
    }), version: 1);

    tableAccountOrder = TableAccountOrder(database: _database);
    tablePayee = TablePayee(database: _database);
    tableMember = TableMember(database: _database);
  }
}

class TableAccountOrder {
  static const String tableName = "accounts";
  static const String colOrder = "order_val";
  static const String colNumber = "number";
  static const String colBsb = "bsb";
  static const String colHidden = "hidden";
  static const String colMemberId = "member_id";

  final Database _database;

  TableAccountOrder({required Database database}) : _database = database;

  // AccountIDOrder
  Future<void> insertAccountID(
      AccountIDOrder accountIDOrder, String memberId) async {
    await _database.insert(
        tableName, getAccountIDOrderMap(accountIDOrder, memberId));
  }

  Future<List<AccountIDOrder>> getAccountIDs(String memberId) async {
    final List<Map<String, dynamic>> accountIDs = await _database
        .query(tableName, where: "$colMemberId = ?", whereArgs: [memberId]);

    List<AccountIDOrder> accountIDOrders = List.generate(
        accountIDs.length,
        (index) => AccountIDOrder(
            number: accountIDs[index][colNumber],
            bsb: accountIDs[index][colBsb],
            order: accountIDs[index][colOrder],
            hidden: accountIDs[index][colHidden]));

    return accountIDOrders;
  }

  Future<List<AccountIDOrder>> getAccountIDsOrdered(String memberId) async {
    List<AccountIDOrder> accountIDOrders = await getAccountIDs(memberId);

    accountIDOrders.sort(((a, b) => a.order.compareTo(b.order)));

    return accountIDOrders;
  }

  Future<void> replaceAccountOrder(
      List<AccountIDOrder> accountIDOrders, String memberId) async {
    Batch batch = _database.batch();

    batch.delete(tableName, where: "$colMemberId = ?", whereArgs: [memberId]);
    for (AccountIDOrder accountIDOrder in accountIDOrders) {
      batch.insert(tableName, getAccountIDOrderMap(accountIDOrder, memberId));
    }

    batch.commit();
  }

  Map<String, Object?> getAccountIDOrderMap(
      AccountIDOrder accountIDOrder, String memberId) {
    return {
      colMemberId: memberId,
      colOrder: accountIDOrder.order,
      colNumber: accountIDOrder.getAccountID.getNumber,
      colBsb: accountIDOrder.getAccountID.getBsb,
      colHidden: accountIDOrder.getHidden
    };
  }
}

class TablePayee {
  static const String tableName = "payee";
  static const String colDocId = "doc_id";
  static const String colMemberId = "member_id";
  static const String colAccountName = "account_name";
  static const String colNickName = "nick_name";
  static const String colAccountNumber = "account_number";
  static const String colAccountBsb = "account_bsb";
  static const String colLastPayDate = "last_pay_date";

  final Database _database;

  TablePayee({required Database database}) : _database = database;

  Future<List<Payee>> getPayees(String memberId) async {
    final List<Map<String, dynamic>> readPayees = await _database.query(
        tableName,
        where: "$colMemberId = ?",
        whereArgs: [memberId],
        orderBy: "$colLastPayDate DESC");

    return List.generate(readPayees.length, (index) {
      int lastPayeeInt = readPayees[index][colLastPayDate] as int;
      String nickNameRaw = readPayees[index][colNickName] as String;
      return Payee(
          docId: readPayees[index][colDocId],
          accountNumber: readPayees[index][colAccountNumber],
          accountBSB: readPayees[index][colAccountBsb],
          accountName: readPayees[index][colAccountName],
          nickName: nickNameRaw,
          lastPayDate: lastPayeeInt != SQLiteController.invalidDateIntValue
              ? DateTime.fromMillisecondsSinceEpoch(lastPayeeInt)
              : null);
    });
  }

  Future<bool> doesPayeeExist(String memberId, Payee payee) async {
    var query = await _database.query(TablePayee.tableName,
        where:
            "$colMemberId = ? AND $colAccountNumber = ? AND $colAccountBsb = ?",
        whereArgs: [
          memberId,
          payee.accountID.getNumber,
          payee.accountID.getBsb
        ],
        limit: 1);
    return query.isEmpty ? false : true;
  }

  Future<void> addPayee(String memberId, Payee payee, DateTime addTime) async {
    await _database.insert(TablePayee.tableName, getPayeeMap(memberId, payee));
    await SQLiteController.instance.tableMember
        .updateRecentPayeeEditDate(memberId, addTime);
  }

  Future<void> delPayee(
      String memberId, String payeeId, DateTime delTime) async {
    await _database.delete(TablePayee.tableName,
        where: "$colMemberId = ? AND $colDocId = ?",
        whereArgs: [memberId, payeeId]);
    await SQLiteController.instance.tableMember
        .updateRecentPayeeEditDate(memberId, delTime);
  }

  Future<void> updatePayeeLastPayDate(
      String memberId, String docId, DateTime payDate) async {
    await _database.update(
        TablePayee.tableName, {colLastPayDate: payDate.millisecondsSinceEpoch},
        where: "$colMemberId = ? AND $colDocId = ?",
        whereArgs: [memberId, docId]);
    await SQLiteController.instance.tableMember
        .updateRecentPayeeEditDate(memberId, payDate);
  }

  Future<void> syncPayees(
      {required String memberId,
      required List<Payee> remotePayees,
      required List<Payee> localPayees,
      required DateTime recentPayeeDate}) async {
    var batch = _database.batch();

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
        where: "$colMemberId = ?", whereArgs: [memberId]);

    for (Payee payee in remotePayees) {
      batch.insert(TablePayee.tableName, getPayeeMap(memberId, payee));
    }

    await batch.commit();
    await SQLiteController.instance.tableMember
        .updateRecentPayeeEditDate(memberId, recentPayeeDate);
  }

  Map<String, Object?> getPayeeMap(String memberId, Payee payee) {
    return {
      colDocId: payee.docId,
      colMemberId: memberId,
      colAccountNumber: payee.accountID.getNumber,
      colAccountBsb: payee.accountID.getBsb,
      colAccountName: payee.accountName,
      colNickName: payee.nickName,
      colLastPayDate: payee.lastPayDate != null
          ? payee.lastPayDate!.millisecondsSinceEpoch
          : SQLiteController.invalidDateIntValue
    };
  }
}

class TableMember {
  static const String tableName = "member_info";
  static const String colMemberId = "member_id";
  static const String colLastLogin = "last_login";
  static const String colRecentPayee = "recent_payee";
  static const String colNotifyLocalAuth = "notify_local_auth";

  final Database _database;

  TableMember({required Database database}) : _database = database;

  Future<bool> getNotifyLocalAuth(String memberId) async {
    bool notifyLocalAuth = false;
    var query = await _database.query(tableName,
        where: "$colMemberId = ?", whereArgs: [memberId], limit: 1);
    if (query.isNotEmpty) {
      Object? value = query[0][colNotifyLocalAuth];
      if (value != null && value is int) {
        notifyLocalAuth = value == 1 ? true : false;
      }
    }

    return notifyLocalAuth;
  }

  Future<void> updateNotifyLocalAuth(String memberId, bool value) async {
    await _database.update(tableName, {colNotifyLocalAuth: value ? 1 : 0},
        where: "$colMemberId = ?", whereArgs: [memberId]);
  }

  Future<void> updateRecentPayeeEditDate(
      String memberId, DateTime dateTime) async {
    await _database.update(TableMember.tableName,
        {colRecentPayee: dateTime.millisecondsSinceEpoch},
        where: "$colMemberId = ?", whereArgs: [memberId]);
  }

  Future<bool> insertMemberIfNotExist(
      String memberId, DateTime lastLogin) async {
    var member = await getMember(memberId);
    bool exist = member != null;

    if (!exist) {
      await insertMember(getMemberMap(memberId, lastLogin, null, false));
    }

    return exist;
  }

  Future<void> insertMember(Map<String, Object?> memberMap) async {
    await _database.insert(TableMember.tableName, memberMap);
  }

  Future<Map<String, Object?>?> getMember(String memberId) async {
    var query = await _database.query(TableMember.tableName,
        where: "$colMemberId = ?", whereArgs: [memberId], limit: 1);
    return query.isNotEmpty ? query[0] : null;
  }

  /// This will get the date time of member [memberId]'s recent payee add or
  /// delete stored locally.
  /// null is returned if no record of member
  Future<DateTime?> getRecentPayeeEditDate(String memberId) async {
    final List<Map<String, dynamic>> query = await _database.query(
        TableMember.tableName,
        where: "$colMemberId = ?",
        whereArgs: [memberId]);

    if (query.isEmpty) {
      return null;
    }

    Map<String, dynamic> memberInfo = query[0];

    int dateValue = memberInfo[colRecentPayee] as int;

    return dateValue != SQLiteController.invalidDateIntValue
        ? DateTime.fromMillisecondsSinceEpoch(dateValue)
        : null;
  }

  Future<void> updateRecentLogin(
      {required String memberId, required DateTime dateTime}) async {
    await _database.update(
        tableName, {colLastLogin: dateTime.millisecondsSinceEpoch},
        where: "$colMemberId = ?", whereArgs: [memberId]);
  }

  /// This will get the member id of the last member who logged in with this app
  /// on this device
  /// null returned when no records of member logged in is found
  Future<String?> getRecentLoggedMemberId() async {
    final List<Map<String, dynamic>> query = await _database
        .query(TableMember.tableName, orderBy: "$colLastLogin DESC", limit: 1);

    if (query.isEmpty) {
      return null;
    }

    Map<String, dynamic> memberInfo = query[0];

    return memberInfo[colMemberId];
  }

  Map<String, Object?> getMemberMap(String memberId, DateTime lastLogin,
      DateTime? recentPayeeDate, bool notifyLocalAuth) {
    return {
      colMemberId: memberId,
      colLastLogin: lastLogin.millisecondsSinceEpoch,
      colRecentPayee: recentPayeeDate != null
          ? recentPayeeDate.millisecondsSinceEpoch
          : SQLiteController.invalidDateIntValue,
      colNotifyLocalAuth: notifyLocalAuth ? 1 : 0
    };
  }
}
