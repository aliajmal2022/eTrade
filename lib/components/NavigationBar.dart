import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/components/sharePreferences.dart';
import 'package:eTrade/entities/EditOrder.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/DashboardScreen.dart';
import 'package:eTrade/screen/TakeOrderScreen.dart';
import 'package:eTrade/screen/RecoveryScreen.dart';
import 'package:eTrade/screen/ViewBookingScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyNavigationBar extends StatefulWidget {
  MyNavigationBar(
      {required this.selectedIndex,
      required this.orderList,
      required this.orderId,
      required this.orderDate,
      required this.editRecovery,
      required this.orderPartyName});
  int orderId;
  int selectedIndex;
  List<EditOrder> orderList;
  String orderPartyName;
  String orderDate;
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
        orderList: widget.orderList,
        orderDate: widget.orderDate,
        orderPartyName: widget.orderPartyName,
        orderID: widget.orderId,
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
                label: (TakeOrderScreen.isSaleSpot) ? 'Invoice' : 'Take Order',
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
