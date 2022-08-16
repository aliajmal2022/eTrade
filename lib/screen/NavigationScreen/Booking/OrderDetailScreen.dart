import 'package:dart_ping/dart_ping.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/components/AddItemModelSheet.dart';
import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Edit.dart';
import 'package:eTrade/entities/Order.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:eTrade/entities/ViewBooking.dart';
import 'package:eTrade/main.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/ViewBookingScreen.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatefulWidget {
  OrderDetailScreen(
      {required this.selectedItems,
      required this.selecedCustomer,
      required this.fromDate,
      required this.toDate,
      required this.selectedOrdeDate,
      required this.orderId});
  List<Edit> selectedItems;
  String selecedCustomer;
  String selectedOrdeDate;
  String toDate;
  String fromDate;
  int orderId;

  static int totalQuantity = 0;
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  ScrollController _controller = ScrollController();
  TextEditingController controller = TextEditingController();
  String description = '';
  int totalQuantity = 0;
  double totalAmount = 0.0;
  int getTotalQuantity() {
    int temp = 0;
    if (widget.selectedItems.isNotEmpty) {
      widget.selectedItems.forEach((element) {
        temp += element.quantity;
      });
    }
    return temp;
  }

  double getTotalAmount() {
    double temp = 0;
    if (widget.selectedItems.isNotEmpty) {
      widget.selectedItems.forEach((element) {
        temp += (element.rate * element.quantity);
      });
    }
    return temp;
  }

  @override
  void initState() {
    setState(() {
      totalQuantity = getTotalQuantity();
      totalAmount = getTotalAmount();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int itemNo = widget.selectedItems.length;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          backgroundColor: eTradeMainColor,
          toolbarHeight: 80,
          title: Text(
            'Order Detail',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 20.0, bottom: 5.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "Customer Name: ",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "${widget.selecedCustomer}",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]),
                      ),
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "Order Date: ",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                "${widget.selectedOrdeDate}",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ]),
                      ),
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "Description: ",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                "${Edit.getDescription()}",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 2,
                  color: eTradeMainColor,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.builder(
                    controller: _controller,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      return Card(
                        child: ListTile(
                          horizontalTitleGap: 20,
                          title: Text(
                            widget.selectedItems[index].itemName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Qty: ${widget.selectedItems[index].quantity}",
                                style: TextStyle(fontSize: 13),
                              ),
                              Text(
                                "Rate: ${widget.selectedItems[index].rate}",
                                style: TextStyle(fontSize: 13),
                              ),
                              Text(
                                "Value: ${widget.selectedItems[index].quantity * widget.selectedItems[index].rate}",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        // )
                      );
                    },
                    itemCount: widget.selectedItems.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.all(5),
                    scrollDirection: Axis.vertical,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
            child: BottomAppBar(
              elevation: 50,
              child: Container(
                decoration: BoxDecoration(
                    color: (MyApp.isDark)
                        ? Color(0xff424242)
                        : Colors.grey.shade100,
                    border: Border(
                      top: BorderSide(color: eTradeMainColor, width: 4),
                    )),
                height: 80,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Qty: $totalQuantity",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // color: Colors.white
                                ),
                              ),
                              Text(
                                "Total Value: $totalAmount",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // color: Colors.white
                                ),
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
