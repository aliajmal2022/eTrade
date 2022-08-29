import 'dart:math';

import 'package:etrade/components/CustomNavigator.dart';
import 'package:etrade/components/NavigationBar.dart';
import 'package:etrade/components/constants.dart';
import 'package:etrade/screen/NavigationScreen/Booking/components/SearchListViewBooking.dart';
import 'package:etrade/screen/NavigationScreen/Booking/components/ViewBookingTabBar.dart';
import 'package:etrade/components/drawer.dart';
import 'package:etrade/helper/sqlhelper.dart';
import 'package:etrade/entities/Customer.dart';
import 'package:etrade/entities/Edit.dart';
import 'package:etrade/entities/ViewBooking.dart';
import 'package:etrade/entities/ViewRecovery.dart';
import 'package:etrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:etrade/screen/NavigationScreen/Booking/OrderDetailScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ViewBookingScreen extends StatefulWidget {
  @override
  State<ViewBookingScreen> createState() => _ViewBookingScreenState();
  static bool isSaleBooking = false;
}

class _ViewBookingScreenState extends State<ViewBookingScreen>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  openDrawer() async {
    await Future.delayed(Duration.zero);
    _scaffoldKey.currentState!.openDrawer();
  }

  @override
  void initState() {
    super.initState();
    if (MyDrawer.isopen) {
      openDrawer();
      MyDrawer.isopen = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _tcontroller = TabController(length: 4, vsync: this);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: etradeMainColor,
            toolbarHeight: 80,
            automaticallyImplyLeading: false,
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
            leading: ViewBookingScreen.isSaleBooking
                ? IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () async {
                      setState(() {
                        BookingTabBarItem.listOfItems.clear();
                        ViewBookingScreen.isSaleBooking = false;
                        // dispose();
                      });
                      Navigator.pushAndRemoveUntil(
                          context,
                          MyCustomRoute(
                              builder: (context) =>
                                  MyNavigationBar.initializer(2),
                              slide: "Right"),
                          (route) => false);
                    },
                  )
                : Builder(
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
            title: Text(
              ViewBookingScreen.isSaleBooking
                  ? 'View Invoices'
                  : 'View Bookings',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          drawer: MyDrawer(),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tcontroller,
            children: [
              Center(
                child: BookingTabBarItem(tabName: "All"),
              ),
              Center(
                child: BookingTabBarItem(tabName: "Today"),
              ),
              Center(
                child: BookingTabBarItem(tabName: "Yesterday"),
              ),
              BookingTabBarItem(tabName: "Search"),
            ],
          )),
    );
  }
}
