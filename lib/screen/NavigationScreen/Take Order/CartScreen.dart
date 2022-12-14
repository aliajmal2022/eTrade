import 'package:etrade/components/CustomNavigator.dart';
import 'package:etrade/components/constants.dart';
import 'package:etrade/entities/Edit.dart';
import 'package:etrade/screen/NavigationScreen/DashBoard/DashboardScreen.dart';
import 'package:etrade/screen/NavigationScreen/Take%20Order/components/AddItemModelSheet.dart';

import 'package:etrade/components/NavigationBar.dart';
import 'package:etrade/helper/sqlhelper.dart';
import 'package:etrade/entities/Customer.dart';
import 'package:etrade/entities/Order.dart';
import 'package:etrade/entities/Products.dart';
import 'package:etrade/entities/Sale.dart';
import 'package:etrade/entities/ViewRecovery.dart';
import 'package:etrade/main.dart';
import 'package:etrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  CartScreen(
      {required this.selectedItems,
      required this.iD,
      required this.date,
      required this.userID,
      required this.selecedCustomer});
  List<Product> selectedItems;
  Customer selecedCustomer;
  int iD;
  int userID;
  String date;

  int getTotalQuantity() {
    int temp = 0;
    if (selectedItems.isNotEmpty) {
      selectedItems.forEach((element) {
        temp += element.Quantity;
      });
    }
    return temp;
  }

  double getTotalAmount() {
    double temp = 0;
    if (selectedItems.isNotEmpty) {
      selectedItems.forEach((element) {
        temp += (element.Price * element.Quantity);
      });
    }
    return temp;
  }

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  ScrollController _controller = ScrollController();

  DateFormat showDateFormat = DateFormat('dd-MM-yyyy');
  DateFormat storedateFormat = DateFormat('yyyy-MM-dd');
  TextEditingController controller = TextEditingController();
  String description = '';
  bool isCash = TakeOrderScreen.isSaleSpot ? true : false;
  double totalDiscount = 0;
  double totalAmount = 0;
  int nowtime = int.parse(DateFormat('ddMMyyhhmmss').format(DateTime.now()));
  int totalQuantity = 0;
  @override
  void initState() {
    totalAmount = widget.getTotalAmount();
    totalQuantity = widget.getTotalQuantity();
    if (TakeOrderScreen.isEditOrder || TakeOrderScreen.isEditSale) {
      controller.text = Edit.getDescription();
      description = controller.text;
      if (TakeOrderScreen.isEditSale) {
        isCash = Edit.getisCash();
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            backgroundColor: etradeMainColor,
            toolbarHeight: 80,
            leading: IconButton(
              onPressed: () {
                TakeOrderScreen.isSelected = true;
                Navigator.pushAndRemoveUntil(
                    context,
                    MyCustomRoute(
                        builder: (context) => MyNavigationBar(
                              editRecovery: ViewRecovery.initializer(),
                              selectedIndex: 1,
                              list: [],
                              date: widget.date,
                              id: widget.iD,
                              partyName: "Search Customer",
                            ),
                        slide: "Right"),
                    (route) => false);
              },
              icon: Icon(
                Icons.arrow_back,
              ),
            ),
            title: Text(
              TakeOrderScreen.isSaleSpot ? 'Sale Detail' : 'Order Detail',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: widget.selectedItems.isEmpty
              ? Center(
                  child: Text("There is no Item in Cart."),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${widget.selecedCustomer.partyName} ",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: etradeMainColor),
                            ),
                            Text(
                              "(${TakeOrderScreen.isEditOrder ? widget.date : showDateFormat.format(DateTime.now())})",
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      TakeOrderScreen.isSaleSpot || TakeOrderScreen.isEditSale
                          ? Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Switch(
                                    value: isCash,
                                    activeColor: etradeMainColor,
                                    onChanged: (value) async {
                                      setState(() {
                                        isCash = value;
                                      });
                                    },
                                  ),
                                  Text(
                                    isCash ? "Cash" : "Credit",
                                    style: TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ListView.builder(
                          controller: _controller,
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            return Card(
                                child: MaterialButton(
                              elevation: 20,
                              onPressed: () {
                                setState(() {
                                  AddItemIntoCart(
                                      widget.selecedCustomer.discount,
                                      widget.selectedItems[index].Quantity,
                                      context,
                                      widget.selectedItems[index],
                                      CartScreen(
                                        selectedItems: getCartList(),
                                        selecedCustomer: widget.selecedCustomer,
                                        iD: widget.iD,
                                        userID: widget.userID,
                                        date: widget.date,
                                      ));
                                });
                              },
                              minWidth: double.infinity,
                              height: 60,
                              child: ListTile(
                                horizontalTitleGap: 20,
                                title: Text(
                                  widget.selectedItems[index].Title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Qty: ${widget.selectedItems[index].Quantity}",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    Text(
                                      "Rate: ${widget.selectedItems[index].Price}",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    Text(
                                      "Value: ${formatter.format(widget.selectedItems[index].Price * widget.selectedItems[index].Quantity)}",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      getCartList().removeAt(index);
                                      totalQuantity = widget.getTotalQuantity();
                                      totalAmount = widget.getTotalAmount();
                                    });
                                  },
                                  icon: Icon(Icons.remove_circle_outline),
                                ),
                              ),
                            ));
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
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              child: BottomAppBar(
                elevation: 50,
                child: Container(
                  decoration: BoxDecoration(
                      color: MyApp.isDark
                          ? Color(0xff424242)
                          : Colors.grey.shade100,
                      border: Border(
                        top: BorderSide(color: etradeMainColor, width: 4),
                      )),
                  height: (isLandscape) ? 170 : 220.0,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: TextField(
                              minLines:
                                  2, // any number you need (It works as the rows for the textarea)
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              maxLength: 270,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              // inputFormatters: [
                              //   LengthLimitingTextInputFormatter(100),
                              // ],
                              controller: controller,
                              onChanged: (value) {
                                setState(() {
                                  description = value.toLowerCase();
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 20.0)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: etradeMainColor),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelText: 'Description',
                                // labelStyle: TextStyle(color: etradeMainColor),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total Qty: $totalQuantity",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          // color: Colors.white
                                        ),
                                      ),
                                      Text(
                                        "Total Value: ${formatter.format(totalAmount)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          // color: Colors.white
                                        ),
                                      ),
                                    ]),
                              ]),
                        ),
                        MaterialButton(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0))),
                            disabledColor: Colors.grey,
                            disabledTextColor: Colors.white,
                            onPressed: widget.selectedItems.isEmpty
                                ? null
                                : TakeOrderScreen.isEditOrder ||
                                        TakeOrderScreen.isEditSale
                                    ? () async {
                                        if (TakeOrderScreen.isEditOrder) {
                                          await SQLHelper.deleteItem(
                                              "OrderDetail",
                                              "OrderID",
                                              widget.iD);

                                          widget.selectedItems
                                              .forEach((element) async {
                                            await SQLHelper.instance
                                                .createOrderDetail(
                                                    element,
                                                    widget.iD,
                                                    storedateFormat
                                                        .format(DateTime.now()),
                                                    false,
                                                    widget.userID);
                                          });
                                          List<Map<String, dynamic>> orderRes =
                                              await SQLHelper.instance.getTable(
                                                  "OrderDetail", "OrderID");
                                          await SQLHelper.updateOrderTable(
                                              widget.iD,
                                              widget.selecedCustomer.partyId,
                                              description);
                                          TakeOrderScreen.isEditOrder = false;
                                          TakeOrderScreen.isSelected = false;
                                          resetCartList();
                                          TakeOrderScreen.setParty(
                                              Customer.initializer());
                                          await TakeOrderScreen.getdataFromDb();
                                          controller.clear();
                                          Get.off(
                                              MyNavigationBar.initializer(2),
                                              transition:
                                                  Transition.rightToLeft,
                                              duration:
                                                  Duration(milliseconds: 700));
                                        } else {
                                          await SQLHelper.deleteItem(
                                              "SaleDetail",
                                              "InvoiceID",
                                              widget.iD);

                                          widget.selectedItems
                                              .forEach((element) async {
                                            await SQLHelper.instance
                                                .createSaleDetail(
                                                    element,
                                                    widget.iD,
                                                    storedateFormat
                                                        .format(DateTime.now()),
                                                    false,
                                                    widget.userID);
                                          });

                                          await SQLHelper.updateSaleTable(
                                              widget.iD,
                                              widget.selecedCustomer.partyId,
                                              description,
                                              isCash);
                                          setState(() {
                                            TakeOrderScreen.isEditSale = false;
                                            TakeOrderScreen.isSelected = false;
                                            controller.clear();
                                            TakeOrderScreen.setParty(
                                                Customer.initializer());
                                            resetCartList();
                                          });
                                          await TakeOrderScreen.getdataFromDb();
                                          Get.off(
                                              MyNavigationBar.initializer(2),
                                              transition:
                                                  Transition.rightToLeft,
                                              duration:
                                                  Duration(milliseconds: 700));
                                        }
                                      }
                                    : TakeOrderScreen.isSaleSpot
                                        ? () async {
                                            Sale sale = Sale(
                                              customer: widget.selecedCustomer,
                                              userID: widget.userID,
                                              isCash: isCash,
                                              totalQuantity: totalQuantity,
                                              saleID: nowtime.toString(),
                                              totalValue: totalAmount,
                                              date: storedateFormat
                                                  .format(DateTime.now()),
                                              description: description,
                                            );
                                            bool isPosted = false;
                                            int saleID = await SQLHelper
                                                .instance
                                                .createSale(sale, isPosted);
                                            List<Map<String, dynamic>> saleRes =
                                                await SQLHelper.instance
                                                    .getTable(
                                                        "Sale", "InvoiceID");
                                            var maptoListOrder =
                                                saleRes.whereType<Map>().first;
                                            var dated = maptoListOrder['Dated'];
                                            for (var element
                                                in widget.selectedItems) {
                                              await SQLHelper.instance
                                                  .createSaleDetail(
                                                      element,
                                                      nowtime,
                                                      dated,
                                                      isPosted,
                                                      widget.userID);
                                            }
                                            TakeOrderScreen.getdataFromDb();
                                            setState(() {
                                              TakeOrderScreen.isordered = true;
                                              TakeOrderScreen.isSelected =
                                                  false;
                                              TakeOrderScreen.isSaleSpot =
                                                  false;
                                              controller.clear();
                                              resetCartList();
                                              Get.off(
                                                  MyNavigationBar.initializer(
                                                      1),
                                                  transition:
                                                      Transition.leftToRight,
                                                  duration: Duration(
                                                      milliseconds: 700));
                                            });
                                          }
                                        : () async {
                                            Order order = Order(
                                              customer: widget.selecedCustomer,
                                              userID: widget.userID,
                                              totalQuantity: totalQuantity,
                                              orderID: nowtime,
                                              totalValue: totalAmount,
                                              date: storedateFormat
                                                  .format(DateTime.now()),
                                              description: description,
                                            );
                                            bool isPosted = false;
                                            int orderId = await SQLHelper
                                                .instance
                                                .createOrder(order, isPosted);
                                            List<Map<String, dynamic>>
                                                orderRes = await SQLHelper
                                                    .instance
                                                    .getTable(
                                                        "Order", "OrderID");
                                            var maptoListOrder =
                                                orderRes.whereType<Map>().first;
                                            var dated = maptoListOrder['Dated'];
                                            for (var element
                                                in widget.selectedItems) {
                                              await SQLHelper.instance
                                                  .createOrderDetail(
                                                      element,
                                                      nowtime,
                                                      dated,
                                                      isPosted,
                                                      widget.userID);
                                            }
                                            await TakeOrderScreen
                                                .getdataFromDb();
                                            setState(() {
                                              TakeOrderScreen.isSelected =
                                                  false;
                                              TakeOrderScreen.isordered = true;
                                              controller.clear();
                                              resetCartList();
                                            });
                                            // DashBoardScreen.dashBoard =
                                            //     await DashBoardScreen
                                            //         .getOrderHistory(true);
                                            Get.off(
                                                MyNavigationBar.initializer(1),
                                                transition:
                                                    Transition.leftToRight,
                                                duration: Duration(
                                                    milliseconds: 700));
                                          },
                            minWidth: double.infinity,
                            height: 40,
                            color: etradeMainColor,
                            child: Text(
                              TakeOrderScreen.isEditOrder
                                  ? "Update Order"
                                  : TakeOrderScreen.isEditSale
                                      ? "Update Sale"
                                      : "Save",
                              style: TextStyle(color: Colors.white),
                            )),
                      ],
                    ),
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
