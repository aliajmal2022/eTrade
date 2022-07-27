import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Order.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:eTrade/entities/Recovery.dart';
import 'package:eTrade/entities/Sale.dart';
import 'package:eTrade/entities/User.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLHelper {
  SQLHelper._privateConstructor();
  static final SQLHelper instance = SQLHelper._privateConstructor();
  static const _dbname = "eTrade.db";
  static const _dbversion = 1;
  static var _database;
  static var isExit = false;
  static var directory;
  static bool onceCheck = true;
  static var path;
  Future<Database> CheckDBExit() async {
    if (onceCheck) {
      directory = await getDatabasesPath();
      path = join(directory, _dbname);
      isExit = await databaseExists(path);
      if (isExit) {
        _database = await openDatabase(path,
            version: _dbversion, onOpen: (Database database) async {});
        onceCheck = false;
        return _database;
      }
    }
    if (isExit) {
      return _database;
    }
    _database = await _initiateDatabase();
    return _database;
  }

  static Future<void> resetData(String action) async {
    if (action == "Sync") {
      await deleteTable(_database, "Party");
      await deleteTable(_database, "Item");
    } else {
      await deleteTable(_database, "Party");
      await deleteTable(_database, "Order");
      await deleteTable(_database, "User");
      await deleteTable(_database, "Order");
      await deleteTable(_database, "OrderDetail");
      await deleteTable(_database, "Sale");
      await deleteTable(_database, "SaleDetail");
      await deleteTable(_database, "Recovery");
    }
  }

  Future<dynamic> get database async {
    return await CheckDBExit();
  }

  static _initiateDatabase() async {
    return await openDatabase(path, version: _dbversion,
        onOpen: (Database database) async {
      await createPartyTable(database);
      await createItemTable(database);
      await createUserTable(database);
      await createOrderTable(database);
      await createOrderDetailTable(database);
      await createSaleTable(database);
      await createSaleDetailTable(database);
      await createRecoveryTable(database);
    });
  }

  static Future<void> createUserTable(Database database) async {
    await database.execute('''
CREATE TABLE User(
  ID INTEGER PRIMARY KEY NOT NULL,
  UserName TEXT NOT NULL,
  PASSWORD TEXT NOT NULL
  )
   ''');
    print("successfully created User table");
  }

  Future<int> createUser(User user) async {
    Database db = await instance.database;
    final data = {
      'UserName': user.userName,
      'Password': user.password,
    };
    return await db.insert('User', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> createPartyTable(Database database) async {
    await database.execute('''
  CREATE TABLE Party(
	PartyID INTEGER PRIMARY KEY NOT NULL,
	PartyName TEXT NOT NULL,
  Discount REAL,
  isPosted BOOLEAN NOT NULL, 
  Address TEXT
 )
      ''');
    print("successfully created Party table");
  }

  Future<int> createParty(Customer customer) async {
    Database db = await instance.database;
    // updateItem(customer.partyId, customer.partyName, db);
    bool isPosted = false;
    final data = {
      'PartyID': customer.partyId,
      'PartyName': customer.partyName,
      'Discount': customer.discount,
      'isPosted': isPosted,
      'Address': customer.address,
    };
    return await db.insert('Party', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> createItemTable(Database database) async {
    await database.execute('''
  CREATE TABLE Item(
	ItemID TEXT PRIMARY KEY NOT NULL,
	ItemName TEXT NOT NULL,
	TradePrice REAL NOT NULL
 )
      ''');
    print("successfully created Item table");
  }

//   // Create new ItemValue(journal)
  Future<int> createItem(Product product) async {
    Database db = await instance.database;

    final data = {
      'ItemID': product.ID.toString(),
      'ItemName': product.Title,
      'TradePrice': product.Price,
    };
    return await db.insert('Item', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> createOrderTable(Database database) async {
    await database.execute('''
CREATE TABLE [Order](
OrderID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
PartyID INTEGER NOT NULL,
UserID INTEGER NOT NULL,
TotalQuantity INTEGER NOT NULL,
TotalValue REAL NOT NULL,
Dated TEXT NOT NULL,
Description TEXT,
isPosted BOOLEAN NOT NULL
  )
      ''');
    print("successfully created Order table");
  }

  Future<int> createOrder(Order order, bool isPost) async {
    Database db = await instance.database;

    final data = {
      'PartyID': order.customer.partyId,
      'Description': order.description,
      'TotalQuantity': order.totalQuantity,
      'UserID': order.userID,
      'TotalValue': order.totalValue,
      'Dated': order.date,
      'isPosted': isPost,
    };
    final id = await db.insert('Order', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List> getFromToViewOrder(var start, var end) async {
    Database db = await instance.database;
    var listOrder = await db.rawQuery(
        "SELECT o.Dated,o.OrderID,o.TotalQuantity,p.PartyName FROM [Order] AS o INNER JOIN Party AS p ON p.PartyID = o.PartyID WHERE o.Dated BETWEEN '$start' AND '$end' and o.isPosted=0 ");

    return listOrder;
  }

  static Future<List> getSpecificViewOrder(var date) async {
    Database db = await instance.database;
    var listOrder = await db.rawQuery(
        "SELECT o.Dated,o.OrderID,o.TotalQuantity,p.PartyName FROM [Order] AS o INNER JOIN Party AS p ON p.PartyID = o.PartyID WHERE o.Dated ='${date}' and o.isPosted=0 ");

    return listOrder;
  }

  static Future<List> getAllViewOrder() async {
    Database db = await instance.database;
    var listOrder = await db.rawQuery(
        "SELECT o.Dated,o.OrderID,o.TotalQuantity,p.PartyName FROM [Order] AS o INNER JOIN Party AS p ON p.PartyID = o.PartyID WHERE  o.isPosted=0 ");

    return listOrder;
  }

  static Future<void> updateOrderTable(
      int id, int partyID, String description) async {
    Database db = await instance.database;
    try {
      await db.execute(
          "UPDATE [Order] SET TotalQuantity = 	(SELECT Sum(Quantity) FROM OrderDetail as od WHERE  od.OrderID=$id), TotalValue= (SELECT Sum(Amount) FROM OrderDetail as od WHERE  od.OrderID=$id),Description='$description',PartyID=$partyID WHERE [Order].OrderID=$id and [Order].isPosted=0"

          // "UPDATE [Order] SET  PartyID=$partyID,Description='$description',TotalQuantity = (SELECT Sum(Quantity) FROM OrderDetail , [Order] as o WHERE o.OrderID = OrderDetail.OrderID and o.OrderID=$id),TotalValue=(SELECT Sum(Amount) FROM OrderDetail , [Order] as o WHERE o.OrderID = OrderDetail.OrderID and o.OrderID=$id) WHERE [Order].OrderID=$id"
          );
    } catch (e) {
      debugPrint('Order is not update');
    }
  }

  static Future<void> createOrderDetailTable(Database database) async {
    await database.execute('''
  CREATE TABLE OrderDetail(
	ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  UserID INTEGER NOT NULL,
	OrderID INTEGER NOT NULL,
	ItemID TEXT NOT NULL,
  Quantity INTEGER NOT NULL,
  RATE REAL NOT NULL,
  Discount REAL,
  Bonus INTEGER,
  [TO] Real,
  Amount REAL NOT NULL,
	Dated TEXT NOT NULL,
  isPosted BOOLEAN NOT NULL
 )
      ''');
    print("successfully created OrderDetail table");
  }

  Future<int> createOrderDetail(Product product, int orderID, String date,
      bool isPost, int userID) async {
    Database db = await instance.database;

    final data = {
      'UserID': userID,
      'OrderID': orderID,
      'Discount': product.discount,
      'Bonus': product.bonus,
      '[TO]': product.to,
      'ItemID': product.ID,
      'Quantity': product.Quantity,
      'Rate': product.Price,
      'Amount': product.Quantity * product.Price,
      'Dated': date,
      'isPosted': isPost,
    };
    return await db.insert('OrderDetail', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List> getOrderDetail(int id) async {
    Database db = await instance.database;
    var ListOrder = await db.rawQuery(
        "SELECT i.ItemName, od.Bonus,od.Discount,od.[TO],od.Quantity,od.Rate,od.Amount,i.itemID FROM OrderDetail as od INNER JOIN Item AS i ON i.ItemID = od.ItemID WHERE od.OrderID=$id and od.isPosted=0");

    return ListOrder;
  }

  static Future<void> createSaleTable(Database database) async {
    await database.execute('''
CREATE TABLE Sale(
SaleID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
PartyID INTEGER NOT NULL,
UserID INTEGER NOT NULL,
TotalQuantity INTEGER NOT NULL,
TotalValue REAL NOT NULL,
Dated TEXT NOT NULL,
Description TEXT,
isCash BOOLEAN NOT NULL,
isPosted BOOLEAN NOT NULL
  )
      ''');
    print("successfully created Sale table");
  }

  Future<int> createSale(Sale sale, bool isPost) async {
    Database db = await instance.database;

    final data = {
      'PartyID': sale.customer.partyId,
      'Description': sale.description,
      'TotalQuantity': sale.totalQuantity,
      'UserID': sale.userID,
      'isCash': sale.isCash,
      'TotalValue': sale.totalValue,
      'Dated': sale.date,
      'isPosted': isPost,
    };
    final id = await db.insert('Sale', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List> getFromToViewSale(var start, var end) async {
    Database db = await instance.database;
    var listOrder = await db.rawQuery(
        "SELECT s.Dated,s.SaleID,s.TotalQuantity,p.PartyName FROM Sale AS s INNER JOIN Party AS p ON p.PartyID = s.PartyID WHERE s.Dated BETWEEN '$start' AND '$end' and s.isPosted=0 ");

    return listOrder;
  }

  static Future<List> getSpecificViewSale(var date) async {
    Database db = await instance.database;
    var listOrder = await db.rawQuery(
        "SELECT s.Dated,s.SaleID,s.TotalQuantity,p.PartyName FROM Sale AS s INNER JOIN Party AS p ON p.PartyID = s.PartyID WHERE s.Dated ='${date}' and s.isPosted=0 ");

    return listOrder;
  }

  static Future<List> getAllViewSale() async {
    Database db = await instance.database;
    var listOrder = await db.rawQuery(
        "SELECT s.Dated,s.SaleID,s.TotalQuantity,p.PartyName FROM Sale AS s INNER JOIN Party AS p ON s.PartyID = p.PartyID WHERE  s.isPosted=0 ");

    return listOrder;
  }

  static Future<void> updateSaleTable(
      int id, int partyID, String description, bool isCash) async {
    Database db = await instance.database;
    try {
      await db.execute(
          "UPDATE Sale SET TotalQuantity = 	(SELECT Sum(Quantity) FROM SaleDetail as sd WHERE  sd.SaleID=$id), TotalValue= (SELECT Sum(Amount) FROM SaleDetail as sd WHERE  sd.SaleID=$id),Description='$description',PartyID='$partyID',isCash='$isCash' WHERE Sale.SaleID=$id and Sale.isPosted=0"

          // "UPDATE [Order] SET  PartyID=$partyID,Description='$description',TotalQuantity = (SELECT Sum(Quantity) FROM OrderDetail , [Order] as o WHERE o.OrderID = OrderDetail.OrderID and o.OrderID=$id),TotalValue=(SELECT Sum(Amount) FROM OrderDetail , [Order] as o WHERE o.OrderID = OrderDetail.OrderID and o.OrderID=$id) WHERE [Order].OrderID=$id"
          );
    } catch (e) {
      debugPrint('Order is not update');
    }
  }

  static Future<void> createSaleDetailTable(Database database) async {
    await database.execute('''
  CREATE TABLE SaleDetail(
	ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  SaleID INTEGER NOT NULL,
	UserID INTEGER NOT NULL,
	ItemID TEXT NOT NULL,
  Quantity INTEGER NOT NULL,
  RATE REAL NOT NULL,
  Discount REAL,
  Bonus INTEGER,
  [TO] Real,
  Amount REAL NOT NULL,
	Dated TEXT NOT NULL,
  isPosted BOOLEAN NOT NULL
 )
      ''');
    print("successfully created SaleDetail table");
  }

  Future<int> createSaleDetail(
      Product product, int saleID, String date, bool isPost, int userID) async {
    Database db = await instance.database;

    final data = {
      'UserID': userID,
      'SaleID': saleID,
      'Discount': product.discount,
      'Bonus': product.bonus,
      '[TO]': product.to,
      'ItemID': product.ID,
      'Quantity': product.Quantity,
      'Rate': product.Price,
      'Amount': product.Quantity * product.Price,
      'Dated': date,
      'isPosted': isPost,
    };
    return await db.insert('SaleDetail', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List> getSaleDetail(int id) async {
    Database db = await instance.database;
    var ListOrder = await db.rawQuery(
        "SELECT i.ItemName,sd.Bonus,sd.Discount,sd.[TO],sd.Quantity,sd.Rate,sd.Amount,i.itemID FROM SaleDetail as sd INNER JOIN Item AS i ON i.ItemID = sd.ItemID WHERE sd.SaleID=$id and sd.isPosted=0");

    return ListOrder;
  }

  static Future<void> createRecoveryTable(Database database) async {
    await database.execute('''
CREATE TABLE Recovery(
RecoveryID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
PartyID INTEGER NOT NULL,
UserID INTEGER NOT NULL,
Amount REAL NOT NULL,
Dated TEXT NOT NULL,
Description TEXT,
isPosted BOOLEAN NOT NULL
  )
      ''');
    print("successfully created Recovery table");
  }

  Future<int> createRecoveryitem(Recovery recovery, bool isPost) async {
    Database db = await instance.database;

    final data = {
      'PartyID': recovery.party.partyId,
      'UserID': recovery.userID,
      'Description': recovery.description,
      'Dated': recovery.dated,
      'Amount': recovery.amount,
      'isPosted': isPost,
    };
    final id = await db.insert('Recovery', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List> getFromToRecovery(var start, var end) async {
    Database db = await instance.database;
    var listRecovery = await db.rawQuery(
        "SELECT r.Dated,r.Description,r.RecoveryID,r.Amount,p.PartyName,p.PartyID FROM Recovery AS r INNER JOIN Party AS p ON p.PartyID = r.PartyID WHERE r.Dated BETWEEN '$start' AND '$end' and r.isPosted=0");

    return listRecovery;
  }

  static Future<List> getSpecificRecovery(var date) async {
    Database db = await instance.database;
    var listRecovery = await db.rawQuery(
        "SELECT r.Dated,r.Description,r.RecoveryID,r.Amount,p.PartyName,p.PartyID FROM Recovery AS r INNER JOIN Party AS p ON p.PartyID = r.PartyID WHERE r.Dated = '$date' and r.isPosted=0");

    return listRecovery;
  }

  static Future<List> getAllRecovery() async {
    Database db = await instance.database;
    var listRecovery = await db.rawQuery(
        "SELECT r.Dated,r.Description,r.RecoveryID,r.Amount,p.PartyName,p.PartyID FROM Recovery AS r INNER JOIN Party AS p ON p.PartyID = r.PartyID WHERE r.isPosted=0");

    return listRecovery;
  }

  static Future<void> deleteRecovery() async {
    Database db = await instance.database;
    try {
      await db.execute("DELETE FROM Recovery;");
      await db
          .execute("update sqlite_sequence set seq='0' where name=RecoveryID");
    } catch (e) {
      debugPrint('item is not delete');
    }
  }

  static Future<void> updateRecoveryTable(
      int id, int partyID, double amount, String description) async {
    Database db = await instance.database;
    try {
      await db.execute(
          "UPDATE Recovery SET Amount=$amount, PartyID=$partyID,Description='$description' WHERE Recovery.RecoveryId=$id and Recovery.isPosted=0");
    } catch (e) {
      debugPrint('Recovery is not update');
    }
  }

  static Future<void> deleteItem(String table, String idName, var id) async {
    Database db = await instance.database;
    try {
      await db
          .execute("DELETE FROM [$table] WHERE $idName=$id AND isPosted=0 ");
    } catch (e) {
      debugPrint('Row is not delete');
    }
  }

  static Future<int> getIDForNCustomer() async {
    int nCustomerID = 0;
    Database db = await instance.database;
    List ListCustomer = await db.rawQuery(
        '''SELECT  ifnull(MAX(PartyId),2200)+1 FROM Party AS p WHERE p.PartyID BETWEEN 2201 AND 2999''');
    var iterable = ListCustomer.whereType<Map>().first;

    nCustomerID = iterable['ifnull(MAX(PartyId),2200)+1'];
    return nCustomerID;
  }

  // Delete
  Future<List<Map<String, dynamic>>> getTable(
      String tableName, String id) async {
    Database db = await instance.database;
    if (tableName == "Order" ||
        tableName == "OrderDetail" ||
        tableName == "Recovery") {
      return db.query(tableName, orderBy: id, where: "isPosted=0");
    } else {
      return db.query(tableName, orderBy: id);
    }
  }

  static Future<void> deleteTable(Database database, String tableName) async {
    try {
      await database.execute("""
  DELETE FROM $tableName 
      """);
      // }

    } catch (e) {
      debugPrint("successfully deleted values from $tableName table");
    }
  }

  static Future<void> tablePosted() async {
    try {
      Database db = await instance.database;
      await db.execute("UPDATE [Order] SET isPosted=1");
      await db.execute("UPDATE [OrderDetail] SET isPosted=1");
      await db.execute("UPDATE [Recovery] SET isPosted=1");
      await db.execute("UPDATE [Customer] SET isPosted=1");
    } catch (e) {
      debugPrint("Error During posting update");
    }
  }
}
