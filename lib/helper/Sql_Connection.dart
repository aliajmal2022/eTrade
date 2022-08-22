import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:dart_ping/dart_ping.dart';
import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/sharePreferences.dart';
import 'package:eTrade/entities/Order.dart';
import 'package:eTrade/entities/OrderDetail.dart';
import 'package:eTrade/entities/Recovery.dart';
import 'package:eTrade/entities/Sale.dart';
import 'package:eTrade/entities/SaleDetail.dart';
import 'package:eTrade/helper/onldt_to_local_db.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:eTrade/entities/User.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/SaleDetailScreen.dart';
import 'package:eTrade/screen/NavigationScreen/DashBoard/SetTarget.dart';
import 'package:eTrade/screen/NavigationScreen/Take Order/TakeOrderScreen.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/RecoveryScreen.dart';
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
      await SqlConn.connect(
          ip: ip,
          port: port,
          // databaseName: "7495_ePharma",
          // username: "7495_ePharmaUser",
          // password: "ePharma@1234");
          databaseName: "AGENBAKE2021",
          username: "sa",
          password: "exapp");

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
      if (MyNavigationBar.isAdmin) {
        List<Order> LOOrder = [];
        List<OrderDetail> LOOrderDetail = [];
        List<Sale> LOSale = [];
        List<SaleDetail> LOSaleDetail = [];
        List<Recovery> LORecovey = [];
        UserTarget userTarget = UserTarget.initializer();
        var userTargetList =
            await Sql_Connection().read("Select * from dbo_m.SaleRapTarget") ??
                [];
        if (userTargetList.isNotEmpty) {
          userTarget.userID = userTargetList[0]['SRID'];
          userTarget.januaryTarget = userTargetList[0]['January'];
          userTarget.februaryTarget = userTargetList[0]['February'];
          userTarget.marchTarget = userTargetList[0]['March'];
          userTarget.aprilTarget = userTargetList[0]['April'];
          userTarget.mayTarget = userTargetList[0]['May'];
          userTarget.juneTarget = userTargetList[0]['June'];
          userTarget.julyTarget = userTargetList[0]['July'];
          userTarget.augustTarget = userTargetList[0]['August'];
          userTarget.septemberTarget = userTargetList[0]['September'];
          userTarget.octoberTarget = userTargetList[0]['October'];
          userTarget.novemberTarget = userTargetList[0]['November'];
          userTarget.decemberTarget = userTargetList[0]['December'];
        }
        LOOrder = await Order.OrderForAdmin(false);
        LOOrderDetail = await OrderDetail.OrderDetailForAdmin(false);
        LOSale = await Sale.SaleForAdmin(false);
        LOSaleDetail = await SaleDetail.SaleDetailForAdmin(false);
        LORecovey = await Recovery.RecoveryForAdmin(false);

        LOOrder.forEach((element) async {
          await SQLHelper.instance.createOrderForAdmin(element);
        });
        LOOrderDetail.forEach((element) async {
          await SQLHelper.instance.createOrderDetailForAdmin(element);
        });
        LOSale.forEach((element) async {
          await SQLHelper.instance.createSaleForAdmin(element);
        });
        LOSaleDetail.forEach((element) async {
          await SQLHelper.instance.createSaleDetailForAdmin(element);
        });
        LORecovey.forEach((element) async {
          await SQLHelper.instance.createRecoveryitemForAdmin(element);
        });
        await SQLHelper.instance.createUserTargetForAdmin(userTarget);
      }
      await SQLHelper.deleteDataDuringSync(MyNavigationBar.userID);
    }
  }
}
