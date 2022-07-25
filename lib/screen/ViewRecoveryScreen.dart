import 'dart:math';

import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/SearchListOrder.dart';
import 'package:eTrade/components/SearchListRecovery.dart';
import 'package:eTrade/components/ViewRecoveryTabBar.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/components/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/EditOrder.dart';
import 'package:eTrade/entities/Recovery.dart';
import 'package:eTrade/entities/ViewBooking.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/TakeOrderScreen.dart';
import 'package:eTrade/screen/RecoveryScreen.dart';
import 'package:eTrade/screen/ViewOrderScreen.dart';
import 'package:eTrade/screen/ViewRecoveryDetailScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ViewRecoveryScreen extends StatefulWidget {
  @override
  State<ViewRecoveryScreen> createState() => _ViewRecoveryScreenState();
}

class _ViewRecoveryScreenState extends State<ViewRecoveryScreen>
    with SingleTickerProviderStateMixin {
  @override
  @override
  Widget build(BuildContext context) {
    final _tcontroller = TabController(length: 4, vsync: this);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return SafeArea(
        child: WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF00620b),
          toolbarHeight: 80,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "All"),
              Tab(text: "Today"),
              Tab(text: "Yesterday"),
              Tab(text: "Search")
            ],
            controller: _tcontroller,
          ),
          leading: IconButton(
            onPressed: () {
              TakeOrderScreen.isSelectedOrder = true;
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyNavigationBar(
                      editRecovery: ViewRecovery(
                          amount: 0,
                          description: "",
                          recoveryID: 0,
                          dated: "",
                          party:
                              Customer(partyId: 0, partyName: "", discount: 0)),
                      selectedIndex: 0,
                      orderList: [],
                      orderDate: "",
                      orderId: 0,
                      orderPartyName: "Search Customer",
                    ),
                  ),
                  (route) => false);
            },
            icon: Icon(
              Icons.arrow_back,
            ),
          ),
          title: const Text(
            'View Recoveries',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tcontroller,
            children: [
              RecoveryTabBarItem(tabName: "All"),
              RecoveryTabBarItem(tabName: "Today"),
              RecoveryTabBarItem(tabName: "Yesterday"),
              RecoveryTabBarItem(tabName: "Search"),
            ]),
      ),
    ));
  }
}
