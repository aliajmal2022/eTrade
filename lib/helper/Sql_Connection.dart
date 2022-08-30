import 'dart:convert';
import 'dart:io';
import 'package:dart_ping/dart_ping.dart';
import 'package:etrade/components/NavigationBar.dart';
import 'package:etrade/components/sharePreferences.dart';
import 'package:etrade/entities/Order.dart';
import 'package:etrade/entities/OrderDetail.dart';
import 'package:etrade/entities/Recovery.dart';
import 'package:etrade/entities/Sale.dart';
import 'package:etrade/entities/SaleDetail.dart';
import 'package:etrade/helper/onldt_to_local_db.dart';
import 'package:etrade/helper/sqlhelper.dart';
import 'package:etrade/entities/Customer.dart';
import 'package:etrade/entities/Products.dart';
import 'package:etrade/entities/User.dart';
import 'package:etrade/screen/Connection/ConnectionScreen.dart';
import 'package:etrade/screen/NavigationScreen/Booking/SaleDetailScreen.dart';
import 'package:etrade/screen/NavigationScreen/DashBoard/SetTarget.dart';
import 'package:etrade/screen/NavigationScreen/Take Order/TakeOrderScreen.dart';
import 'package:etrade/screen/NavigationScreen/RecoveryBooking/RecoveryScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sql_conn/sql_conn.dart';

class Sql_Connection {
  var jsonres;

  static const bool _isconnected = false;
  static Future<bool> connect(BuildContext ctx, String ip, String port) async {
    bool isConnect = false;
    // ip: "92.53.240.78,1433"
    debugPrint("Connecting...");
    try {
      if (ConnectionScreen.isLocal) {
        await SqlConn.connect(
            ip: ip,
            port: port,
            databaseName: "AGENBAKE2021",
            username: "sa",
            password: "exapp");
      } else {
        await SqlConn.connect(
            ip: ip,
            port: port,
            databaseName: "7495_ePharma",
            username: "7495_ePharmaUser",
            password: "ePharma@1234");
      }

      isConnect = true;
      debugPrint("Connected!");
    } catch (e) {
      debugPrint(e.toString());
    }
    return isConnect;
  }

  Future<void> write(String query) async {
    try {
      var res = await SqlConn.writeData(query);
      print(res.toString());
    } catch (e) {
      print("Error ::::: ${e.toString()}");
    }
  }

  Future<dynamic> read(String query) async {
    try {
      String res = await SqlConn.readData(query);
      jsonres = json.decode(res);

      return jsonres;
    } catch (e) {
      print(e);
    }
  }

  static Future<void> PreLoadData(bool isSync) async {
    TakeOrderScreen.isSync = true;
    RecoveryScreen.isSync = true;
    List<Customer> LOCustomer = [];
    List<Product> LOProduct = [];
    List<User> LOUser = [];
    LOProduct = await Product.ProductLOdb(false);
    LOCustomer = await Customer.CustomerLOdb(false);
    LOUser = await User.UserList(false);
    if (_isconnected && LOCustomer.isNotEmpty && LOCustomer.isNotEmpty ||
        LOUser.isNotEmpty) {
      if (UserSharePreferences.getflag()) {
        if (!isSync || MyNavigationBar.isAdmin) {
          for (var element in LOUser) {
            await SQLHelper.instance.createUser(element);
          }
        }
        LOCustomer.forEach((element) async {
          await SQLHelper.instance.createParty(element);
        });
        LOProduct.forEach((element) async {
          await SQLHelper.instance.createItem(element);
        });
      }
      if (!MyNavigationBar.isAdmin) {
        UserTarget userTarget = await UserTarget.getUserTarget();
        await SQLHelper.instance.createUserTargetForAdmin(userTarget);
      } else {
        List<UserTarget> LOUserTarget = await UserTarget.getListUserTarget();
        LOUserTarget.forEach((element) async {
          await SQLHelper.instance.createUserTargetForAdmin(element);
        });
      }
      await SQLHelper.deleteDataDuringSync(MyNavigationBar.userID);
    }
  }
}
