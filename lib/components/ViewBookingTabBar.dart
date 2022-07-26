import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/SearchListOrder.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/components/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/EditOrder.dart';
import 'package:eTrade/entities/ViewBooking.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/main.dart';
import 'package:eTrade/screen/TakeOrderScreen.dart';
import 'package:eTrade/screen/ViewBookingScreen.dart';
import 'package:eTrade/screen/ViewOrderScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class BookingTabBarItem extends StatefulWidget {
  BookingTabBarItem({required this.tabName});
  String tabName;
  static String fromDate = '';
  static String toDate = '';
  static setFromDate(String date) {
    fromDate = date;
  }

  static setToDate(String date) {
    toDate = date;
  }

  static getFromDate() {
    return fromDate;
  }

  static getToDate() {
    return toDate;
  }

  static List<ViewOrderBooking> listOfOrdered = [];
  static Future<List<EditOrder>> getOrderDetail(int id) async {
    List orderDetail = await SQLHelper.getOrderDetail(id);
    var getDetail = EditOrder.ViewOrderFromDb(orderDetail);
    return getDetail;
  }

  @override
  State<BookingTabBarItem> createState() => _BookingTabBarItemState();
}

class _BookingTabBarItemState extends State<BookingTabBarItem> {
  String range = 'Select Date';
  String searchString = "";
  TextEditingController controller = TextEditingController();
  String prerange = 'Select Date';
  var _order;

  @override
  void initState() {
    BookingTabBarItem.listOfOrdered = [];
    if (widget.tabName == "Search") {
      range = BookingTabBarItem.getFromDate() +
              "-" +
              BookingTabBarItem.getToDate() ??
          BookingTabBarItem.getFromDate();
      if (BookingTabBarItem.getFromDate() != "" &&
          BookingTabBarItem.getToDate() != "") {
        setState(() {
          prerange = range;
        });
        checkListDateAvialable(widget.tabName);
      }
    } else if (widget.tabName == "Today") {
      checkListDateAvialable(widget.tabName);
    } else if (widget.tabName == "Yesterday") {
      checkListDateAvialable(widget.tabName);
    } else {
      checkListDateAvialable(widget.tabName);
    }

    super.initState();
  }

  DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  checkListDateAvialable(String tabName) async {
    if (widget.tabName == "Search") {
      _order = await SQLHelper.getFromToViewOrder(
          BookingTabBarItem.getFromDate(), BookingTabBarItem.getToDate());
    } else if (widget.tabName == "Today") {
      String todayDate = dateFormat.format(DateTime.now());
      _order = await SQLHelper.getSpecificViewOrder(todayDate);
    } else if (widget.tabName == "Yesterday") {
      String yesterdayDate =
          dateFormat.format(DateTime.now().subtract(Duration(days: 1)));
      _order = await SQLHelper.getSpecificViewOrder(yesterdayDate);
    } else {
      _order = await SQLHelper.getAllViewOrder();
    }
    BookingTabBarItem.listOfOrdered = ViewOrderBooking.ViewOrderFromDb(_order);
    setState(() {
      if (BookingTabBarItem.listOfOrdered.isNotEmpty) {
        BookingTabBarItem.listOfOrdered;
      } else {
        BookingTabBarItem.listOfOrdered = [];
      }
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    // setState(() {
    if (args.value is PickerDateRange) {
      range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)}-'
          '${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
    }
  }

  void datePickerBox() {
    Widget cancelButton = TextButton(
        onPressed: (() {
          Navigator.pop(context);
        }),
        child: const Text(
          "Cancel",
          style: TextStyle(color: Color(0xff00620b)),
        ));
    Widget selectedButton = TextButton(
        onPressed: (() {
          setState(() {
            prerange = range;
            var splitDate = prerange.split('-');
            BookingTabBarItem.setFromDate(splitDate[0]);
            BookingTabBarItem.setToDate(splitDate[1]);
          });
          Navigator.pop(context);
        }),
        child:
            const Text("Select", style: TextStyle(color: Color(0xff00620b))));
    List<Widget> LOWidget = [cancelButton, selectedButton];
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    Widget selectDateDialog = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(const Radius.circular(10.0))),
      actions: LOWidget,
      title: const Text("Select Date"),
      content: Container(
        height: (isLandscape) ? height : height / 3,
        width: (isLandscape) ? width / 2.5 : width / 4,
        child: SfDateRangePicker(
          onSelectionChanged: _onSelectionChanged,
          selectionMode: DateRangePickerSelectionMode.range,
          startRangeSelectionColor: Color(0xff00620b),
          endRangeSelectionColor: Color(0xff00620b),
          todayHighlightColor: Color(0xff00620b),

          // view: ,
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (context) {
          return selectDateDialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.tabName == "Search")
                ? Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 20.0, right: 20.0),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Flexible(
                              child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: Colors.grey, width: 1)),
                                  onPressed: (() {
                                    datePickerBox();
                                  }),
                                  child: Text(
                                    "${prerange}",
                                    style: TextStyle(
                                        fontSize: 19,
                                        color: (MyApp.isDark)
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.normal),
                                  )),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Color(0xff00620b)),
                                onPressed: prerange == "Select Date"
                                    ? null
                                    : () async {
                                        _order =
                                            await SQLHelper.getFromToViewOrder(
                                                BookingTabBarItem.getFromDate(),
                                                BookingTabBarItem.getToDate());
                                        BookingTabBarItem.listOfOrdered =
                                            ViewOrderBooking.ViewOrderFromDb(
                                                _order);
                                        setState(() {
                                          if (BookingTabBarItem
                                              .listOfOrdered.isNotEmpty) {
                                            BookingTabBarItem.listOfOrdered;
                                          } else {
                                            BookingTabBarItem.listOfOrdered =
                                                [];
                                          }
                                        });
                                      },
                                child: const Text('Get Date'))
                          ],
                        ),
                      ),
                      Divider(
                        color: Color(0xff00620b),
                        thickness: 2,
                        height: 50,
                      )
                    ],
                  )
                : Padding(padding: EdgeInsets.all(10)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: TextFormField(
                keyboardType: TextInputType.name,
                controller: controller,
                onChanged: (value) {
                  setState(() {
                    searchString = value.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xff00620b)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xff00620b)),
                  ),
                  labelText: 'Search CustomerName',
                  // labelStyle: const TextStyle(color: Colors.grey),
                  suffixIcon: Icon(
                    Icons.search,
                    color: Color(0xff00620b),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            (widget.tabName != "Search")
                ? Divider(
                    color: Color(0xff00620b),
                    thickness: 2,
                    height: 50,
                  )
                : Container(),
            (BookingTabBarItem.listOfOrdered.isEmpty)
                ? Container()
                : (controller.text == "")
                    ? ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext, index) {
                          return Slidable(
                            key: const ValueKey(0),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: SlidableAction(
                                      onPressed: (((context) async {
                                        var orderDetail =
                                            await BookingTabBarItem
                                                .getOrderDetail(
                                                    BookingTabBarItem
                                                        .listOfOrdered[index]
                                                        .orderID);
                                        TakeOrderScreen.isEditOrder = true;
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MyNavigationBar(
                                                        selectedIndex: 1,
                                                        editRecovery:
                                                            ViewRecovery(
                                                                amount: 0,
                                                                description: "",
                                                                recoveryID: 0,
                                                                dated: "",
                                                                party: Customer(
                                                                    discount: 0,
                                                                    address: "",
                                                                    partyId: 0,
                                                                    partyName:
                                                                        "")),
                                                        orderDate:
                                                            BookingTabBarItem
                                                                .listOfOrdered[
                                                                    index]
                                                                .orderDate,
                                                        orderList: orderDetail,
                                                        orderPartyName:
                                                            BookingTabBarItem
                                                                .listOfOrdered[
                                                                    index]
                                                                .partyName,
                                                        orderId:
                                                            BookingTabBarItem
                                                                .listOfOrdered[
                                                                    index]
                                                                .orderID)));
                                      })),
                                      backgroundColor: const Color(0xFF21B7CA),
                                      foregroundColor: Colors.white,
                                      icon: Icons.edit,
                                      label: 'Edit',
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: SlidableAction(
                                      onPressed: (((context) async {
                                        await SQLHelper.deleteItem(
                                            "Order",
                                            "OrderID",
                                            BookingTabBarItem
                                                .listOfOrdered[index].orderID);

                                        await SQLHelper.deleteItem(
                                            "OrderDetail",
                                            "OrderID",
                                            BookingTabBarItem
                                                .listOfOrdered[index].orderID);

                                        if (widget.tabName == "Search") {
                                          _order = await SQLHelper
                                              .getFromToViewOrder(
                                                  BookingTabBarItem
                                                      .getFromDate(),
                                                  BookingTabBarItem
                                                      .getToDate());
                                        } else if (widget.tabName == "Today") {
                                          String todayDate =
                                              dateFormat.format(DateTime.now());
                                          _order = await SQLHelper
                                              .getSpecificViewOrder(todayDate);
                                        } else if (widget.tabName ==
                                            "Yesterday") {
                                          String yesterdayDate =
                                              dateFormat.format(DateTime.now()
                                                  .subtract(Duration(days: 1)));
                                          _order = await SQLHelper
                                              .getSpecificViewOrder(
                                                  yesterdayDate);
                                        } else {
                                          _order =
                                              await SQLHelper.getAllViewOrder();
                                        }
                                        BookingTabBarItem.listOfOrdered =
                                            ViewOrderBooking.ViewOrderFromDb(
                                                _order);
                                        setState(() {
                                          BookingTabBarItem.listOfOrdered;
                                        });
                                      })),
                                      backgroundColor: const Color(0xFFFE4A49),
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Container(
                                height: 110,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: (MyApp.isDark)
                                        ? Color(0xff424242)
                                        : Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(0.0, 0.5), //(x,y)
                                        blurRadius: 3.0,
                                      ),
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "OrderId: #${BookingTabBarItem.listOfOrdered[index].orderID}",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          Text(
                                            " ${BookingTabBarItem.listOfOrdered[index].partyName}",
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
                                              Text("Order On",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                "${BookingTabBarItem.listOfOrdered[index].orderDate}",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                color: Color(0xff00620b),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5))),
                                            child: Text(
                                              "${BookingTabBarItem.listOfOrdered[index].totalQuantity} items",
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          MaterialButton(
                                            onPressed: () async {
                                              var orderDetail =
                                                  await BookingTabBarItem
                                                      .getOrderDetail(
                                                          BookingTabBarItem
                                                              .listOfOrdered[
                                                                  index]
                                                              .orderID);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => ViewOrderScreen(
                                                          selectedOrdeDate:
                                                              BookingTabBarItem
                                                                  .listOfOrdered[
                                                                      index]
                                                                  .orderDate,
                                                          selectedItems:
                                                              orderDetail,
                                                          selecedCustomer:
                                                              BookingTabBarItem
                                                                  .listOfOrdered[
                                                                      index]
                                                                  .partyName,
                                                          fromDate:
                                                              BookingTabBarItem
                                                                  .getFromDate(),
                                                          toDate:
                                                              BookingTabBarItem
                                                                  .getToDate(),
                                                          orderId:
                                                              BookingTabBarItem
                                                                  .listOfOrdered[
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
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5))),
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
                        itemCount: BookingTabBarItem.listOfOrdered.length,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(5),
                        scrollDirection: Axis.vertical,
                      )
                    : ListOfOrder(
                        matchItem: searchString, tabName: widget.tabName),
          ]),
    );
  }
}
