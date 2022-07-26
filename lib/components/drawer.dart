import 'package:eTrade/components/NavigationBar.dart';
import 'package:date_format/date_format.dart';
import 'package:eTrade/components/Sql_Connection.dart';
import 'package:eTrade/components/sharePreferences.dart';
import 'package:eTrade/components/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/main.dart';
import 'package:eTrade/screen/ConnectionScreen.dart';
import 'package:eTrade/screen/TakeOrderScreen.dart';
import 'package:eTrade/screen/LoginScreen.dart';
import 'package:eTrade/screen/RecoveryScreen.dart';
import 'package:eTrade/screen/SplashScreen.dart';
import 'package:eTrade/screen/ViewRecoveryScreen.dart';
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
                              recoveryID: 0,
                              dated: "",
                              party: Customer(
                                  address: "",
                                  partyId: 0,
                                  partyName: "",
                                  discount: 0)),
                          selectedIndex: 0,
                          orderList: [],
                          orderDate: "",
                          orderId: 0,
                          orderPartyName: "Search Customer",
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
                          description: "",
                          recoveryID: 0,
                          dated: "",
                          party: Customer(
                              address: "",
                              partyId: 0,
                              partyName: "",
                              discount: 0)),
                      selectedIndex: 0,
                      orderDate: "",
                      orderList: [],
                      orderPartyName: "Search Customer",
                      orderId: 0,
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
                                            description: "",
                                            recoveryID: 0,
                                            dated: "",
                                            party: Customer(
                                                partyId: 0,
                                                partyName: "",
                                                address: "",
                                                discount: 0)),
                                        selectedIndex: 0,
                                        orderDate: "",
                                        orderList: [],
                                        orderId: 0,
                                        orderPartyName: "Search Customer",
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
                                        dated: "",
                                        party: Customer(
                                            address: "",
                                            discount: 0,
                                            partyId: 0,
                                            partyName: "")),
                                    selectedIndex: 1,
                                    orderDate: "",
                                    orderList: [],
                                    orderId: 0,
                                    orderPartyName: "Search Customer",
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
                      var strToList = ping.split(",");
                      var ip = strToList[0];
                      var port = strToList[1];

                      bool isconnected =
                          await Sql_Connection.connect(context, ip, port);
                      if (isconnected) {
                        final snackBar = const SnackBar(
                          content: Text("Posting is Completed."),
                        );
                        var _order = await SQLHelper.instance
                            .getTable("Order", "OrderID");
                        var _orderDetail = await SQLHelper.instance
                            .getTable("OrderDetail", "OrderID");
                        var _recovery = await SQLHelper.instance
                            .getTable("Recovery", "RecoveryID");
                        try {
                          _order.forEach((element) {
                            String dated = element['Dated'];
                            var rawDate = dated.split("/");
                            DateTime date =
                                DateTime.parse(rawDate.reversed.join(""));

                            Sql_Connection().write(
                                "INSERT INTO dbo_m.[Order](OrderID,UserId,PartyID,TotalQuantity,TotalValue,Dated,[Description])VALUES( ${element['OrderID']} , ${element['UserID']} , ${element['PartyID']},${element['TotalQuantity']} ,${element['TotalValue']} , '${formatDate(date, [
                                  yyyy,
                                  mm,
                                  dd
                                ])}',	'${element['Description']}')");
                          });
                          _orderDetail.forEach((element) {
                            String dated = element['Dated'];
                            var rawDate = dated.split("/");
                            DateTime date =
                                DateTime.parse(rawDate.reversed.join(""));
                            Sql_Connection().write(
                                "INSERT INTO dbo_m.[OrderDetail]( UserId ,OrderID, ItemID, Quantity, RATE, Amount, Dated) VALUES ( ${element['UserID']}, ${element['OrderID']} , '${element['ItemID']}', ${element['Quantity']},${element['RATE']} ,${element['Amount']} , '${formatDate(date, [
                                  yyyy,
                                  mm,
                                  dd
                                ])}') ");
                          });
                          _recovery.forEach((element) {
                            String dated = element['Dated'];
                            var rawDate = dated.split("/");
                            DateTime date =
                                DateTime.parse(rawDate.reversed.join(""));
                            Sql_Connection().write(
                                " INSERT INTO dbo_m.[Recovery]( RecoveryID, UserId, PartyID, Amount, Dated, [Description]) VALUES ( ${element['RecoveryID']},${element['UserID']},${element['PartyID']},${element['Amount']},'${formatDate(date, [
                                  yyyy,
                                  mm,
                                  dd
                                ])}','${element['Description']}') ");
                          });
                          await SQLHelper.tablePosted();
                          print("here we go");
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyNavigationBar(
                                        editRecovery: ViewRecovery(
                                            amount: 0,
                                            description: "",
                                            recoveryID: 0,
                                            dated: "",
                                            party: Customer(
                                                address: "",
                                                discount: 0,
                                                partyId: 0,
                                                partyName: "")),
                                        selectedIndex: 0,
                                        orderDate: "",
                                        orderList: [],
                                        orderId: 0,
                                        orderPartyName: "Search Customer",
                                      )),
                              (route) => false);
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } catch (e) {
                          debugPrint("Ops");
                        }
                      } else {
                        // await SQLHelper.tableNotPosted();
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
                                          description: "",
                                          recoveryID: 0,
                                          dated: "",
                                          party: Customer(
                                              discount: 0,
                                              address: "",
                                              partyId: 0,
                                              partyName: "")),
                                      selectedIndex: 0,
                                      orderDate: "",
                                      orderList: [],
                                      orderId: 0,
                                      orderPartyName: "Search Customer",
                                    )),
                            (route) => false);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
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
                    onPressed: () {},
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
