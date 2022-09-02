import 'package:etrade/components/constants.dart';
import 'package:etrade/components/drawer.dart';
import 'package:etrade/components/sharePreferences.dart';
import 'package:etrade/entities/Customer.dart';
import 'package:etrade/entities/Edit.dart';
import 'package:etrade/entities/ViewRecovery.dart';
import 'package:etrade/screen/NavigationScreen/DashBoard/DashboardScreen.dart';
import 'package:etrade/screen/NavigationScreen/RecoveryBooking/ViewRecoveryScreen.dart';
import 'package:etrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:etrade/screen/NavigationScreen/RecoveryBooking/RecoveryScreen.dart';
import 'package:etrade/screen/NavigationScreen/Booking/ViewBookingScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyNavigationBar extends StatefulWidget {
  MyNavigationBar(
      {required this.selectedIndex,
      required this.list,
      required this.id,
      required this.date,
      required this.editRecovery,
      required this.partyName});
  int id;
  int selectedIndex;
  List<Edit> list;
  String partyName;
  String date;
  ViewRecovery editRecovery;
  static int currentIndex = 0;
  static int userID = 0;
  static String userName = "";
  static bool isAdmin = false;
  static bool islocal = false;
  static int userTarget = 0;
  static String ip = "";
  changeIndex() {
    selectedIndex = 1;
  }

  static MyNavigationBar initializer(int index) {
    return MyNavigationBar(
      editRecovery: ViewRecovery.initializer(),
      selectedIndex: index,
      date: "",
      list: [],
      id: 0,
      partyName: "Search Customer",
    );
  }

  @override
  _MyNavigationBarState createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  _onItemTapped(int index) {
    setState(() {
      MyNavigationBar.currentIndex = index;
      widget.selectedIndex = MyNavigationBar.currentIndex;
    });
  }

  @override
  void initState() {
    MyNavigationBar.userID = UserSharePreferences.getId();
    MyNavigationBar.ip = UserSharePreferences.getIp();
    MyNavigationBar.userName = UserSharePreferences.getName();
    MyNavigationBar.isAdmin = UserSharePreferences.getisAdminOrNot();
    MyNavigationBar.islocal = UserSharePreferences.getislocal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MyNavigationBar.currentIndex = widget.selectedIndex;
    final List<Widget> _pages = MyNavigationBar.isAdmin
        ? <Widget>[DashBoardScreen(), ViewBookingScreen(), ViewRecoveryScreen()]
        : <Widget>[
            DashBoardScreen(),
            TakeOrderScreen(
              list: widget.list,
              date: widget.date,
              partyName: widget.partyName,
              iD: widget.id,
            ),
            ViewBookingScreen(),
            RecoveryScreen(
              recovery: widget.editRecovery,
              userID: MyNavigationBar.userID,
            ),
          ];

    return Scaffold(
        body: _pages[widget.selectedIndex],
        bottomNavigationBar: Material(
          elevation: 23,
          child: Container(
            decoration: BoxDecoration(
                border: Border(
              top: BorderSide(width: 1.5, color: etradeMainColor),
            )),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: GNav(
                selectedIndex: MyNavigationBar.currentIndex,
                onTabChange: _onItemTapped,
                activeColor: Colors.white,
                tabBackgroundColor: etradeMainColor,
                gap: 8,
                padding: EdgeInsets.all(14),
                tabs: MyNavigationBar.isAdmin
                    ? [
                        GButton(
                          icon: Icons.home,
                          text: 'Home',
                        ),
                        GButton(
                          icon: Icons.wysiwyg_outlined,
                          text: (ViewBookingScreen.isSaleBooking)
                              ? "View Invoice"
                              : 'View Booking',
                        ),
                        GButton(
                          icon: Icons.home,
                          text: 'View Recovery',
                        ),
                      ]
                    : [
                        GButton(
                          icon: Icons.home,
                          text: 'Home',
                        ),
                        GButton(
                          icon: Icons.edit_note_outlined,
                          text: (TakeOrderScreen.isSaleSpot)
                              ? 'Invoice'
                              : (TakeOrderScreen.isEditSale)
                                  ? 'Edit Invoice'
                                  : (TakeOrderScreen.isEditOrder)
                                      ? 'Edit Order'
                                      : 'Take Order',
                        ),
                        GButton(
                          icon: Icons.wysiwyg_outlined,
                          text: (ViewBookingScreen.isSaleBooking)
                              ? "View Invoice"
                              : 'View Booking',
                        ),
                        GButton(
                          icon: Icons.grading_outlined,
                          text: RecoveryScreen.isEditRecovery
                              ? "Edit Recovery"
                              : 'Recovery',
                        ),
                      ]),
          ),
        )
        // )
        );
  }
}
