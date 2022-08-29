import 'package:etrade/components/NavigationBar.dart';
import 'package:etrade/components/constants.dart';
import 'package:etrade/screen/NavigationScreen/Booking/components/ViewBookingTabBar.dart';
import 'package:etrade/helper/sqlhelper.dart';
import 'package:etrade/entities/Customer.dart';
import 'package:etrade/entities/ViewBooking.dart';
import 'package:etrade/entities/ViewRecovery.dart';
import 'package:etrade/main.dart';
import 'package:etrade/screen/NavigationScreen/Booking/SaleDetailScreen.dart';
import 'package:etrade/screen/NavigationScreen/DashBoard/DashboardScreen.dart';
import 'package:etrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:etrade/screen/NavigationScreen/Booking/OrderDetailScreen.dart';
import 'package:etrade/screen/NavigationScreen/Booking/ViewBookingScreen.dart';
import 'package:etrade/screen/NavigationScreen/Take%20Order/components/AddItemModelSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class ListOfOrder extends StatefulWidget {
  ListOfOrder({required this.matchItem, required this.tabName});
  String matchItem;
  String tabName;
  @override
  State<ListOfOrder> createState() => _ListOfOrderState();
}

class _ListOfOrderState extends State<ListOfOrder>
    with TickerProviderStateMixin {
  var dummyOrderList = [];

  var _item;
  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  CheckList(List list) {
    dummyOrderList.clear();

    for (var element in list) {
      if (element.partyName.toLowerCase().contains(widget.matchItem)) {
        setState(() {
          dummyOrderList.add(element);
        });
      }
    }
  }

  var _animationController;
  @override
  void initState() {
    // TODO: implement initState
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = ScrollController();
    CheckList(BookingTabBarItem.listOfItems);
    return dummyOrderList.isNotEmpty
        ? ListView.builder(
            controller: _controller,
            itemBuilder: (BuildContext context, index) {
              return MyNavigationBar.isAdmin
                  ? SlideTransition(
                      position:
                          Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                              .animate(_animationController),
                      child: FadeTransition(
                          opacity: _animationController,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ViewBookingScreen.isSaleBooking
                                                ? "Sale Id: ${dummyOrderList[index].iD}"
                                                : "Order Id: ${dummyOrderList[index].iD}",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          Text(
                                            "${dummyOrderList[index].partyName}",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              // fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  ViewBookingScreen
                                                          .isSaleBooking
                                                      ? "Sale On"
                                                      : "Order On",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                    // fontWeight: FontWeight.bold
                                                  )),
                                              Text(
                                                ViewBookingScreen.isSaleBooking
                                                    ? "${dummyOrderList[index].date}"
                                                    : "${dummyOrderList[index].date}",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5))),
                                            child: Text(
                                              "${dummyOrderList[index].totalQuantity} items",
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          MaterialButton(
                                            onPressed:
                                                ViewBookingScreen.isSaleBooking
                                                    ? () async {
                                                        var saleDetail =
                                                            await BookingTabBarItem
                                                                .getSaleDetail(
                                                                    dummyOrderList[
                                                                            index]
                                                                        .iD);
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => SaleDetailScreen(
                                                                    selectedSaleDate:
                                                                        dummyOrderList[index]
                                                                            .date,
                                                                    selectedItems:
                                                                        saleDetail,
                                                                    selecedCustomer:
                                                                        dummyOrderList[index]
                                                                            .partyName,
                                                                    fromDate:
                                                                        BookingTabBarItem
                                                                            .getFromDate(),
                                                                    toDate: BookingTabBarItem
                                                                        .getToDate(),
                                                                    saleID: dummyOrderList[
                                                                            index]
                                                                        .iD)));
                                                      }
                                                    : () async {
                                                        var orderDetail =
                                                            await BookingTabBarItem
                                                                .getOrderDetail(
                                                                    dummyOrderList[
                                                                            index]
                                                                        .iD);
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => OrderDetailScreen(
                                                                    selectedOrdeDate:
                                                                        dummyOrderList[index]
                                                                            .date,
                                                                    selectedItems:
                                                                        orderDetail,
                                                                    selecedCustomer:
                                                                        dummyOrderList[index]
                                                                            .partyName,
                                                                    fromDate:
                                                                        BookingTabBarItem
                                                                            .getFromDate(),
                                                                    toDate: BookingTabBarItem
                                                                        .getToDate(),
                                                                    orderId: dummyOrderList[
                                                                            index]
                                                                        .iD)));
                                                      },
                                            padding: EdgeInsets.zero,
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  color: etradeMainColor,
                                                  // border: Border.all(
                                                  //     color:
                                                  //         etradeMainColor,
                                                  //     width: 1),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5))),
                                              child: Text(
                                                ViewBookingScreen.isSaleBooking
                                                    ? "Sale Detail"
                                                    : "Order Detail",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    // fontStyle: FontStyle.italic,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )))
                  : SlideTransition(
                      position:
                          Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                              .animate(_animationController),
                      child: FadeTransition(
                        opacity: _animationController,

                        child: Slidable(
                          key: const ValueKey(0),
                          endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: ((ViewBookingScreen.isSaleBooking
                                      ? (context) async {
                                          var saleDetail =
                                              await BookingTabBarItem
                                                  .getSaleDetail(
                                                      dummyOrderList[index].iD);
                                          TakeOrderScreen.isSaleSpot = false;
                                          TakeOrderScreen.isEditOrder = false;
                                          TakeOrderScreen.isSelected = false;
                                          TakeOrderScreen.isEditSale = true;
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyNavigationBar(
                                                          selectedIndex: 1,
                                                          editRecovery:
                                                              ViewRecovery
                                                                  .initializer(),
                                                          date: dummyOrderList[
                                                                  index]
                                                              .date,
                                                          list: saleDetail,
                                                          partyName:
                                                              dummyOrderList[
                                                                      index]
                                                                  .partyName,
                                                          id: dummyOrderList[
                                                                  index]
                                                              .iD)));
                                        }
                                      : (context) async {
                                          var orderDetail =
                                              await BookingTabBarItem
                                                  .getOrderDetail(
                                                      dummyOrderList[index].iD);
                                          TakeOrderScreen.isSaleSpot = false;
                                          TakeOrderScreen.isEditSale = true;
                                          TakeOrderScreen.isSelected = false;
                                          resetCartList();
                                          TakeOrderScreen.isEditOrder = true;
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyNavigationBar(
                                                        editRecovery:
                                                            ViewRecovery
                                                                .initializer(),
                                                        date: dummyOrderList[
                                                                index]
                                                            .date,
                                                        selectedIndex: 1,
                                                        list: orderDetail,
                                                        id: dummyOrderList[
                                                                index]
                                                            .iD,
                                                        partyName:
                                                            dummyOrderList[
                                                                    index]
                                                                .partyName,
                                                      )));
                                        })),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Edit',
                                ),
                                SlidableAction(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'delete',
                                  onPressed: ((context) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content:
                                                Text("Really want to detele"),
                                            action: SnackBarAction(
                                                label: "Delete",
                                                onPressed:
                                                    ViewBookingScreen
                                                            .isSaleBooking
                                                        ? () async {
                                                            await SQLHelper
                                                                .deleteItem(
                                                                    "Sale",
                                                                    "InvoiceID",
                                                                    dummyOrderList[
                                                                            index]
                                                                        .iD);

                                                            await SQLHelper
                                                                .deleteItem(
                                                                    "SaleDetail",
                                                                    "InvoiceID",
                                                                    dummyOrderList[
                                                                            index]
                                                                        .iD);

                                                            if (widget
                                                                    .tabName ==
                                                                "Search") {
                                                              _item = await SQLHelper.getFromToViewSale(
                                                                  BookingTabBarItem
                                                                      .getFromDate(),
                                                                  BookingTabBarItem
                                                                      .getToDate());
                                                            } else if (widget
                                                                    .tabName ==
                                                                "Today") {
                                                              String todayDate =
                                                                  dateFormat.format(
                                                                      DateTime
                                                                          .now());
                                                              _item = await SQLHelper
                                                                  .getSpecificViewSale(
                                                                      todayDate);
                                                            } else if (widget
                                                                    .tabName ==
                                                                "Yesterday") {
                                                              String
                                                                  yesterdayDate =
                                                                  dateFormat.format(DateTime
                                                                          .now()
                                                                      .subtract(
                                                                          Duration(
                                                                              days: 1)));
                                                              _item = await SQLHelper
                                                                  .getSpecificViewSale(
                                                                      yesterdayDate);
                                                            } else {
                                                              _item = await SQLHelper
                                                                  .getAllViewSale();
                                                            }
                                                            setState(() {
                                                              BookingTabBarItem
                                                                      .listOfItems =
                                                                  ViewBooking
                                                                      .ViewSaleFromDb(
                                                                          _item);

                                                              build(context);
                                                            });
                                                            DashBoardScreen
                                                                    .dashBoard =
                                                                await DashBoardScreen
                                                                    .getOrderHistory(
                                                                        false);
                                                          }
                                                        : () async {
                                                            await SQLHelper
                                                                .deleteItem(
                                                                    "Order",
                                                                    "OrderID",
                                                                    dummyOrderList[
                                                                            index]
                                                                        .iD);

                                                            await SQLHelper.deleteItem(
                                                                "OrderDetail",
                                                                "OrderID",
                                                                dummyOrderList[
                                                                        index]
                                                                    .iD);

                                                            if (widget
                                                                    .tabName ==
                                                                "Search") {
                                                              _item = await SQLHelper.getFromToViewOrder(
                                                                  BookingTabBarItem
                                                                      .getFromDate(),
                                                                  BookingTabBarItem
                                                                      .getToDate());
                                                            } else if (widget
                                                                    .tabName ==
                                                                "Today") {
                                                              String todayDate =
                                                                  dateFormat.format(
                                                                      DateTime
                                                                          .now());
                                                              _item = await SQLHelper
                                                                  .getSpecificViewOrder(
                                                                      todayDate);
                                                            } else if (widget
                                                                    .tabName ==
                                                                "Yesterday") {
                                                              String
                                                                  yesterdayDate =
                                                                  dateFormat.format(DateTime
                                                                          .now()
                                                                      .subtract(
                                                                          Duration(
                                                                              days: 1)));
                                                              _item = await SQLHelper
                                                                  .getSpecificViewOrder(
                                                                      yesterdayDate);
                                                            } else {
                                                              _item = await SQLHelper
                                                                  .getAllViewOrder();
                                                            }
                                                            setState(() {
                                                              BookingTabBarItem
                                                                      .listOfItems =
                                                                  ViewBooking
                                                                      .ViewOrderFromDb(
                                                                          _item);

                                                              build(context);
                                                            });
                                                            DashBoardScreen
                                                                    .dashBoard =
                                                                await DashBoardScreen
                                                                    .getOrderHistory(
                                                                        true);
                                                          })));
                                  }),
                                ),
                              ]),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ViewBookingScreen.isSaleBooking
                                                ? "Sale Id: ${dummyOrderList[index].iD}"
                                                : "Order Id: ${dummyOrderList[index].iD}",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          Text(
                                            "${dummyOrderList[index].partyName}",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              // fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  ViewBookingScreen
                                                          .isSaleBooking
                                                      ? "Sale On"
                                                      : "Order On",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                    // fontWeight: FontWeight.bold
                                                  )),
                                              Text(
                                                ViewBookingScreen.isSaleBooking
                                                    ? "${dummyOrderList[index].date}"
                                                    : "${dummyOrderList[index].date}",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5))),
                                            child: Text(
                                              "${dummyOrderList[index].totalQuantity} items",
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          MaterialButton(
                                            onPressed:
                                                ViewBookingScreen.isSaleBooking
                                                    ? () async {
                                                        var saleDetail =
                                                            await BookingTabBarItem
                                                                .getSaleDetail(
                                                                    dummyOrderList[
                                                                            index]
                                                                        .iD);
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => SaleDetailScreen(
                                                                    selectedSaleDate:
                                                                        dummyOrderList[index]
                                                                            .date,
                                                                    selectedItems:
                                                                        saleDetail,
                                                                    selecedCustomer:
                                                                        dummyOrderList[index]
                                                                            .partyName,
                                                                    fromDate:
                                                                        BookingTabBarItem
                                                                            .getFromDate(),
                                                                    toDate: BookingTabBarItem
                                                                        .getToDate(),
                                                                    saleID: dummyOrderList[
                                                                            index]
                                                                        .iD)));
                                                      }
                                                    : () async {
                                                        var orderDetail =
                                                            await BookingTabBarItem
                                                                .getOrderDetail(
                                                                    dummyOrderList[
                                                                            index]
                                                                        .iD);
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => OrderDetailScreen(
                                                                    selectedOrdeDate:
                                                                        dummyOrderList[index]
                                                                            .date,
                                                                    selectedItems:
                                                                        orderDetail,
                                                                    selecedCustomer:
                                                                        dummyOrderList[index]
                                                                            .partyName,
                                                                    fromDate:
                                                                        BookingTabBarItem
                                                                            .getFromDate(),
                                                                    toDate: BookingTabBarItem
                                                                        .getToDate(),
                                                                    orderId: dummyOrderList[
                                                                            index]
                                                                        .iD)));
                                                      },
                                            padding: EdgeInsets.zero,
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  color: etradeMainColor,
                                                  // border: Border.all(
                                                  //     color:
                                                  //         etradeMainColor,
                                                  //     width: 1),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5))),
                                              child: Text(
                                                ViewBookingScreen.isSaleBooking
                                                    ? "Sale Detail"
                                                    : "Order Detail",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    // fontStyle: FontStyle.italic,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // ),
                      ));
            },
            itemCount: dummyOrderList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.all(5),
            scrollDirection: Axis.vertical,
          )
        : const Center(
            child: const Text("Not Found"),
          );
  }
}
