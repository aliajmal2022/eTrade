import 'dart:math';

import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/SearchListOrder.dart';
import 'package:eTrade/components/ViewBookingTabBar.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/components/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Edit.dart';
import 'package:eTrade/entities/ViewBooking.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/TakeOrderScreen.dart';
import 'package:eTrade/screen/OrderDetailScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
    if (MyDrawer.isopen) {
      openDrawer();
      MyDrawer.isopen = false;
    }
    super.initState();
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
            backgroundColor: Color(0xFF00620b),
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
                          MaterialPageRoute(
                              builder: (context) => MyNavigationBar(
                                  selectedIndex: 2,
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
                                  list: [],
                                  date: "",
                                  id: 0,
                                  partyName: "Search Customer")),
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
