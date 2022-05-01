import 'package:flutwest/model/account.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/account_id.dart';

class AccountOrder {
  static const String tableName = "accounts";
  static const String order = "order";
  static const String number = "number";
  static const String bsb = "bsb";
  static const String memberID = "member_id";

  AccountOrder._() {}
}

class SQLiteController {
  static const String dbName = "flutWest.db";

  static late final SQLiteController? _controller;

  late final Database dataBase;

  SQLiteController._() {}

  SQLiteController getInstance() {
    _controller ??= SQLiteController._();

    return _controller!;
  }

  void loadDB() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);

    dataBase = await openDatabase(path, onCreate: ((db, version) {
      return db.execute(
          'CREATE TABLE ${AccountOrder.tableName}(${AccountOrder.memberID} TEXT NOT NULL, ${AccountOrder.order} INTEGER NOT NULL, ${AccountOrder.number} TEXT, ${AccountOrder.bsb} TEXT, PRIMARY KEY (${AccountOrder.memberID}, ${AccountOrder.order}))');
    }), version: 1);
  }

  Future<void> insertAccountID(AccountID account, int order) async {
    await dataBase.insert(
        AccountOrder.tableName, getAccountIDMap(account, order));
  }

  Future<List<AccountIDOrder>> getAccountIDs() async {
    final List<Map<String, dynamic>> accountIDs = await dataBase.query(
        AccountOrder.tableName,
        where: "${AccountOrder.memberID} = ?",
        whereArgs: [/*TODO: memberid*/]);

    List<AccountIDOrder> accountIDOrders = List.generate(
        accountIDs.length,
        (index) => AccountIDOrder(
            number: accountIDs[index][AccountOrder.number],
            bsb: accountIDs[index][AccountOrder.bsb],
            order: accountIDs[index][AccountOrder.order]));

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
        whereArgs: [/* TODO: member id */]);
    for (AccountIDOrder accountIDOrder in accountIDOrders) {
      batch.insert(
          AccountOrder.tableName,
          getAccountIDMap(
              accountIDOrder.getAccountID, accountIDOrder.getOrder));
    }

    batch.commit();
  }

  Map<String, Object?> getAccountIDMap(AccountID account, int order) {
    return {
      //TODO: member id
      AccountOrder.order: order,
      AccountOrder.number: account.getNumber,
      AccountOrder.bsb: account.getBsb
    };
  }
}