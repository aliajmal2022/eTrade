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
  PageController _pageController = PageController(initialPage: 0);
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              border: Border(
            top: BorderSide(width: 0.5, color: Colors.grey.shade500),
          )),
          child: BottomNavigationBar(
            backgroundColor: Color(0xFF00620b),
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 16,
            selectedIconTheme: const IconThemeData(color: Colors.white),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            unselectedIconTheme: IconThemeData(color: Colors.grey),
            elevation: 19,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.trending_up_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.edit_note_outlined),
                label: (TakeOrderScreen.isSaleSpot)
                    ? 'Invoice'
                    : (TakeOrderScreen.isEditSale)
                        ? 'Edit Invoice'
                        : (TakeOrderScreen.isEditOrder)
                            ? 'Edit Order'
                            : 'Take Order',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wysiwyg_outlined),
                label: (ViewBookingScreen.isSaleBooking)
                    ? "View Invoice"
                    : 'View Booking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grading_outlined),
                label: 'Recovery',
              ),
            ],
            currentIndex: MyNavigationBar.currentIndex,
            onTap: _onItemTapped,
          ),
        ));
  }
}
