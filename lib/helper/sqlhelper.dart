import 'dart:io';

import 'package:eTrade/components/sharePreferences.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Order.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:eTrade/entities/Recovery.dart';
import 'package:eTrade/entities/Sale.dart';
import 'package:eTrade/entities/User.dart';
import 'package:eTrade/screen/NavigationScreen/DashBoard/SetTarget.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  static bool existDataBase = false;

  static bool onceCheck = true;
  static var path;
  static Future<Database> checkDBExit() async {
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

  static backupDB() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;
    if (!status1.isGranted) {
      await Permission.storage.request();
    }
    try {
      File ourDBFile = File('$directory/eTrade.db');
      Directory folderPathForDB =
          Directory('/storage/emulated/0/eTrade_Backup/');
      if (!await folderPathForDB.exists()) await folderPathForDB.create();
      await ourDBFile.copy('/storage/emulated/0/eTrade_Backup/eTrade.db');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static restoreDB() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;
    if (!status1.isGranted) {
      await Permission.storage.request();
    }
    try {
      File savedDBFile = File('/storage/emulated/0/eTrade_Backup/eTrade.db');
      await savedDBFile.copy('$directory/eTrade.db');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> resetData(String action, bool isLogin) async {
    if (action == "Sync" && !isLogin) {
      await deleteTable(_database, "Party", true);
      await deleteTable(_database, "Item", true);
    } else if (action == "Sync" && isLogin) {
      await deleteTable(_database, "Party", false);
      await deleteTable(_database, "Item", false);
    } else {
      await deleteTable(_database, "Party", false);
      await deleteTable(_database, "Order", false);
      await deleteTable(_database, "User", false);
      await deleteTable(_database, "UserTarget", false);
      await deleteTable(_database, "Order", false);
      await deleteTable(_database, "OrderDetail", false);
      await deleteTable(_database, "Sale", false);
      await deleteTable(_database, "SaleDetail", false);
      await deleteTable(_database, "Recovery", false);
    }
  }

  Future<dynamic> get database async {
    var db = await checkDBExit();
    return db;
  }

  static _initiateDatabase() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;
    if (!status1.isGranted) {
      await Permission.storage.request();
    }
    try {
      File savedDBFile = File('/storage/emulated/0/eTrade_Backup/eTrade.db');
      if (await savedDBFile.exists()) {
        await savedDBFile.copy('$directory/eTrade.db');
        UserSharePreferences.setmode(false);
        existDataBase = true;

        return await checkDBExit();
      } else {
        return await openDatabase(path, version: _dbversion,
            onOpen: (Database database) async {
          await createPartyTable(database);
          await createItemTable(database);
          await createUserTable(database);
          await createUserTargetTable(database);
          await createOrderTable(database);
          await createOrderDetailTable(database);
          await createSaleTable(database);
          await createSaleDetailTable(database);
          await createRecoveryTable(database);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> createUserTable(Database database) async {
    await database.execute('''
CREATE TABLE User(
  ID INTEGER PRIMARY KEY NOT NULL,
  UserName TEXT NOT NULL,
  Password TEXT NOT NULL
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

  static Future<void> createUserTargetTable(Database database) async {
    await database.execute('''
CREATE TABLE UserTarget(
  ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  January INTEGER NOT NULL,
  February INTEGER NOT NULL,
  March INTEGER NOT NULL,
  April INTEGER NOT NULL,
  May INTEGER NOT NULL,
  June INTEGER NOT NULL,
  July INTEGER NOT NULL,
  August INTEGER NOT NULL,
  September INTEGER NOT NULL,
  October INTEGER NOT NULL,
  November INTEGER NOT NULL,
  December INTEGER NOT NULL
  )
   ''');
    print("successfully created UserTarget table");
  }

  Future<int> createUserTarget(UserTarget target) async {
    Database db = await instance.database;
    final data = {
      'January': target.januaryTarget,
      'February': target.februaryTarget,
      'March': target.marchTarget,
      'April': target.aprilTarget,
      'May': target.mayTarget,
      'June': target.juneTarget,
      'July': target.julyTarget,
      'August': target.augustTarget,
      'September': target.septemberTarget,
      'October': target.octoberTarget,
      'November': target.novemberTarget,
      'December': target.decemberTarget,
    };
    return await db.insert('UserTarget', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateUserTargetTable(UserTarget userTarget) async {
    Database db = await instance.database;
    try {
      await db.execute(
          "UPDATE [UserTarget] SET January=${userTarget.januaryTarget} , February=${userTarget.februaryTarget},March=${userTarget.marchTarget},April=${userTarget.aprilTarget},May=${userTarget.mayTarget},June=${userTarget.juneTarget},July=${userTarget.julyTarget},August=${userTarget.augustTarget},September=${userTarget.septemberTarget},October=${userTarget.octoberTarget},November=${userTarget.novemberTarget},December=${userTarget.decemberTarget} WHERE ID = 1");
    } catch (e) {
      debugPrint('Target is not update');
    }
  }

  static Future<void> createPartyTable(Database database) async {
    await database.execute('''
  CREATE TABLE Party(
	PartyID INTEGER PRIMARY KEY NOT NULL,
  PartyID_Mobile INTEGER,
	UserID INTEGER NOT NULL,
	PartyName TEXT NOT NULL,
  Discount REAL,
  isPosted BOOLEAN NOT NULL CHECK (isPosted IN (0, 1)),
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
      'PartyID_Mobile': customer.partyIdMobile,
      'UserID': customer.userId,
      'isPosted': isPosted,
      'Address': customer.address,
    };
    return await db.insert('Party', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List> getNotPostedParty() async {
    Database db = await instance.database;
    return await db.rawQuery(
        "SELECT * FROM Party WHERE PartyID BETWEEN 2201 and 2999 and isPosted=0");
  }

  static Future<void> deleteDataDuringSync(int id) async {
    Database db = await instance.database;
    try {
      await db.rawDelete(
          "Delete from Party where PartyID in (select PartyID_Mobile from Party where UserID=$id and ifnull(Partyid_mobile,0)>0)");
      // await db.execute(
      //     "UPDATE [Order] SET PartyID =p.PartyId FROM [Order] AS o INNER JOIN Party AS p ON p.PartyId_Mobile = o.PartyID WHERE o.PartyID BETWEEN 2200 AND 2999");
//       await db.execute("""
// UPDATE [Order] SET PartyID =(select p.PartyId from Party AS p WHERE ifnull(p.PartyId_Mobile,0)>0 and p.PartyId_Mobile =PartyID)
// WHERE exists (select PartyID from Party where PartyID_Mobile=[Order].PartyId)
// and PartyID BETWEEN 2200 AND 2999
// """);
// UPDATE Sale
// SET
// PartyID =p.PartyId
// FROM [Sale] AS s
// INNER JOIN Party AS p ON p.PartyId_Mobile = s.PartyID
// WHERE s.PartyID BETWEEN 2200 AND 2999
//       await db.execute("""UPDATE recovery
// SET
// PartyID =p.PartyId
// FROM [recovery] AS r
// INNER JOIN Party AS p ON p.PartyId_Mobile = r.PartyID
// WHERE r.PartyID BETWEEN 2200 AND 2999""");
    } catch (e) {
      print("error :::::::: ${e.toString()}");
    }
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
Dated DATE NOT NULL,
Description TEXT,
isPosted BOOLEAN NOT NULL CHECK (isPosted IN (0, 1))
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

  static Future<List> getNotPostedOrder() async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT * FROM [Order] WHERE isPosted=0");
  }

  static Future<List> getFromToViewOrder(String start, String end) async {
    Database db = await instance.database;
    var splitDate = start.split('-');
    start = '${splitDate[2]}-${splitDate[1]}-${splitDate[0]}';
    splitDate = end.split('-');
    end = '${splitDate[2]}-${splitDate[1]}-${splitDate[0]}';
    var listOrder = await db.rawQuery(
        "SELECT strftime('%d-%m-%Y', o.Dated)  as Dated,o.OrderID,o.TotalQuantity,p.PartyName FROM [Order] AS o INNER JOIN Party AS p ON p.PartyID = o.PartyID WHERE o.Dated BETWEEN '$start' AND '$end'  ");

    return listOrder;
  }

  static Future<List> getSpecificViewOrder(var date) async {
    Database db = await instance.database;
    var splitDate = date.split('-');
    date = '${splitDate[2]}-${splitDate[1]}-${splitDate[0]}';
    var listOrder = await db.rawQuery(
        "SELECT strftime('%d-%m-%Y', o.Dated)  as Dated,o.OrderID,o.TotalQuantity,p.PartyName FROM [Order] AS o INNER JOIN Party AS p ON p.PartyID = o.PartyID WHERE o.Dated ='${date}' ");

    return listOrder;
  }

  static Future<List> getAllViewOrder() async {
    Database db = await instance.database;
    var listOrder = await db.rawQuery(
        "SELECT strftime('%d-%m-%Y', o.Dated)  as Dated,o.OrderID,o.TotalQuantity,p.PartyName FROM [Order] AS o INNER JOIN Party AS p ON p.PartyID = o.PartyID  ");

    return listOrder;
  }

  static Future<List> getMonthOrderHistory() async {
    Database db = await instance.database;
    var listOrder = await db.rawQuery(
        "SELECT IFNULL(SUM(CASE WHEN strftime('%m', dated) = '01' THEN o.Amount END),0) AS Jan,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '02' THEN o.Amount END),0) as Feb,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '03' THEN o.Amount END),0) as Mar,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '04' THEN o.Amount END),0) as Apr,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '05' THEN o.Amount END),0) as May,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '06' THEN o.Amount END),0) as Jun,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '07' THEN o.Amount END),0) as Jul,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '08' THEN o.Amount END),0) as Aug,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '09' THEN o.Amount END),0) as Sep,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '10' THEN o.Amount END),0) as Oct,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '11' THEN o.Amount END),0) as Nov,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '12' THEN o.Amount END),0) as [Dec] FROM OrderDetail o where strftime('%Y',Dated) = strftime('%Y',Date())");
    return listOrder;
  }

  static Future<List> getTopTenProductByOrder() async {
    Database db = await instance.database;
    var listOrder = await db.rawQuery(
        "SELECT od.ItemID,i.ItemName,sum(od.Quantity) as Quantity , sum(od.Amount) as Amount FROM  OrderDetail as od INNER JOIN Item as i on od.ItemID=i.ItemID group by od.ItemID,i.ItemName order by sum(od.Amount) DESC LIMIT   10");
    return listOrder;
  }

  static Future<List> getTopTenProductBySale() async {
    Database db = await instance.database;
    var listOrder = await db.rawQuery(
        "SELECT sd.ItemID,i.ItemName,sum(sd.Quantity) as Quantity , sum(sd.Amount) as Amount FROM  SaleDetail as sd INNER JOIN Item as i on sd.ItemID=i.ItemID group by sd.ItemID,i.ItemName order by sum(sd.Amount) DESC LIMIT   10");
    return listOrder;
  }

  static Future<void> updateOrderTable(
      int id, int partyID, String description) async {
    Database db = await instance.database;
    try {
      await db.execute(
          "UPDATE [Order] SET TotalQuantity = 	(SELECT Sum(Quantity) FROM OrderDetail as od WHERE  od.OrderID=$id), TotalValue= (SELECT Sum(Amount) FROM OrderDetail as od WHERE  od.OrderID=$id),Description='$description',PartyID=$partyID WHERE OrderID=$id "

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
  TradeOffer Real,
  Amount REAL NOT NULL,
	Dated DATE NOT NULL,
isPosted BOOLEAN NOT NULL CHECK (isPosted IN (0, 1))
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
      'TradeOffer': product.to,
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

  static Future<List> getNotPostedOrderDetail() async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT * FROM OrderDetail WHERE isPosted=0");
  }

  static Future<List> getOrderDetail(int id) async {
    Database db = await instance.database;
    var ListOrder = await db.rawQuery(
        "SELECT i.ItemName, od.Bonus,od.Discount,od.TradeOffer,od.Quantity,od.Rate,od.Amount,i.itemID,o.Description FROM OrderDetail as od LEFT JOIN Item AS i ON i.ItemID = od.ItemID LEFT JOIN [Order] AS o ON o.OrderID=od.OrderID WHERE od.OrderID=$id and od.isPosted=0");

    return ListOrder;
  }

  static Future<void> createSaleTable(Database database) async {
    await database.execute('''
CREATE TABLE Sale(
InvoiceID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
PartyID INTEGER NOT NULL,
UserID INTEGER NOT NULL,
TotalQuantity INTEGER NOT NULL,
TotalValue REAL NOT NULL,
Dated DATE NOT NULL,
Description TEXT,
isCashInvoice BOOLEAN NOT NULL CHECK (isCashInvoice IN (0, 1)) ,
isPosted BOOLEAN NOT NULL CHECK (isPosted IN (0, 1))
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
      'isCashInvoice': sale.isCash,
      'TotalValue': sale.totalValue,
      'Dated': sale.date,
      'isPosted': isPost,
    };
    final id = await db.insert('Sale', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List> getNotPostedSale() async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT * FROM Sale WHERE isPosted=0");
  }

  static Future<List> getMonthSaleHistory() async {
    Database db = await instance.database;
    var listOrder = await db.rawQuery(
        "SELECT IFNULL(SUM(CASE WHEN strftime('%m', dated) = '01' THEN s.Amount END),0) AS Jan,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '02' THEN s.Amount END),0) as Feb,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '03' THEN s.Amount END),0) as Mar,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '04' THEN s.Amount END),0) as Apr,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '05' THEN s.Amount END),0) as May,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '06' THEN s.Amount END),0) as Jun,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '07' THEN s.Amount END),0) as Jul,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '08' THEN s.Amount END),0) as Aug,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '09' THEN s.Amount END),0) as Sep,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '10' THEN s.Amount END),0) as Oct,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '11' THEN s.Amount END),0) as Nov,IFNULL(SUM(CASE WHEN strftime('%m', dated) = '12' THEN s.Amount END),0) as [Dec] FROM SaleDetail s where strftime('%Y',Dated) = strftime('%Y',Date())");
    return listOrder;
  }

  static Future<List> getFromToViewSale(var start, var end) async {
    Database db = await instance.database;
    var splitDate = start.split('-');
    start = '${splitDate[2]}-${splitDate[1]}-${splitDate[0]}';
    splitDate = end.split('-');
    end = '${splitDate[2]}-${splitDate[1]}-${splitDate[0]}';
    var listOrder = await db.rawQuery(
        "SELECT strftime('%d-%m-%Y', s.Dated)  as Dated,s.InvoiceID,s.TotalQuantity,p.PartyName FROM Sale AS s INNER JOIN Party AS p ON p.PartyID = s.PartyID WHERE s.Dated BETWEEN '$start' AND '$end' ");

    return listOrder;
  }

  static Future<List> getSpecificViewSale(var date) async {
    Database db = await instance.database;
    var splitDate = date.split('-');
    date = '${splitDate[2]}-${splitDate[1]}-${splitDate[0]}';
    var listOrder = await db.rawQuery(
        "SELECT strftime('%d-%m-%Y', s.Dated)  as Dated,s.InvoiceID,s.TotalQuantity,p.PartyName FROM Sale AS s INNER JOIN Party AS p ON p.PartyID = s.PartyID WHERE s.Dated ='${date}' ");

    return listOrder;
  }

  static Future<List> getAllViewSale() async {
    Database db = await instance.database;
    var listOrder = await db.rawQuery(
        "SELECT strftime('%d-%m-%Y', s.Dated)  as Dated,s.InvoiceID,s.TotalQuantity,p.PartyName FROM Sale AS s INNER JOIN Party AS p ON s.PartyID = p.PartyID ");

    return listOrder;
  }

  static Future<void> updateSaleTable(
      int id, int partyID, String description, bool isCash) async {
    int iscash = isCash ? 1 : 0;
    Database db = await instance.database;
    try {
      await db.execute(
          "UPDATE Sale SET TotalQuantity = 	(SELECT Sum(sd.Quantity) FROM SaleDetail as sd WHERE  sd.InvoiceID=$id), TotalValue= (SELECT Sum(sd.Amount) FROM SaleDetail as sd WHERE  sd.InvoiceID=$id),Description='$description',PartyID=$partyID,isCashInvoice='$iscash' WHERE InvoiceID=$id "

          // "UPDATE [Order] SET  PartyID=$partyID,Description='$description',TotalQuantity = (SELECT Sum(Quantity) FROM OrderDetail , [Order] as o WHERE o.OrderID = OrderDetail.OrderID and o.OrderID=$id),TotalValue=(SELECT Sum(Amount) FROM OrderDetail , [Order] as o WHERE o.OrderID = OrderDetail.OrderID and o.OrderID=$id) WHERE [Order].OrderID=$id"
          );
    } catch (e) {
      debugPrint('Order is not update \n ${e.toString()}');
    }
  }

  static Future<void> createSaleDetailTable(Database database) async {
    await database.execute('''
  CREATE TABLE SaleDetail(
	ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  InvoiceID INTEGER NOT NULL,
	UserID INTEGER NOT NULL,
	ItemID TEXT NOT NULL,
  Quantity INTEGER NOT NULL,
  RATE REAL NOT NULL,
  Discount REAL,
  Bonus INTEGER,
  TradeOffer Real,
  Amount REAL NOT NULL,
	Dated DATE NOT NULL,
isPosted BOOLEAN NOT NULL CHECK (isPosted IN (0, 1))
 )
      ''');
    print("successfully created SaleDetail table");
  }

  Future<int> createSaleDetail(Product product, int InvoiceID, String date,
      bool isPost, int userID) async {
    Database db = await instance.database;

    final data = {
      'UserID': userID,
      'InvoiceID': InvoiceID,
      'Discount': product.discount,
      'Bonus': product.bonus,
      'TradeOffer': product.to,
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

  static Future<List> getNotPostedSaleDetail() async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT * FROM SaleDetail WHERE isPosted=0");
  }

  static Future<List> getSaleDetail(int id) async {
    Database db = await instance.database;
    var ListOrder = await db.rawQuery(
        "SELECT i.ItemName,sd.Bonus,sd.Discount,sd.TradeOffer,sd.Quantity,sd.Rate,sd.Amount,i.itemID,s.Description,s.isCashInvoice FROM SaleDetail as sd LEFT JOIN Item AS i ON i.ItemID = sd.ItemID LEFT JOIN Sale AS s ON sd.InvoiceID=s.InvoiceID WHERE sd.InvoiceID=$id and sd.isPosted=0");

    return ListOrder;
  }

  static Future<void> createRecoveryTable(Database database) async {
    await database.execute('''
CREATE TABLE Recovery(
RecoveryID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
PartyID INTEGER NOT NULL,
UserID INTEGER NOT NULL,
Amount REAL NOT NULL,
Dated DATE NOT NULL,
isCash BOOLEAN NOT NULL CHECK (isCash IN (0, 1)) ,
Description TEXT,
isPosted BOOLEAN NOT NULL CHECK (isPosted IN (0, 1))
  )
      ''');
    print("successfully created Recovery table");
  }

  Future<int> createRecoveryitem(Recovery recovery, bool isPost) async {
    Database db = await instance.database;

    final data = {
      'PartyID': recovery.party.partyId,
      'UserID': recovery.userID,
      'isCash': recovery.isCashOrCheck,
      'Description': recovery.description,
      'Dated': recovery.dated,
      'Amount': recovery.amount,
      'isPosted': isPost,
    };
    final id = await db.insert('Recovery', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List> getNotPostedRecovery() async {
    Database db = await instance.database;
    return await db.rawQuery("SELECT * FROM Recovery WHERE isPosted=0");
  }

  static Future<List> getFromToRecovery(var start, var end) async {
    var splitDate = start.split('-');
    start = '${splitDate[2]}-${splitDate[1]}-${splitDate[0]}';
    splitDate = end.split('-');
    end = '${splitDate[2]}-${splitDate[1]}-${splitDate[0]}';
    Database db = await instance.database;
    var listRecovery = await db.rawQuery(
        "SELECT strftime('%d-%m-%Y', r.Dated)  as Dated,r.isCash,r.Description,r.RecoveryID,r.Amount,p.PartyName,p.PartyID FROM Recovery AS r INNER JOIN Party AS p ON p.PartyID = r.PartyID WHERE r.Dated BETWEEN '$start' AND '$end' ");

    return listRecovery;
  }

  static Future<List> getSpecificRecovery(var date) async {
    Database db = await instance.database;
    var splitDate = date.split('-');
    date = '${splitDate[2]}-${splitDate[1]}-${splitDate[0]}';
    var listRecovery = await db.rawQuery(
        "SELECT strftime('%d-%m-%Y', r.Dated)  as Dated,r.isCash,r.Description,r.RecoveryID,r.Amount,p.PartyName,p.PartyID FROM Recovery AS r INNER JOIN Party AS p ON p.PartyID = r.PartyID WHERE r.Dated = '$date'");

    return listRecovery;
  }

  static Future<List> getAllRecovery() async {
    Database db = await instance.database;
    var listRecovery = await db.rawQuery(
        "SELECT strftime('%d-%m-%Y', r.Dated)  as Dated,r.isCash,r.Description,r.RecoveryID,r.Amount,p.PartyName,p.PartyID FROM Recovery AS r INNER JOIN Party AS p ON p.PartyID = r.PartyID ");

    return listRecovery;
  }

  static Future<void> updateRecoveryTable(int id, int partyID, double amount,
      String description, bool isCash) async {
    Database db = await instance.database;
    int iscash = isCash ? 1 : 0;
    try {
      await db.execute(
          "UPDATE Recovery SET Amount=$amount, PartyID=$partyID,isCash=$iscash,Description='$description' WHERE RecoveryID=$id ");
    } catch (e) {
      debugPrint(e.toString());
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

  static Future<int> getSaleCount(String name, String date) async {
    var db = await instance.database;
    int count = 0;

    var splitDate = date.split('-');
    date = '${splitDate[2]}-${splitDate[1]}-${splitDate[0]}';
    var order;
    try {
      if (name == "Week") {
        order = await db.rawQuery(
            "SELECT count(s.InvoiceID) FROM Sale as s WHERE s.Dated BETWEEN  DATETIME('$date','-6 day') and DATETIME('$date','localtime')");
      } else if (name == "PWeek") {
        order = await db.rawQuery(
            "SELECT count(s.InvoiceID) FROM Sale as s WHERE s.Dated BETWEEN  DATETIME('$date','-13 day') and DATETIME('$date','-6 day')");
      } else if (name == "Month") {
        order = await db.rawQuery(
            "SELECT count(s.InvoiceID) FROM Sale as s WHERE s.Dated BETWEEN  DATETIME('$date','-1 month') and DATETIME('$date','localtime')");
      } else if (name == "PMonth") {
        order = await db.rawQuery(
            "SELECT count(s.InvoiceID) FROM Sale as s WHERE s.Dated BETWEEN  DATETIME('$date','-2 month') and DATETIME('$date','-1 month')");
      } else if (name == "Year") {
        order = await db.rawQuery(
            "SELECT count(s.InvoiceID) FROM Sale as s WHERE s.Dated BETWEEN  DATETIME('$date','-1 year') and DATETIME('$date','localtime')");
      } else if (name == "PYear") {
        order = await db.rawQuery(
            "SELECT count(s.InvoiceID) FROM Sale as s WHERE s.Dated BETWEEN  DATETIME('$date','-2 year') and DATETIME('$date','-1 year')");
      } else {
        order = await db.rawQuery(
            "SELECT count(s.InvoiceID) FROM Sale as s WHERE s.Dated='$date'");
      }
      if (order.isNotEmpty) {
        var iterable = order.whereType<Map>().first;

        count = iterable['count(s.InvoiceID)'];
      }
    } catch (e) {
      debugPrint("$e");
    }

    return count;
  }

  static Future<int> getOrderCount(String name, String date) async {
    var db = await instance.database;
    int count = 0;

    var splitDate = date.split('-');
    date = '${splitDate[2]}-${splitDate[1]}-${splitDate[0]}';
    var order;
    try {
      if (name == "Week") {
        order = await db.rawQuery(
            "SELECT count(o.OrderID) FROM [Order] as o WHERE o.Dated BETWEEN  DATETIME('$date','-6 day') and DATETIME('$date','localtime')");
      } else if (name == "PWeek") {
        order = await db.rawQuery(
            "SELECT count(o.OrderID) FROM [Order] as o WHERE o.Dated BETWEEN  DATETIME('$date','-13 day') and DATETIME('$date','-6 day')");
      } else if (name == "Month") {
        order = await db.rawQuery(
            "SELECT count(o.OrderID) FROM [Order] as o WHERE o.Dated BETWEEN  DATETIME('$date','-1 month') and DATETIME('$date','localtime')");
      } else if (name == "PMonth") {
        order = await db.rawQuery(
            "SELECT count(o.OrderID) FROM [Order] as o WHERE o.Dated BETWEEN  DATETIME('$date','-2 month') and DATETIME('$date','-1 month')");
      } else if (name == "Year") {
        order = await db.rawQuery(
            "SELECT count(o.OrderID) FROM [Order] as o WHERE o.Dated BETWEEN  DATETIME('$date','-1 year') and DATETIME('$date','localtime')");
      } else if (name == "PYear") {
        order = await db.rawQuery(
            "SELECT count(o.OrderID) FROM [Order] as o WHERE o.Dated BETWEEN  DATETIME('$date','-2 year') and DATETIME('$date','-1 year')");
      } else {
        order = await db.rawQuery(
            "SELECT count(o.OrderID) FROM [Order] as o WHERE o.Dated='$date'");
      }
      if (order.isNotEmpty) {
        var iterable = order.whereType<Map>().first;

        count = iterable['count(o.OrderID)'];
      }
    } catch (e) {
      debugPrint("$e");
    }

    return count;
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
        tableName == "Sale" ||
        tableName == "SaleDetail" ||
        tableName == "Recovery") {
      return db.query(tableName, orderBy: id, where: "isPosted=0");
    } else {
      return db.query(tableName, orderBy: id);
    }
  }

  static Future<void> deleteTable(
      Database database, String tableName, bool isSync) async {
    try {
      if (tableName == "Party" && isSync) {
        int id = await database.rawDelete("""
  DELETE FROM $tableName WHERE PartyID > 2999
      """);
        var list = instance.getTable("Party", "PartyID");
        print(list);
      } else {
        await database.execute("""
  DELETE FROM [$tableName]
      """);
      }
    } catch (e) {
      debugPrint("successfully deleted values from $tableName table");
    }
  }

  static Future<void> tablenotPosted() async {
    try {
      Database db = await instance.database;
      await db.execute("UPDATE [Order] SET isPosted=0");
      await db.execute("UPDATE [OrderDetail] SET isPosted=0");
      await db.execute("UPDATE [Recovery] SET isPosted=0");
      await db.execute("UPDATE [Party] SET isPosted=0");
      await db.execute("UPDATE [Sale] SET isPosted=0");
      await db.execute("UPDATE [SaleDetail] SET isPosted=0");
    } catch (e) {
      debugPrint("Error During posting update");
    }
  }

  static Future<void> tablePosted() async {
    try {
      Database db = await instance.database;
      await db.execute("UPDATE [Order] SET isPosted=1");
      await db.execute("UPDATE [OrderDetail] SET isPosted=1");
      await db.execute("UPDATE [Recovery] SET isPosted=1");
      await db.execute("UPDATE [Party] SET isPosted=1");
      await db.execute("UPDATE [Sale] SET isPosted=1");
      await db.execute("UPDATE [SaleDetail] SET isPosted=1");
    } catch (e) {
      debugPrint("Error During posting update");
    }
  }
}
