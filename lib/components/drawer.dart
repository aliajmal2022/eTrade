import 'dart:async';

import 'package:eTrade/components/NavigationBar.dart';
import 'package:date_format/date_format.dart';
import 'package:eTrade/helper/Sql_Connection.dart';
import 'package:eTrade/components/sharePreferences.dart';
import 'package:eTrade/helper/onldt_to_local_db.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/main.dart';
import 'package:eTrade/screen/Connection/ConnectionScreen.dart';

import 'package:eTrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:eTrade/screen/LoginScreen/LoginScreen.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/RecoveryScreen.dart';
import 'package:eTrade/screen/SplashScreen/SplashScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/ViewBookingScreen.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/ViewRecoveryScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sql_conn/sql_conn.dart';

class MyDrawer extends StatefulWidget {
  static bool isopen = false;
  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String ping = '';

  @override
  void initState() {
    ping = UserSharePreferences.getIp();
    super.initState();
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget progressButton = TextButton(
        child: const Text("OK"),
        onPressed: () async {
          if (ping.isNotEmpty) {
            var strToList = ping.split(",");
            var ip = strToList[0];
            var port = strToList[1];
            bool isconnected = await Sql_Connection.connect(context, ip, port);
            if (isconnected) {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginScreen(
                            ip: ping,
                            fromMasterReset: true,
                          )),
                  (route) => true);
            }
          } else {
            final snackBar = const SnackBar(
              content:
                  Text("Host unaccessible. Keep your device near to router."),
            );
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => MyNavigationBar(
                          editRecovery: ViewRecovery(
                              amount: 0,
                              description: "",
                              checkOrCash: "",
                              recoveryID: 0,
                              dated: "",
                              party: Customer(
                                  userId: 0,
                                  address: "",
                                  partyId: 0,
                                  partyName: "",
                                  discount: 0)),
                          selectedIndex: 0,
                          list: [],
                          date: "",
                          id: 0,
                          partyName: "Search Customer",
                        )),
                (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        });
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => MyNavigationBar(
                      editRecovery: ViewRecovery(
                          amount: 0,
                          checkOrCash: "",
                          description: "",
                          recoveryID: 0,
                          dated: "",
                          party: Customer(
                              address: "",
                              userId: 0,
                              partyId: 0,
                              partyName: "",
                              discount: 0)),
                      selectedIndex: 0,
                      date: "",
                      list: [],
                      partyName: "Search Customer",
                      id: 0,
                    )),
            (route) => false);
      },
    );
    // set up the AlertDialog
    List<Widget> LOWidget = [cancelButton, progressButton];
    AlertDialog alert = AlertDialog(
      title: const Text("All previous data will be lost."),
      content: const Text("  Do you want to proceed?"),
      actions: LOWidget,
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> onPostingLoading(
    BuildContext context,
  ) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoActivityIndicator(
            animating: true,
            radius: 30,
          );
          // return CircularProgressIndicator();
        });

    Future.delayed(const Duration(seconds: 3), () async {
      final snackBar;
      var strToList = ping.split(",");
      var ip = strToList[0];
      var port = strToList[1];
      bool isconnected = await Sql_Connection.connect(context, ip, port);
      if (isconnected) {
        snackBar = const SnackBar(
          content: Text("Posting is Completed."),
        );
        var _order = await SQLHelper.getNotPostedOrder();
        var _orderDetail = await SQLHelper.getNotPostedOrderDetail();
        var _recovery = await SQLHelper.getNotPostedRecovery();
        var _party = await SQLHelper.getNotPostedParty();
        var _sale = await SQLHelper.getNotPostedSale();
        var _saleDetail = await SQLHelper.getNotPostedSaleDetail();
        try {
          if (_order.isNotEmpty) {
            for (var element in _order) {
              String date = element['Dated'];

              await Sql_Connection().write(
                  "INSERT INTO dbo_m.[Order](OrderID,UserId,PartyID,TotalQuantity,TotalValue,Dated,[Description])VALUES( ${element['OrderID']} , ${element['UserID']} , ${element['PartyID']},${element['TotalQuantity']} ,${element['TotalValue']} , '${date}',	'${element['Description']}')");
            }
          }
          if (_orderDetail.isNotEmpty) {
            for (var element in _orderDetail) {
              String date = element['Dated'];
              await Sql_Connection().write(
                  "INSERT INTO dbo_m.[OrderDetail]( UserId ,OrderID, ItemID, Quantity, RATE, Amount, Dated) VALUES ( ${element['UserID']}, ${element['OrderID']} , '${element['ItemID']}', ${element['Quantity']},${element['RATE']} ,${element['Amount']} , '${date}') ");
            }
          }
          if (_recovery.isNotEmpty) {
            for (var element in _recovery) {
              String date = element['Dated'];
              await Sql_Connection().write(
                  " INSERT INTO dbo_m.[Recovery]( RecoveryID, UserId, PartyID, Amount, Dated, [Description]) VALUES ( ${element['RecoveryID']},${element['UserID']},${element['PartyID']},${element['Amount']},'${date}','${element['Description']}') ");
            }
          }
          if (_sale.isNotEmpty) {
            for (var element in _sale) {
              String date = element['Dated'];

              await Sql_Connection().write(
                  "INSERT INTO dbo_m.[Sale](InvoiceID,UserId,PartyID,isCashInvoice,TotalQuantity,TotalValue,Dated,[Description])VALUES( ${element['InvoiceID']} , ${element['UserID']} , ${element['PartyID']},${element['isCash']},${element['TotalQuantity']} ,${element['TotalValue']} , '${date}',	'${element['Description']}')");
            }
          }
          if (_saleDetail.isNotEmpty) {
            for (var element in _saleDetail) {
              String date = element['Dated'];
              await Sql_Connection().write(
                  "INSERT INTO dbo_m.[SaleDetail]( InvoiceID,UserId , ItemID, Quantity, RATE, Amount, Dated) VALUES ( ${element['InvoiceID']}, ${element['UserID']} , '${element['ItemID']}', ${element['Quantity']},${element['RATE']} ,${element['Amount']} , '${date}') ");
            }
          }
          if (_party.isNotEmpty) {
            for (var element in _party) {
              await Sql_Connection().write(
                  "INSERT INTO dbo_m.[Party](PartyID,UserId,PartyName,Discount,Address)VALUES( ${element['PartyID']} , ${element['UserID']} , '${element['PartyName']}',${element['Discount']} ,'${element['Address']}')");
            }
          }
          await SQLHelper.tablePosted();
          print("here we go");
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } catch (e) {
          debugPrint("Ops");
        }
      } else {
        // await SQLHelper.tableNotPosted();
        snackBar = const SnackBar(
          content: Text("Host unaccessible. Keep your device near to router."),
        );
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MyNavigationBar(
                    editRecovery: ViewRecovery(
                        amount: 0,
                        description: "",
                        recoveryID: 0,
                        checkOrCash: "",
                        dated: "",
                        party: Customer(
                            partyId: 0,
                            userId: 0,
                            partyName: "",
                            discount: 0,
                            address: "")),
                    selectedIndex: 0,
                    date: "",
                    list: [],
                    id: 0,
                    partyName: "Search Customer",
                  )),
          (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  bool isSwitched = MyApp.isDark;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
              child: Center(
            child: Text(
              "eTrade",
              style: TextStyle(fontSize: 40),
            ),
          )),
          Divider(
            thickness: 2,
            color: Color(0xff00620b),
          ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
//                 addBoolToSF() async {
// }

                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.nightlight_outlined),
                            Text(
                              "Dark Mode",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Switch(
                          value: isSwitched,
                          onChanged: (value) async {
                            setState(() {
                              isSwitched = value;
                              MyApp.isDark = isSwitched;
                              MyApp.themeNotifier.value =
                                  (MyApp.themeNotifier.value == ThemeMode.light)
                                      ? ThemeMode.dark
                                      : ThemeMode.light;
                            });
                            await UserSharePreferences.setmode(isSwitched);
                          },
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      await TakeOrderScreen.forSaleInVoice();
                      TakeOrderScreen.isSaleSpot = true;
                      TakeOrderScreen.isEditOrder = false;
                      TakeOrderScreen.isSelected = false;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyNavigationBar(
                                    editRecovery: ViewRecovery(
                                        amount: 0,
                                        description: "",
                                        recoveryID: 0,
                                        checkOrCash: "",
                                        dated: "",
                                        party: Customer(
                                            userId: 0,
                                            address: "",
                                            discount: 0,
                                            partyId: 0,
                                            partyName: "")),
                                    selectedIndex: 1,
                                    date: "",
                                    list: [],
                                    id: 0,
                                    partyName: "Search Customer",
                                  )));
                    },
                    child: Row(
                      children: const [Icon(Icons.bookmark), Text("Spot Sale")],
                    ),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      await TakeOrderScreen.forSaleInVoice();
                      ViewBookingScreen.isSaleBooking = true;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyNavigationBar(
                                    editRecovery: ViewRecovery(
                                        amount: 0,
                                        description: "",
                                        recoveryID: 0,
                                        dated: "",
                                        checkOrCash: "",
                                        party: Customer(
                                            address: "",
                                            userId: 0,
                                            discount: 0,
                                            partyId: 0,
                                            partyName: "")),
                                    selectedIndex: 2,
                                    date: "",
                                    list: [],
                                    id: 0,
                                    partyName: "Search Customer",
                                  )));
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.bookmark),
                        Text("View Sales")
                      ],
                    ),
                  ),
                  MaterialButton(
                      onPressed: () async {
                        if (ping.isNotEmpty) {
                          var strToList = ping.split(",");
                          var ip = strToList[0];
                          var port = strToList[1];
                          bool isconnected =
                              await Sql_Connection.connect(context, ip, port);
                          if (isconnected) {
                            TakeOrderScreen.onLoading(context, true);
                          }
                        } else {
                          final snackBar = const SnackBar(
                            content: Text(
                                "Host unaccessible. Keep your device near to router."),
                          );
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyNavigationBar(
                                        editRecovery: ViewRecovery(
                                            amount: 0,
                                            checkOrCash: "",
                                            description: "",
                                            recoveryID: 0,
                                            dated: "",
                                            party: Customer(
                                                userId: 0,
                                                partyId: 0,
                                                partyName: "",
                                                address: "",
                                                discount: 0)),
                                        selectedIndex: 0,
                                        date: "",
                                        list: [],
                                        id: 0,
                                        partyName: "Search Customer",
                                      )),
                              (route) => false);
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: Row(
                        children: const [Icon(Icons.sync), Text("Sync Data")],
                      )),
                  MaterialButton(
                      child: Row(
                        children: const [
                          Icon(Icons.lock_reset),
                          Text("Master Reset")
                        ],
                      ),
                      onPressed: () async {
                        await showAlertDialog(context);
                      }),
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ConnectionScreen(
                                    isConnectionfromdrawer: true,
                                  )));
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.cable_outlined),
                        Text("Make Connection")
                      ],
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyNavigationBar(
                                    editRecovery: ViewRecovery(
                                        amount: 0,
                                        description: "",
                                        recoveryID: 0,
                                        checkOrCash: "",
                                        dated: "",
                                        party: Customer(
                                            address: "",
                                            userId: 0,
                                            discount: 0,
                                            partyId: 0,
                                            partyName: "")),
                                    selectedIndex: 1,
                                    date: "",
                                    list: [],
                                    id: 0,
                                    partyName: "Search Customer",
                                  )));
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.bookmark),
                        Text("Order Booking")
                      ],
                    ),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      onPostingLoading(context);
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.bookmark_add),
                        Text("Post Bookings")
                      ],
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewRecoveryScreen()));
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.price_change_outlined),
                        Text("View Recovery")
                      ],
                    ),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      SQLHelper.tablenotPosted();
                    },
                    child: Row(
                      children: const [Icon(Icons.exit_to_app), Text("Logout")],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
