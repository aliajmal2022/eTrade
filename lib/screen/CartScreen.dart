import 'package:eTrade/components/AddItemModelSheet.dart';

import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Order.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/TakeOrderScreen.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  CartScreen(
      {required this.selectedItems,
      required this.orderID,
      required this.orderDate,
      required this.userID,
      required this.selecedCustomer});
  List<Product> selectedItems;
  Customer selecedCustomer;
  int orderID;
  int userID;
  String orderDate;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  ScrollController _controller = ScrollController();

  int getTotalQuantity() {
    int temp = 0;
    if (widget.selectedItems.isNotEmpty) {
      widget.selectedItems.forEach((element) {
        temp += element.Quantity;
      });
    }
    return temp;
  }

  double getTotalAmount() {
    double temp = 0;
    if (widget.selectedItems.isNotEmpty) {
      widget.selectedItems.forEach((element) {
        temp += (element.Price * element.Quantity);
      });
    }
    return temp;
  }

  DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  TextEditingController controller = TextEditingController();
  String description = '';
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double totalAmount = getTotalAmount();
    int totalQuantity = getTotalQuantity();
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
            backgroundColor: Color(0xFF00620b),
            toolbarHeight: 80,
            leading: IconButton(
              onPressed: () {
                TakeOrderScreen.isSelectedOrder = true;
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyNavigationBar(
                        editRecovery: ViewRecovery(
                            amount: 0,
                            description: "",
                            recoveryID: 0,
                            dated: "",
                            party: Customer(
                                partyId: 0, partyName: "", discount: 0)),
                        selectedIndex: 1,
                        orderList: [],
                        orderDate: widget.orderDate,
                        orderId: widget.orderID,
                        orderPartyName: "Search Customer",
                      ),
                    ),
                    (route) => false);
              },
              icon: Icon(
                Icons.arrow_back,
              ),
            ),
            title: Text(
              'Order Detail',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: widget.selectedItems.isEmpty
              ? Center(
                  child: Text("Nothing you add  "),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Row(
                          children: [
                            Center(
                                child: Text(
                              "${widget.selecedCustomer.partyName} ",
                              style: TextStyle(fontSize: 20),
                            )),
                            Center(
                                child: Text(
                              "(${TakeOrderScreen.isEditOrder ? widget.orderDate : dateFormat.format(DateTime.now())})",
                              style: TextStyle(fontSize: 15),
                            )),
                          ],
                        ),
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
                                child: MaterialButton(
                              elevation: 20,
                              onPressed: () {
                                setState(() {
                                  AddItemIntoCart(
                                      widget.selectedItems[index].Quantity,
                                      context,
                                      widget.selectedItems[index],
                                      CartScreen(
                                        selectedItems: getCartList(),
                                        selecedCustomer: widget.selecedCustomer,
                                        orderID: widget.orderID,
                                        userID: widget.userID,
                                        orderDate: widget.orderDate,
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
                                      "Value: ${widget.selectedItems[index].Price * widget.selectedItems[index].Quantity}",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      getCartList().removeAt(index);
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
                      color: Colors.grey.shade100,
                      border: Border(
                        top: BorderSide(color: Color(0xff00620b), width: 4),
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
                                enabledBorder: OutlineInputBorder(
                                    // borderSide: BorderSide(color: Colors.white),
                                    ),
                                focusedBorder: OutlineInputBorder(
                                    // borderSide: BorderSide(color: Colors.white),
                                    ),
                                // fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.black),
                                // focusColor: Colors.white,
                                labelText: 'Description',
                              ),
                            ),
                          ),
                        ),
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
                        MaterialButton(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0))),
                            disabledElevation: 10.0,
                            disabledColor: Color(0x0ff1e1e1),
                            disabledTextColor: Colors.white30,
                            onPressed: widget.selectedItems.isEmpty
                                ? null
                                : TakeOrderScreen.isEditOrder
                                    ? () async {
                                        await SQLHelper.deleteItem(
                                            "OrderDetail",
                                            "OrderID",
                                            widget.orderID);

                                        widget.selectedItems
                                            .forEach((element) async {
                                          await SQLHelper.instance
                                              .createOrderDetail(
                                                  element,
                                                  widget.orderID,
                                                  dateFormat
                                                      .format(DateTime.now()),
                                                  false,
                                                  widget.userID);
                                        });
                                        List<Map<String, dynamic>> orderRes =
                                            await SQLHelper.instance.getTable(
                                                "OrderDetail", "OrderID");
                                        await SQLHelper.updateOrderTable(
                                            widget.orderID,
                                            widget.selecedCustomer.partyId,
                                            description);
                                        setState(() {
                                          TakeOrderScreen.isEditOrder = false;
                                          TakeOrderScreen.isordered = true;
                                          TakeOrderScreen.isSelectedOrder =
                                              false;
                                          controller.clear();
                                          resetCartList();
                                          TakeOrderScreen.getdataFromDb();
                                        });
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MyNavigationBar(
                                                selectedIndex: 2,
                                                editRecovery: ViewRecovery(
                                                    amount: 0,
                                                    description: "",
                                                    recoveryID: 0,
                                                    dated: "",
                                                    party: Customer(
                                                        discount: 0,
                                                        partyId: 0,
                                                        partyName: "")),
                                                orderList: [],
                                                orderId: 0,
                                                orderDate: "",
                                                orderPartyName:
                                                    "Search Customer",
                                              ),
                                            ),
                                            (route) => false);
                                      }
                                    : () async {
                                        Order order = Order(
                                          customer: widget.selecedCustomer,
                                          userID: widget.userID,
                                          totalQuantity: totalQuantity,
                                          orderID: 0,
                                          totalValue: totalAmount,
                                          date:
                                              dateFormat.format(DateTime.now()),
                                          description: description,
                                        );
                                        bool isPosted = false;
                                        int orderId = await SQLHelper.instance
                                            .createOrder(order, isPosted);
                                        List<Map<String, dynamic>> orderRes =
                                            await SQLHelper.instance
                                                .getTable("Order", "OrderID");
                                        var maptoListOrder =
                                            orderRes.whereType<Map>().first;
                                        var dated = maptoListOrder['Dated'];
                                        TakeOrderScreen.getdataFromDb();
                                        print(dated);
                                        for (var element
                                            in widget.selectedItems) {
                                          await SQLHelper.instance
                                              .createOrderDetail(
                                                  element,
                                                  orderId,
                                                  dated,
                                                  isPosted,
                                                  widget.userID);
                                        }
                                        setState(() {
                                          TakeOrderScreen.isSelectedOrder =
                                              false;
                                          TakeOrderScreen.isordered = true;
                                          controller.clear();
                                          resetCartList();
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MyNavigationBar(
                                                  selectedIndex: 1,
                                                  editRecovery: ViewRecovery(
                                                      amount: 0,
                                                      description: "",
                                                      recoveryID: 0,
                                                      dated: "",
                                                      party: Customer(
                                                          partyId: 0,
                                                          discount: 0,
                                                          partyName: "")),
                                                  orderList: [],
                                                  orderDate: "",
                                                  orderId: 0,
                                                  orderPartyName:
                                                      "Search Customer",
                                                ),
                                              ),
                                              (route) => false);
                                        });
                                      },
                            minWidth: double.infinity,
                            height: 40,
                            color: Color(0xff00620b),
                            child: Text(
                              TakeOrderScreen.isEditOrder
                                  ? "Update Order"
                                  : "Save Order",
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
