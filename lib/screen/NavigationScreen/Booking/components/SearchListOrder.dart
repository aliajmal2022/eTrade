import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/components/ViewBookingTabBar.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/ViewBooking.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/main.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/SaleDetailScreen.dart';
import 'package:eTrade/screen/NavigationScreen/DashBoard/DashboardScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/OrderDetailScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/ViewBookingScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/components/AddItemModelSheet.dart';
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

class _ListOfOrderState extends State<ListOfOrder> {
  var dummyOrderList = [];

  var _item;
  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  CheckList(List list) {
    dummyOrderList.clear();

    for (var element in list) {
      if (element.partyName.toLowerCase().contains(widget.matchItem)) {
        setState(() {
          print(element.partyName.toLowerCase());
          dummyOrderList.add(element);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = ScrollController();
    CheckList(BookingTabBarItem.listOfItems);
    return dummyOrderList.isNotEmpty
        ? ListView.builder(
            controller: _controller,
            itemBuilder: (BuildContext context, index) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Slidable(
                  key: const ValueKey(0),
                  endActionPane:
                      ActionPane(motion: const ScrollMotion(), children: [
                    SlidableAction(
                      onPressed: ((ViewBookingScreen.isSaleBooking
                          ? (context) async {
                              var saleDetail =
                                  await BookingTabBarItem.getSaleDetail(
                                      dummyOrderList[index].saleID);
                              TakeOrderScreen.isSaleSpot = false;
                              TakeOrderScreen.isEditOrder = false;
                              TakeOrderScreen.isSelected = false;
                              TakeOrderScreen.isEditSale = true;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyNavigationBar(
                                          selectedIndex: 1,
                                          editRecovery: ViewRecovery(
                                              amount: 0,
                                              description: "",
                                              checkOrCash: "",
                                              recoveryID: 0,
                                              dated: "",
                                              party: Customer(
                                                  userId: 0,
                                                  discount: 0,
                                                  address: "",
                                                  partyId: 0,
                                                  partyName: "")),
                                          date: dummyOrderList[index].saleDate,
                                          list: saleDetail,
                                          partyName:
                                              dummyOrderList[index].partyName,
                                          id: dummyOrderList[index].saleID)));
                            }
                          : (context) async {
                              var orderDetail =
                                  await BookingTabBarItem.getOrderDetail(
                                      dummyOrderList[index].orderID);
                              TakeOrderScreen.isSaleSpot = false;
                              TakeOrderScreen.isEditSale = true;
                              TakeOrderScreen.isSelected = false;
                              resetCartList();
                              TakeOrderScreen.isEditOrder = true;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyNavigationBar(
                                            editRecovery: ViewRecovery(
                                                amount: 0,
                                                description: "",
                                                recoveryID: 0,
                                                checkOrCash: "",
                                                dated: "",
                                                party: Customer(
                                                    userId: 0,
                                                    address: "",
                                                    discount: 0,
                                                    partyId: 0,
                                                    partyName: "")),
                                            date:
                                                dummyOrderList[index].orderDate,
                                            selectedIndex: 1,
                                            list: orderDetail,
                                            id: dummyOrderList[index].orderID,
                                            partyName:
                                                dummyOrderList[index].partyName,
                                          )));
                            })),
                      backgroundColor: Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'delete',
                      onPressed: ((ViewBookingScreen.isSaleBooking
                          ? (context) async {
                              await SQLHelper.deleteItem("Sale", "saleID",
                                  dummyOrderList[index].orderID);

                              await SQLHelper.deleteItem("SaleDetail", "saleID",
                                  dummyOrderList[index].orderID);

                              if (widget.tabName == "Search") {
                                _item = await SQLHelper.getFromToViewSale(
                                    BookingTabBarItem.getFromDate(),
                                    BookingTabBarItem.getToDate());
                              } else if (widget.tabName == "Today") {
                                String todayDate =
                                    dateFormat.format(DateTime.now());
                                _item = await SQLHelper.getSpecificViewSale(
                                    todayDate);
                              } else if (widget.tabName == "Yesterday") {
                                String yesterdayDate = dateFormat.format(
                                    DateTime.now().subtract(Duration(days: 1)));
                                _item = await SQLHelper.getSpecificViewSale(
                                    yesterdayDate);
                              } else {
                                _item = await SQLHelper.getAllViewSale();
                              }
                              setState(() {
                                dummyOrderList =
                                    ViewOrderBooking.ViewOrderFromDb(_item);
                              });
                            }
                          : (context) async {
                              await SQLHelper.deleteItem("Order", "OrderID",
                                  dummyOrderList[index].orderID);

                              await SQLHelper.deleteItem("OrderDetail",
                                  "OrderID", dummyOrderList[index].orderID);

                              if (widget.tabName == "Search") {
                                _item = await SQLHelper.getFromToViewOrder(
                                    BookingTabBarItem.getFromDate(),
                                    BookingTabBarItem.getToDate());
                              } else if (widget.tabName == "Today") {
                                String todayDate =
                                    dateFormat.format(DateTime.now());
                                _item = await SQLHelper.getSpecificViewOrder(
                                    todayDate);
                              } else if (widget.tabName == "Yesterday") {
                                String yesterdayDate = dateFormat.format(
                                    DateTime.now().subtract(Duration(days: 1)));
                                _item = await SQLHelper.getSpecificViewOrder(
                                    yesterdayDate);
                              } else {
                                _item = await SQLHelper.getAllViewOrder();
                              }
                              setState(() {
                                dummyOrderList =
                                    ViewOrderBooking.ViewOrderFromDb(_item);
                              });

                              DashBoardScreen.dashBoard =
                                  await DashBoardScreen.getOrderHistory();
                            })),
                    ),
                  ]),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color:
                              (MyApp.isDark) ? Color(0xff424242) : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0.0, 0.5), //(x,y)
                              blurRadius: 3.0,
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ViewBookingScreen.isSaleBooking
                                      ? "SaleID: #${dummyOrderList[index].saleID}"
                                      : "OrderID: #${dummyOrderList[index].orderID}",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  " ${dummyOrderList[index].partyName}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    // fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        ViewBookingScreen.isSaleBooking
                                            ? "Sale On"
                                            : "Order On",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      ViewBookingScreen.isSaleBooking
                                          ? "${dummyOrderList[index].saleDate}"
                                          : "${dummyOrderList[index].orderDate}",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: Color(0xff00620b),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  child: Text(
                                    "${dummyOrderList[index].totalQuantity} items",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white),
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: ViewBookingScreen.isSaleBooking
                                      ? () async {
                                          var saleDetail =
                                              await BookingTabBarItem
                                                  .getSaleDetail(
                                                      dummyOrderList[index]
                                                          .saleID);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SaleDetailScreen(
                                                          selectedSaleDate:
                                                              dummyOrderList[
                                                                      index]
                                                                  .saleDate,
                                                          selectedItems:
                                                              saleDetail,
                                                          selecedCustomer:
                                                              dummyOrderList[
                                                                      index]
                                                                  .partyName,
                                                          fromDate:
                                                              BookingTabBarItem
                                                                  .getFromDate(),
                                                          toDate:
                                                              BookingTabBarItem
                                                                  .getToDate(),
                                                          saleID:
                                                              dummyOrderList[
                                                                      index]
                                                                  .saleID)));
                                        }
                                      : () async {
                                          var orderDetail =
                                              await BookingTabBarItem
                                                  .getOrderDetail(
                                                      dummyOrderList[index]
                                                          .orderID);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderDetailScreen(
                                                          selectedOrdeDate:
                                                              dummyOrderList[
                                                                      index]
                                                                  .orderDate,
                                                          selectedItems:
                                                              orderDetail,
                                                          selecedCustomer:
                                                              dummyOrderList[
                                                                      index]
                                                                  .partyName,
                                                          fromDate:
                                                              BookingTabBarItem
                                                                  .getFromDate(),
                                                          toDate:
                                                              BookingTabBarItem
                                                                  .getToDate(),
                                                          orderId:
                                                              dummyOrderList[
                                                                      index]
                                                                  .orderID)));
                                        },
                                  padding: EdgeInsets.zero,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: (MyApp.isDark)
                                            ? Colors.grey
                                            : Colors.grey.shade300,
                                        // border: Border.all(
                                        //     color:
                                        //         Color(0xff00620b),
                                        //     width: 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    child: Text(
                                      ViewBookingScreen.isSaleBooking
                                          ? "Sale Detail"
                                          : "Order Detail",
                                      style: TextStyle(
                                          color: Color(0xff00620b),
                                          // fontStyle: FontStyle.italic,
                                          fontSize: 15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
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
