import 'dart:io';

import 'package:eTrade/components/CustomNavigator.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/screen/AboutUs/AboutScreen.dart';
import 'package:eTrade/screen/NavigationScreen/DashBoard/SetTarget.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/CustomerBalance.dart';
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
  static bool makeConnection = false;
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

  showRestoreAlertDialog(BuildContext context) {
    // set up the button
    Widget progressButton = TextButton(
        child: const Text("OK"),
        onPressed: () async {
          await SQLHelper.restoreDB();
          Navigator.pushAndRemoveUntil(
              context,
              MyCustomRoute(
                  slide: "Left",
                  builder: (context) => MyNavigationBar.initializer(0)),
              (route) => false);
        });
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    List<Widget> LOWidget = [cancelButton, progressButton];
    AlertDialog alert = AlertDialog(
      title: const Text("Restore Database."),
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

  showBackupAlertDialog(BuildContext context) {
    // set up the button
    Widget progressButton = TextButton(
        child: const Text("OK"),
        onPressed: () async {
          await SQLHelper.backupDB();
          Navigator.pushAndRemoveUntil(
              context,
              MyCustomRoute(
                  slide: "Left",
                  builder: (context) => MyNavigationBar.initializer(0)),
              (route) => false);
        });
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    List<Widget> LOWidget = [cancelButton, progressButton];
    AlertDialog alert = AlertDialog(
      title: const Text("Backup Database."),
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

  showMasterResetAlertDialog(BuildContext context) {
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
                              isConnectionfromdrawer: true,
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
                child: Column(
              children: [
                Expanded(
                    flex: 5,
                    child: Image.asset(
                      "images/logo.png",
                      fit: BoxFit.cover,
                      width: 300,
                    )
                    // CircleAvatar(
                    // // backgroundColor: Color(0xfffafafa),
                    // backgroundColor: eTradeMainColor,
                    // maxRadius: 200,
                    // child: ),
                    ),
                Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "User Name : ",
                          style: TextStyle(
                              color: eTradeMainColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          MyNavigationBar.userName,
                          style: TextStyle(
                              color: eTradeMainColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ))
              ],
            )),
          ),
          Divider(
            thickness: 1,
            color: eTradeMainColor,
          ),
          Container(
              // padding: const EdgeInsets.all(2),
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
                  MyNavigationBar.isAdmin
                      ? Container()
                      : MaterialButton(
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
                  MyNavigationBar.isAdmin
                      ? Container()
                      : MaterialButton(
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
                      MyNavigationBar.isAdmin
                          ? Navigator.pushAndRemoveUntil(
                              context,
                              MyCustomRoute(
                                  slide: "Left",
                                  builder: (context) =>
                                      MyNavigationBar.initializer(1)),
                              (route) => false)
                          : Navigator.pushAndRemoveUntil(
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
                  MyNavigationBar.isAdmin
                      ? Container()
                      : MaterialButton(
                          child: Row(
                            children: const [
                              Icon(Icons.lock_reset),
                              Text("Customer Balance")
                            ],
                          ),
                          onPressed: () async {
                            // Get.off(() => CustomerBalanceScreen());
                            Navigator.pushAndRemoveUntil(
                                context,
                                MyCustomRoute(
                                    builder: (context) =>
                                        CustomerBalanceScreen(),
                                    slide: "Left"),
                                (route) => false);
                          }),
                  MyNavigationBar.isAdmin
                      ? Container()
                      : MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MyCustomRoute(
                                    slide: "Left",
                                    builder: (context) =>
                                        ViewRecoveryScreen()));
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
                        bool isAvialable = await SQLHelper.isDPBeforeGet();
                        if (isAvialable && !MyNavigationBar.isAdmin) {
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
                            title: const Text("Alert!"),
                            content:
                                const Text("Please post the data to proceed."),
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
                            bool isconnected =
                                await Sql_Connection.connect(context, ip, port);
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
                  MyNavigationBar.isAdmin
                      ? Container()
                      : MaterialButton(
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
                  !MyNavigationBar.isAdmin
                      ? Container()
                      : MaterialButton(
                          onPressed: () async {
                            Get.to(
                                () => SetTargetScreen(
                                      ping: ping,
                                    ),
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
                    onPressed: () {
                      MyDrawer.makeConnection = true;
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
                    onPressed: () async {
                      showBackupAlertDialog(context);
                    },
                    child: Row(
                      children: const [Icon(Icons.backup), Text("Backup Data")],
                    ),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      showRestoreAlertDialog(context);
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.restore),
                        Text("Restore Data")
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
                      child: Row(
                        children: const [
                          Icon(Icons.lock_reset),
                          Text("Master Reset")
                        ],
                      ),
                      onPressed: () async {
                        await showMasterResetAlertDialog(context);
                      }),
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
                  // MyNavigationBar.isAdmin?Container():
                  MaterialButton(
                    onPressed: () async {
                      // await SQLHelper.backupDB();
                      await SQLHelper.backupDB();
                      if (MyNavigationBar.isAdmin) {
                        MyNavigationBar.isAdmin = false;
                        UserSharePreferences.setisAdminOrNot(false);
                        UserSharePreferences.setflag(false);
                      }
                      await SQLHelper.deleteAllTableForAdmin();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MyCustomRoute(
                              builder: (context) => ConnectionScreen(
                                    isConnectionfromdrawer: true,
                                  ),
                              slide: "Left"),
                          (route) => false);
                      // SQLHelper.tablenotPosted();
                    },
                    child: Row(
                      children: const [Icon(Icons.exit_to_app), Text("Logout")],
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
