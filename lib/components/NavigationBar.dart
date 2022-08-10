import 'dart:html';

import 'package:eTrade/components/constants.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/components/sharePreferences.dart';
import 'package:eTrade/entities/Edit.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/NavigationScreen/DashBoard/DashboardScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/RecoveryScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/ViewBookingScreen.dart';
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
  changeIndex() {
    selectedIndex = 1;
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
    print(MyNavigationBar.userID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MyNavigationBar.currentIndex = widget.selectedIndex;
    final List<Widget> _pages = <Widget>[
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
        bottomNavigationBar:

            // Container(
            //     height: 100,
            //     decoration: BoxDecoration(
            //         border: Border(
            //       top: BorderSide(width: 0.5, color: Colors.grey.shade800),
            //     )),
            //     child:
            //  BottomNavigationBar(
            //   backgroundColor: eTradeGreen,
            //   type: BottomNavigationBarType.shifting,
            //   selectedFontSize: 16,
            //   showSelectedLabels: true,
            //   showUnselectedLabels: false,
            //   selectedIconTheme: const IconThemeData(color: eTradeBlue),
            //   selectedItemColor: Colors.white,
            //   unselectedItemColor: Colors.grey,
            //   unselectedIconTheme: IconThemeData(color: Colors.grey),
            //   elevation: 19,
            //   items: <BottomNavigationBarItem>[
            //     BottomNavigationBarItem(
            //       icon: Icon(Icons.trending_up_outlined),
            //       label: 'Home',
            //     ),
            //     BottomNavigationBarItem(
            //       icon: Icon(Icons.edit_note_outlined),
            //       label: (TakeOrderScreen.isSaleSpot)
            //           ? 'Invoice'
            //           : (TakeOrderScreen.isEditSale)
            //               ? 'Edit Invoice'
            //               : (TakeOrderScreen.isEditOrder)
            //                   ? 'Edit Order'
            //                   : 'Take Order',
            //     ),
            //     BottomNavigationBarItem(
            //       icon: Icon(Icons.wysiwyg_outlined),
            //       label: (ViewBookingScreen.isSaleBooking)
            //           ? "View Invoice"
            //           : 'View Booking',
            //     ),
            //     BottomNavigationBarItem(
            //       icon: Icon(Icons.grading_outlined),
            //       label: 'Recovery',
            //     ),
            //   ],
            //   currentIndex: MyNavigationBar.currentIndex,
            //   onTap: _onItemTapped,
            // ),
            GNav(
                rippleColor: Colors
                    .grey.shade800, // tab button ripple color when pressed
                hoverColor: Colors.grey.shade700, // tab button hover color
                haptic: true, // haptic feedback
                tabBorderRadius: 15,
                tabActiveBorder: Border.all(
                    color: Colors.black, width: 1), // tab button border
                tabBorder: Border.all(
                    color: Colors.grey, width: 1), // tab button border
                tabShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 8)
                ], // tab button shadow
                curve: Curves.easeOutExpo, // tab animation curves
                duration: Duration(milliseconds: 900), // tab animation duration
                gap: 8, // the tab button gap between icon and text
                color: Colors.grey[800], // unselected icon color
                activeColor: Colors.purple, // selected icon and text color
                iconSize: 24, // tab button icon size
                tabBackgroundColor: Colors.purple
                    .withOpacity(0.1), // selected tab background color
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 5), // navigation bar padding
                tabs: [
                  GButton(
                    icon: Icons.trending_up_outlined,
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
                    text: 'Recovery',
                  ),
                ])
        // )
        );
  }
}
