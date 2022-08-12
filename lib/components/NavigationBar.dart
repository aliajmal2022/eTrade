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
  static int userTarget = 0;
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
        bottomNavigationBar: Material(
          elevation: 23,
          child: Container(
            decoration: BoxDecoration(
                border: Border(
              top: BorderSide(width: 1.5, color: eTradeGreen),
            )),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: GNav(
                selectedIndex: MyNavigationBar.currentIndex,
                onTabChange: _onItemTapped,
                activeColor: Colors.white,
                tabBackgroundColor: eTradeGreen,
                gap: 8,
                padding: EdgeInsets.all(14),
                tabs: [
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
                    text: 'Recovery',
                  ),
                ]),
          ),
        )
        // )
        );
  }
}
