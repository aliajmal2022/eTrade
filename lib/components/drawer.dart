import 'dart:io';

import 'package:eTrade/components/CustomNavigator.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/screen/AboutUs/AboutScreen.dart';
import 'package:eTrade/screen/NavigationScreen/DashBoard/SetTarget.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:eTrade/components/NavigationBar.dart';
import 'package:date_format/date_format.dart';
import 'package:eTrade/components/PostingData.dart';
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
import 'package:share_plus/share_plus.dart';
import 'package:sql_conn/sql_conn.dart';

class MyDrawer extends StatefulWidget {
  static bool isopen = false;
  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer>
    with SingleTickerProviderStateMixin {
  String ping = '';

  var _animationController;
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animationController.forward();
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
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Center(child: CircularProgressIndicator());
                  });
              Future.delayed(Duration(seconds: 2), () async {
                await SQLHelper.resetData("Reset", false);
                Navigator.pushAndRemoveUntil(
                    context,
                    MyCustomRoute(
                        builder: (context) => ConnectionScreen(
                              isConnectionfromdrawer: false,
                            ),
                        slide: "Left"),
                    (route) => false);
              });
            }
          } else {
            final snackBar = const SnackBar(
              content:
                  Text("Host unaccessible. Keep your device near to router."),
            );
            Get.off(MyNavigationBar.initializer(0));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        });
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Get.off(MyNavigationBar.initializer(0));
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

  bool isSwitched = MyApp.isDark;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          FadeTransition(
            opacity: _animationController,
            child: DrawerHeader(
                child: CircleAvatar(
                    backgroundColor: Color(0xfffafafa),
                    child: Image.asset(
                      "images/logo.png",
                      fit: BoxFit.cover,
                      width: 200,
                    ))),
          ),
          Divider(
            thickness: 1,
            color: eTradeGreen,
          ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
                    .animate(_animationController),
                child: FadeTransition(
                  opacity: _animationController,
                  child: Column(
                    //                 addBoolToSF() async {
                    // }

                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 20),
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
                                      (MyApp.themeNotifier.value ==
                                              ThemeMode.light)
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
                          Navigator.pushAndRemoveUntil(
                              context,
                              MyCustomRoute(
                                  slide: "Left",
                                  builder: (context) =>
                                      MyNavigationBar.initializer(1)),
                              (route) => false);
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.bookmark),
                            Text("Spot Sale")
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          await TakeOrderScreen.forSaleInVoice();
                          ViewBookingScreen.isSaleBooking = true;
                          Navigator.pushAndRemoveUntil(
                              context,
                              MyCustomRoute(
                                  slide: "Left",
                                  builder: (context) =>
                                      MyNavigationBar.initializer(2)),
                              (route) => false);
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
                            bool isAvialable = await SQLHelper.isDPBeforeGet();
                            if (isAvialable) {
                              Widget okButton = TextButton(
                                child: const Text("OK"),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MyCustomRoute(
                                          builder: (context) =>
                                              MyNavigationBar.initializer(0),
                                          slide: "Left"),
                                      (route) => false);
                                },
                              );
                              // set up the AlertDialog
                              AlertDialog alert = AlertDialog(
                                title: const Text(
                                    "There is data which is not posted yet."),
                                content: const Text("  Please post the data."),
                                actions: [okButton],
                              );
                              // show the dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                            } else {
                              if (ping.isNotEmpty) {
                                var strToList = ping.split(",");
                                var ip = strToList[0];
                                var port = strToList[1];
                                bool isconnected = await Sql_Connection.connect(
                                    context, ip, port);
                                if (isconnected) {
                                  await TakeOrderScreen.onLoading(
                                      context, true, false);
                                }
                              } else {
                                final snackBar = const SnackBar(
                                  content: Text(
                                      "Host unaccessible. Keep your device near to router."),
                                );
                                Get.off(MyNavigationBar.initializer(0));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            }
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.arrow_downward),
                              Text("Get Data")
                            ],
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
                          TakeOrderScreen.isEditOrder = false;
                          TakeOrderScreen.isEditSale = false;
                          TakeOrderScreen.isSaleSpot = false;
                          TakeOrderScreen.isSelected = false;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MyNavigationBar.initializer(1)));
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
                          Get.to(PostingData(ping: ping));
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.arrow_upward),
                            Text("Post Data")
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          await SQLHelper.backupDB();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MyCustomRoute(
                                  slide: "Left",
                                  builder: (context) =>
                                      MyNavigationBar.initializer(0)),
                              (route) => false);
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.backup),
                            Text("Backup Data")
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          await SQLHelper.restoreDB();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MyCustomRoute(
                                  slide: "Left",
                                  builder: (context) =>
                                      MyNavigationBar.initializer(0)),
                              (route) => false);
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.restore),
                            Text("Restore Data")
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MyCustomRoute(
                                  slide: "Left",
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
                        onPressed:
                            // null,
                            () async {
                          File file = File('${SQLHelper.directory}/eTrade.db');
                          if (await file.exists()) {
                            await Share.shareFiles([(file.path)],
                                text: "Etrade Database");
                          }
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.share),
                            Text("Share DataBase")
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          Get.to(() => SetTargetScreen(),
                              transition: Transition.leftToRight);
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.exit_to_app),
                            Text("Set Target")
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          Get.to(() => AboutScreen(),
                              transition: Transition.leftToRight);
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline),
                            Text("About Us")
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          SQLHelper.tablenotPosted();
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.exit_to_app),
                            Text("Logout")
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
