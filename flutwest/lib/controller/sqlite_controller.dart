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

  void loadDB() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);

    dataBase = await openDatabase(path, onCreate: ((db, version) {
      var batch = db.batch();
      batch.execute(
          'CREATE TABLE ${AccountOrder.tableName}(${AccountOrder.memberID} TEXT NOT NULL, ${AccountOrder.order} INTEGER NOT NULL, ${AccountOrder.number} TEXT, ${AccountOrder.bsb} TEXT,  ${AccountOrder.hidden} INTEGER, PRIMARY KEY (${AccountOrder.memberID}, ${AccountOrder.order}))');
      batch.execute(
          "CREATE TABLE ${TablePayee.tableName}(${TablePayee.memberId} TEXT NOT NULL, ${TablePayee.accountNumber} TEXT NOT NULL, ${TablePayee.accountBsb} TEXT NOT NULL, ${TablePayee.accountName} TEXT NO NULL, ${TablePayee.nickName} TEXT, ${TablePayee.lastPayDate} INTEGER, PRIMARY KEY(${TablePayee.memberId}, ${TablePayee.accountNumber}))");
      batch.execute(
          "CREATE TABLE ${TableMember.tableName}(${TableMember.memberId} TEXT NOT NULL PRIMARY KEY, ${TableMember.lastLogin} INTEGER NOT NULL, ${TableMember.recentPayee} INTEGER NOT NULL)");
      batch.commit();
    }), version: 1);
  }

  // Payee
  Future<List<Payee>> getPayees(String memberId) async {
    final List<Map<String, dynamic>> readPayees = await dataBase.query(
        TablePayee.tableName,
        where: "${TablePayee.memberId} = ?",
        whereArgs: [memberId],
        orderBy: "${TablePayee.lastPayDate} DESC");

    return List.generate(
        readPayees.length,
        (index) => Payee(
            accountNumber: readPayees[index][TablePayee.accountNumber],
            accountBSB: readPayees[index][TablePayee.accountBsb],
            accountName: readPayees[index][TablePayee.accountName],
            nickName: readPayees[index][TablePayee.nickName],
            lastPayDate: readPayees[index][TablePayee.lastPayDate] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    readPayees[index][TablePayee.lastPayDate] as int)
                : null));
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

    return memberInfo[TableMember.recentPayee] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            memberInfo[TableMember.recentPayee] as int)
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

  Future<void> syncPayees(
      {required List<Payee> remotePayees,
      required List<Payee> localPayees}) async {
    var batch = dataBase.batch();

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
        batch.insert(TablePayee.tableName, getPayeeMap(payee));
      }
    }

    for (Payee? payee in localPayeesClone) {
      if (payee != null) {
        batch.delete(TablePayee.tableName,
            where:
                "${TablePayee.accountNumber} = ? AND ${TablePayee.accountBsb} = ? AND ${TablePayee.accountName} = ? AND ${TablePayee.nickName} = ?",
            whereArgs: [
              payee.accountID.getNumber,
              payee.accountID.getBsb,
              payee.accountName,
              payee.nickName
            ]);
      }
    }

    await batch.commit();
  }

  Map<String, Object?> getPayeeMap(Payee payee) {
    return {
      TablePayee.accountNumber: payee.accountID.getNumber,
      TablePayee.accountBsb: payee.accountID.getBsb,
      TablePayee.accountName: payee.accountName,
      TablePayee.nickName: payee.nickName,
      TablePayee.lastPayDate: payee.lastPayDate != null
          ? payee.lastPayDate!.millisecondsSinceEpoch
          : null
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
