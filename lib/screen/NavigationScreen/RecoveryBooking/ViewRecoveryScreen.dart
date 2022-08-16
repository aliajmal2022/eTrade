import 'dart:math';

import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/components/SearchListOrder.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/components/SearchListRecovery.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/components/ViewRecoveryTabBar.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Edit.dart';
import 'package:eTrade/entities/Recovery.dart';
import 'package:eTrade/entities/ViewBooking.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/RecoveryScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/OrderDetailScreen.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/RecoveryDetailScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ViewRecoveryScreen extends StatefulWidget {
  @override
  State<ViewRecoveryScreen> createState() => _ViewRecoveryScreenState();
}

class _ViewRecoveryScreenState extends State<ViewRecoveryScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final _tcontroller = TabController(length: 4, vsync: this);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: eTradeMainColor,
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
            TakeOrderScreen.isSelected = true;
            Get.off(MyNavigationBar.initializer(0));
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
    ));
  }
}
