import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/components/SearchListOrder.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Edit.dart';
import 'package:eTrade/entities/ViewBooking.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/entities/ViewSale.dart';
import 'package:eTrade/main.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/SaleDetailScreen.dart';
import 'package:eTrade/screen/NavigationScreen/DashBoard/DashboardScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/ViewBookingScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/OrderDetailScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/components/AddItemModelSheet.dart';
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

  static List listOfItems = [];
  static Future<List<Edit>> getOrderDetail(int id) async {
    List orderDetail = await SQLHelper.getOrderDetail(id);
    var getDetail = Edit.ViewOrderFromDb(orderDetail);
    return getDetail;
  }

  static Future<List<Edit>> getSaleDetail(int id) async {
    List saleDetail = await SQLHelper.getSaleDetail(id);
    var getDetail = Edit.ViewOrderFromDb(saleDetail);
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
  var _item;

  @override
  void initState() {
    BookingTabBarItem.listOfItems = [];
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

  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  checkListDateAvialable(String tabName) async {
    if (widget.tabName == "Search") {
      _item = ViewBookingScreen.isSaleBooking
          ? await SQLHelper.getFromToViewSale(
              BookingTabBarItem.getFromDate(), BookingTabBarItem.getToDate())
          : await SQLHelper.getFromToViewOrder(
              BookingTabBarItem.getFromDate(), BookingTabBarItem.getToDate());
    } else if (widget.tabName == "Today") {
      String todayDate = dateFormat.format(DateTime.now());
      _item = ViewBookingScreen.isSaleBooking
          ? await SQLHelper.getSpecificViewSale(todayDate)
          : await SQLHelper.getSpecificViewOrder(todayDate);
    } else if (widget.tabName == "Yesterday") {
      String yesterdayDate =
          dateFormat.format(DateTime.now().subtract(Duration(days: 1)));
      _item = ViewBookingScreen.isSaleBooking
          ? await SQLHelper.getSpecificViewSale(yesterdayDate)
          : await SQLHelper.getSpecificViewOrder(yesterdayDate);
    } else {
      _item = ViewBookingScreen.isSaleBooking
          ? await SQLHelper.getAllViewSale()
          : await SQLHelper.getAllViewOrder();
    }
    setState(() {
      if (_item.isNotEmpty) {
        BookingTabBarItem.listOfItems = ViewBookingScreen.isSaleBooking
            ? ViewSaleBooking.ViewSaleFromDb(_item)
            : ViewOrderBooking.ViewOrderFromDb(_item);
      } else {
        BookingTabBarItem.listOfItems = [];
      }
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    // setState(() {
    if (args.value is PickerDateRange) {
      range = '${DateFormat('yyyy-MM-dd').format(args.value.startDate)}/'
          '${DateFormat('yyyy-MM-dd').format(args.value.endDate ?? args.value.startDate)}';
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
            var splitDate = prerange.split('/');
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
                                        _item =
                                            await SQLHelper.getFromToViewOrder(
                                                BookingTabBarItem.getFromDate(),
                                                BookingTabBarItem.getToDate());
                                        BookingTabBarItem.listOfItems =
                                            ViewOrderBooking.ViewOrderFromDb(
                                                _item);
                                        setState(() {
                                          if (BookingTabBarItem
                                              .listOfItems.isNotEmpty) {
                                            BookingTabBarItem.listOfItems;
                                          } else {
                                            BookingTabBarItem.listOfItems = [];
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
            (BookingTabBarItem.listOfItems.isEmpty)
                ? Container()
                : (controller.text == "")
                    ? ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext, index) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Slidable(
                              key: const ValueKey(0),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: ((ViewBookingScreen.isSaleBooking
                                        ? (context) async {
                                            TakeOrderScreen.isEditOrder = false;
                                            TakeOrderScreen.isSaleSpot = false;
                                            TakeOrderScreen.isSelected = false;
                                            resetCartList();
                                            var saleDetail =
                                                await BookingTabBarItem
                                                    .getSaleDetail(
                                                        BookingTabBarItem
                                                            .listOfItems[index]
                                                            .saleID);
                                            TakeOrderScreen.isEditSale = true;
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => MyNavigationBar(
                                                        selectedIndex: 1,
                                                        editRecovery:
                                                            ViewRecovery(
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
                                                                    partyName:
                                                                        "")),
                                                        date: BookingTabBarItem
                                                            .listOfItems[index]
                                                            .saleDate,
                                                        list: saleDetail,
                                                        partyName:
                                                            BookingTabBarItem
                                                                .listOfItems[
                                                                    index]
                                                                .partyName,
                                                        id: BookingTabBarItem
                                                            .listOfItems[index]
                                                            .saleID)));
                                          }
                                        : (context) async {
                                            var orderDetail =
                                                await BookingTabBarItem
                                                    .getOrderDetail(
                                                        BookingTabBarItem
                                                            .listOfItems[index]
                                                            .orderID);
                                            TakeOrderScreen.isEditOrder = true;
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => MyNavigationBar(
                                                        selectedIndex: 1,
                                                        editRecovery:
                                                            ViewRecovery(
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
                                                                    partyName:
                                                                        "")),
                                                        date: BookingTabBarItem
                                                            .listOfItems[index]
                                                            .orderDate,
                                                        list: orderDetail,
                                                        partyName:
                                                            BookingTabBarItem
                                                                .listOfItems[
                                                                    index]
                                                                .partyName,
                                                        id: BookingTabBarItem
                                                            .listOfItems[index]
                                                            .orderID)));
                                          })),
                                    backgroundColor: const Color(0xFF21B7CA),
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Edit',
                                  ),
                                  SlidableAction(
                                    onPressed: ((ViewBookingScreen.isSaleBooking
                                        ? (context) async {
                                            await SQLHelper.deleteItem(
                                                "Sale",
                                                "InvoiceID",
                                                BookingTabBarItem
                                                    .listOfItems[index].saleID);

                                            await SQLHelper.deleteItem(
                                                "SaleDetail",
                                                "InvoiceID",
                                                BookingTabBarItem
                                                    .listOfItems[index].saleID);

                                            if (widget.tabName == "Search") {
                                              _item = await SQLHelper
                                                  .getFromToViewSale(
                                                      BookingTabBarItem
                                                          .getFromDate(),
                                                      BookingTabBarItem
                                                          .getToDate());
                                            } else if (widget.tabName ==
                                                "Today") {
                                              String todayDate = dateFormat
                                                  .format(DateTime.now());
                                              _item = await SQLHelper
                                                  .getSpecificViewSale(
                                                      todayDate);
                                            } else if (widget.tabName ==
                                                "Yesterday") {
                                              String yesterdayDate =
                                                  dateFormat.format(
                                                      DateTime.now().subtract(
                                                          Duration(days: 1)));
                                              _item = await SQLHelper
                                                  .getSpecificViewSale(
                                                      yesterdayDate);
                                            } else {
                                              _item = await SQLHelper
                                                  .getAllViewSale();
                                            }
                                            BookingTabBarItem.listOfItems =
                                                ViewSaleBooking.ViewSaleFromDb(
                                                    _item);
                                            setState(() {
                                              BookingTabBarItem.listOfItems;
                                            });
                                          }
                                        : (context) async {
                                            await SQLHelper.deleteItem(
                                                "Order",
                                                "OrderID",
                                                BookingTabBarItem
                                                    .listOfItems[index]
                                                    .orderID);

                                            await SQLHelper.deleteItem(
                                                "OrderDetail",
                                                "OrderID",
                                                BookingTabBarItem
                                                    .listOfItems[index]
                                                    .orderID);

                                            if (widget.tabName == "Search") {
                                              _item = await SQLHelper
                                                  .getFromToViewOrder(
                                                      BookingTabBarItem
                                                          .getFromDate(),
                                                      BookingTabBarItem
                                                          .getToDate());
                                            } else if (widget.tabName ==
                                                "Today") {
                                              String todayDate = dateFormat
                                                  .format(DateTime.now());
                                              _item = await SQLHelper
                                                  .getSpecificViewOrder(
                                                      todayDate);
                                            } else if (widget.tabName ==
                                                "Yesterday") {
                                              String yesterdayDate =
                                                  dateFormat.format(
                                                      DateTime.now().subtract(
                                                          Duration(days: 1)));
                                              _item = await SQLHelper
                                                  .getSpecificViewOrder(
                                                      yesterdayDate);
                                            } else {
                                              _item = await SQLHelper
                                                  .getAllViewOrder();
                                            }
                                            BookingTabBarItem.listOfItems =
                                                ViewOrderBooking
                                                    .ViewOrderFromDb(_item);
                                            setState(() {
                                              BookingTabBarItem.listOfItems;
                                            });
                                            DashBoardScreen.dashBoard =
                                                await DashBoardScreen
                                                    .getOrderHistory();
                                          })),
                                    backgroundColor: const Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
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
                                              ViewBookingScreen.isSaleBooking
                                                  ? "SaleID: #${BookingTabBarItem.listOfItems[index].saleID}"
                                                  : "OrderID: #${BookingTabBarItem.listOfItems[index].orderID}",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            Text(
                                              " ${BookingTabBarItem.listOfItems[index].partyName}",
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
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                  ViewBookingScreen
                                                          .isSaleBooking
                                                      ? "${BookingTabBarItem.listOfItems[index].saleDate}"
                                                      : "${BookingTabBarItem.listOfItems[index].orderDate}",
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
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5))),
                                              child: Text(
                                                "${BookingTabBarItem.listOfItems[index].totalQuantity} items",
                                                style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            MaterialButton(
                                              onPressed:
                                                  ViewBookingScreen
                                                          .isSaleBooking
                                                      ? () async {
                                                          var saleDetail = await BookingTabBarItem
                                                              .getSaleDetail(
                                                                  BookingTabBarItem
                                                                      .listOfItems[
                                                                          index]
                                                                      .saleID);
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => SaleDetailScreen(
                                                                      selectedSaleDate: BookingTabBarItem
                                                                          .listOfItems[
                                                                              index]
                                                                          .saleDate,
                                                                      selectedItems:
                                                                          saleDetail,
                                                                      selecedCustomer: BookingTabBarItem
                                                                          .listOfItems[
                                                                              index]
                                                                          .partyName,
                                                                      fromDate:
                                                                          BookingTabBarItem
                                                                              .getFromDate(),
                                                                      toDate: BookingTabBarItem
                                                                          .getToDate(),
                                                                      saleID: BookingTabBarItem
                                                                          .listOfItems[
                                                                              index]
                                                                          .saleID)));
                                                        }
                                                      : () async {
                                                          var orderDetail = await BookingTabBarItem
                                                              .getOrderDetail(
                                                                  BookingTabBarItem
                                                                      .listOfItems[
                                                                          index]
                                                                      .orderID);
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => OrderDetailScreen(
                                                                      selectedOrdeDate: BookingTabBarItem
                                                                          .listOfItems[
                                                                              index]
                                                                          .orderDate,
                                                                      selectedItems:
                                                                          orderDetail,
                                                                      selecedCustomer: BookingTabBarItem
                                                                          .listOfItems[
                                                                              index]
                                                                          .partyName,
                                                                      fromDate:
                                                                          BookingTabBarItem
                                                                              .getFromDate(),
                                                                      toDate: BookingTabBarItem
                                                                          .getToDate(),
                                                                      orderId: BookingTabBarItem
                                                                          .listOfItems[
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
                                                            Radius.circular(
                                                                5))),
                                                child: Text(
                                                  ViewBookingScreen
                                                          .isSaleBooking
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
                        itemCount: BookingTabBarItem.listOfItems.length,
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
