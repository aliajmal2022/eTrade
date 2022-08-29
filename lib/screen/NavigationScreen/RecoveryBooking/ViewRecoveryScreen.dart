import 'dart:math';

import 'package:etrade/components/NavigationBar.dart';
import 'package:etrade/components/constants.dart';
import 'package:etrade/components/sharePreferences.dart';
import 'package:etrade/screen/NavigationScreen/Booking/components/SearchListViewBooking.dart';
import 'package:etrade/screen/NavigationScreen/RecoveryBooking/components/SearchListRecovery.dart';
import 'package:etrade/screen/NavigationScreen/RecoveryBooking/components/ViewRecoveryTabBar.dart';
import 'package:etrade/components/drawer.dart';
import 'package:etrade/helper/sqlhelper.dart';
import 'package:etrade/entities/Customer.dart';
import 'package:etrade/entities/Edit.dart';
import 'package:etrade/entities/Recovery.dart';
import 'package:etrade/entities/ViewBooking.dart';
import 'package:etrade/entities/ViewRecovery.dart';
import 'package:etrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:etrade/screen/NavigationScreen/RecoveryBooking/RecoveryScreen.dart';
import 'package:etrade/screen/NavigationScreen/Booking/OrderDetailScreen.dart';
import 'package:etrade/screen/NavigationScreen/RecoveryBooking/RecoveryDetailScreen.dart';
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
        child: MyNavigationBar.isAdmin
            ? Scaffold(
                appBar: AppBar(
                  backgroundColor: etradeMainColor,
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
                  leading: Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: const Icon(
                          Icons.menu,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        tooltip: MaterialLocalizations.of(context)
                            .openAppDrawerTooltip,
                      );
                    },
                  ),
                  title: const Text(
                    'View Recoveries',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                drawer: MyDrawer(),
                body: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _tcontroller,
                    children: [
                      RecoveryTabBarItem(tabName: "All"),
                      RecoveryTabBarItem(tabName: "Today"),
                      RecoveryTabBarItem(tabName: "Yesterday"),
                      RecoveryTabBarItem(tabName: "Search"),
                    ]),
              )
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: etradeMainColor,
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
