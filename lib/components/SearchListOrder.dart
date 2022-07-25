import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/ViewBookingTabBar.dart';
import 'package:eTrade/components/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/ViewBooking.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/TakeOrderScreen.dart';
import 'package:eTrade/screen/ViewOrderScreen.dart';
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
  List<ViewOrderBooking> dummyOrderList = [];
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
    CheckList(BookingTabBarItem.listOfOrdered);
    return dummyOrderList.isNotEmpty
        ? ListView.builder(
            controller: _controller,
            itemBuilder: (BuildContext context, index) {
              return Slidable(
                key: const ValueKey(0),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (((context) async {
                        var orderDetail =
                            await BookingTabBarItem.getOrderDetail(
                                dummyOrderList[index].orderID);

                        TakeOrderScreen.isEditOrder = true;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyNavigationBar(
                                      editRecovery: ViewRecovery(
                                          amount: 0,
                                          description: "",
                                          recoveryID: 0,
                                          dated: "",
                                          party: Customer(
                                            address: "",
                                            discount: 0,  partyId: 0, partyName: "")),
                                      orderDate:
                                          dummyOrderList[index].orderDate,
                                      selectedIndex: 1,
                                      orderList: orderDetail,
                                      orderId: dummyOrderList[index].orderID,
                                      orderPartyName:
                                          dummyOrderList[index].partyName,
                                    )));
                      })),
                      backgroundColor: const Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (((context) async {
                        await SQLHelper.deleteItem(
                            "Order", "OrderID", dummyOrderList[index].orderID);

                        await SQLHelper.deleteItem("OrderDetail", "OrderID",
                            dummyOrderList[index].orderID);
                        var _order;
                        DateFormat dateFormat = DateFormat('dd/MM/yyyy');

                        if (widget.tabName == "Search") {
                          _order = await SQLHelper.getFromToViewOrder(
                              BookingTabBarItem.getFromDate(),
                              BookingTabBarItem.getToDate());
                        } else if (widget.tabName == "Today") {
                          String todayDate = dateFormat.format(DateTime.now());
                          _order =
                              await SQLHelper.getSpecificViewOrder(todayDate);
                        } else if (widget.tabName == "Yesterday") {
                          String yesterdayDate = dateFormat.format(
                              DateTime.now().subtract(Duration(days: 1)));
                          _order = await SQLHelper.getSpecificViewOrder(
                              yesterdayDate);
                        } else {
                          _order = await SQLHelper.getAllViewOrder();
                        }
                        setState(() {
                          BookingTabBarItem.listOfOrdered =
                              ViewOrderBooking.ViewOrderFromDb(_order);
                          if (BookingTabBarItem.listOfOrdered.isNotEmpty) {
                            CheckList(BookingTabBarItem.listOfOrdered);
                          }
                        });
                      })),
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
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
                                "OrderId: #${dummyOrderList[index].orderID}",
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
                                  Text("Order On",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    "${dummyOrderList[index].orderDate}",
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
                                onPressed: () async {
                                  var orderDetail =
                                      await BookingTabBarItem.getOrderDetail(
                                          BookingTabBarItem
                                              .listOfOrdered[index].orderID);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ViewOrderScreen(
                                              selectedOrdeDate:
                                                  dummyOrderList[index]
                                                      .orderDate,
                                              selectedItems: orderDetail,
                                              selecedCustomer:
                                                  dummyOrderList[index]
                                                      .partyName,
                                              fromDate: BookingTabBarItem
                                                  .getFromDate(),
                                              toDate:
                                                  BookingTabBarItem.getToDate(),
                                              orderId: BookingTabBarItem
                                                  .listOfOrdered[index]
                                                  .orderID)));
                                },
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      // border: Border.all(
                                      //     color:
                                      //         Color(0xff00620b),
                                      //     width: 1),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  child: Text(
                                    "Order Detail",
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
