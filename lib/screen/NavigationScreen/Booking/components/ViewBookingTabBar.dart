import 'package:etrade/components/CustomNavigator.dart';
import 'package:etrade/components/NavigationBar.dart';
import 'package:etrade/components/constants.dart';
import 'package:etrade/screen/NavigationScreen/Booking/components/SearchListViewBooking.dart';
import 'package:etrade/components/drawer.dart';
import 'package:etrade/helper/sqlhelper.dart';
import 'package:etrade/entities/Customer.dart';
import 'package:etrade/entities/Edit.dart';
import 'package:etrade/entities/ViewBooking.dart';
import 'package:etrade/entities/ViewRecovery.dart';
import 'package:etrade/main.dart';
import 'package:etrade/screen/NavigationScreen/Booking/SaleDetailScreen.dart';
import 'package:etrade/screen/NavigationScreen/DashBoard/DashboardScreen.dart';
import 'package:etrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:etrade/screen/NavigationScreen/Booking/ViewBookingScreen.dart';
import 'package:etrade/screen/NavigationScreen/Booking/OrderDetailScreen.dart';
import 'package:etrade/screen/NavigationScreen/Take%20Order/components/AddItemModelSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
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
    var getDetail = Edit.ViewFromDb(orderDetail, false);
    return getDetail;
  }

  static Future<List<Edit>> getSaleDetail(int id) async {
    List saleDetail = await SQLHelper.getSaleDetail(id);
    var getDetail = Edit.ViewFromDb(saleDetail, true);
    return getDetail;
  }

  @override
  State<BookingTabBarItem> createState() => _BookingTabBarItemState();
}

class _BookingTabBarItemState extends State<BookingTabBarItem>
    with TickerProviderStateMixin {
  var _animationController;
  String range = 'Select Date';
  String searchString = "";
  TextEditingController controller = TextEditingController();
  String prerange = 'Select Date';
  var _item;

  @override
  void dispose() {
    _animationController.dispose();
    build(context);
    super.dispose();
  }

  preloadData() {
    setState(() {
      _animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 300));
      _animationController.forward();
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
    });
  }

  @override
  void initState() {
    super.initState();
    preloadData();
  }

  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
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
            ? ViewBooking.ViewSaleFromDb(_item)
            : ViewBooking.ViewOrderFromDb(_item);
      } else {
        BookingTabBarItem.listOfItems = [];
      }
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    // setState(() {
    if (args.value is PickerDateRange) {
      range = '${DateFormat('dd-MM-yyyy').format(args.value.startDate)}/'
          '${DateFormat('dd-MM-yyyy').format(args.value.endDate ?? args.value.startDate)}';
    }
  }

  void datePickerBox() {
    Widget cancelButton = TextButton(
        onPressed: (() {
          Navigator.pop(context);
        }),
        child: const Text(
          "Cancel",
          style: TextStyle(color: etradeMainColor),
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
        child: const Text("Select", style: TextStyle(color: etradeMainColor)));
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
          startRangeSelectionColor: etradeMainColor,
          endRangeSelectionColor: etradeMainColor,
          todayHighlightColor: etradeMainColor,

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
                ? SlideTransition(
                    position:
                        Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                            .animate(_animationController),
                    child: Column(
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
                                      primary: etradeMainColor),
                                  onPressed: prerange == "Select Date"
                                      ? null
                                      : ViewBookingScreen.isSaleBooking
                                          ? () async {
                                              _item = await SQLHelper
                                                  .getFromToViewSale(
                                                      BookingTabBarItem
                                                          .getFromDate(),
                                                      BookingTabBarItem
                                                          .getToDate());
                                              BookingTabBarItem.listOfItems =
                                                  ViewBooking.ViewSaleFromDb(
                                                      _item);
                                              setState(() {
                                                if (BookingTabBarItem
                                                    .listOfItems.isNotEmpty) {
                                                  BookingTabBarItem.listOfItems;
                                                } else {
                                                  BookingTabBarItem
                                                      .listOfItems = [];
                                                }
                                              });
                                            }
                                          : () async {
                                              _item = await SQLHelper
                                                  .getFromToViewOrder(
                                                      BookingTabBarItem
                                                          .getFromDate(),
                                                      BookingTabBarItem
                                                          .getToDate());
                                              BookingTabBarItem.listOfItems =
                                                  ViewBooking.ViewOrderFromDb(
                                                      _item);
                                              setState(() {
                                                if (BookingTabBarItem
                                                    .listOfItems.isNotEmpty) {
                                                  BookingTabBarItem.listOfItems;
                                                } else {
                                                  BookingTabBarItem
                                                      .listOfItems = [];
                                                }
                                              });
                                            },
                                  child: const Text('Get Date'))
                            ],
                          ),
                        ),
                        Divider(
                          color: etradeMainColor,
                          thickness: 2,
                          height: 50,
                        )
                      ],
                    ))
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
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: etradeMainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: etradeMainColor),
                  ),
                  labelText: 'Search CustomerName',
                  // labelStyle: const TextStyle(color: Colors.grey),
                  suffixIcon: Icon(
                    Icons.search,
                    color: etradeMainColor,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            (widget.tabName != "Search")
                ? Divider(
                    color: etradeMainColor,
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
                          return (MyNavigationBar.isAdmin)
                              ? SlideTransition(
                                  position: Tween<Offset>(
                                          begin: Offset(1, 0),
                                          end: Offset(0, 0))
                                      .animate(_animationController),
                                  child: FadeTransition(
                                    opacity: _animationController,
                                    child: Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Serial No: ${index + 1}",
                                                    // ViewBookingScreen

                                                    //         .isSaleBooking
                                                    //     ? "Sale Id: ${BookingTabBarItem.listOfItems[index].iD}"
                                                    //     : "Order Id: ${BookingTabBarItem.listOfItems[index].iD}",
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                  Text(
                                                    "${BookingTabBarItem.listOfItems[index].partyName}",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          ViewBookingScreen
                                                                  .isSaleBooking
                                                              ? "Sale On"
                                                              : "Order On",
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.grey,
                                                            // fontWeight:
                                                            //     FontWeight
                                                            //         .bold
                                                          )),
                                                      Text(
                                                        ViewBookingScreen
                                                                .isSaleBooking
                                                            ? "${BookingTabBarItem.listOfItems[index].date}"
                                                            : "${BookingTabBarItem.listOfItems[index].date}",
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            // etradeMainColor,
                                                            Theme.of(context)
                                                                .backgroundColor,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5))),
                                                    child: Text(
                                                      "${BookingTabBarItem.listOfItems[index].totalQuantity} items",
                                                      style: TextStyle(
                                                        // fontStyle: FontStyle.italic,
                                                        // color: Colors.white
                                                        color: ThemeData.light()
                                                            .cardColor,

                                                        // .of(context)
                                                        //     .cardColor,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  MaterialButton(
                                                    onPressed:
                                                        ViewBookingScreen
                                                                .isSaleBooking
                                                            ? () async {
                                                                var saleDetail =
                                                                    await BookingTabBarItem.getSaleDetail(BookingTabBarItem
                                                                        .listOfItems[
                                                                            index]
                                                                        .iD);
                                                                Navigator.push(
                                                                    context,
                                                                    MyCustomRoute(
                                                                        slide:
                                                                            "Left",
                                                                        builder: (context) => SaleDetailScreen(
                                                                            selectedSaleDate:
                                                                                BookingTabBarItem.listOfItems[index].date,
                                                                            selectedItems: saleDetail,
                                                                            selecedCustomer: BookingTabBarItem.listOfItems[index].partyName,
                                                                            fromDate: BookingTabBarItem.getFromDate(),
                                                                            toDate: BookingTabBarItem.getToDate(),
                                                                            saleID: BookingTabBarItem.listOfItems[index].iD)));
                                                              }
                                                            : () async {
                                                                var orderDetail =
                                                                    await BookingTabBarItem.getOrderDetail(BookingTabBarItem
                                                                        .listOfItems[
                                                                            index]
                                                                        .iD);
                                                                Navigator.push(
                                                                    context,
                                                                    MyCustomRoute(
                                                                        slide:
                                                                            "Left",
                                                                        builder: (context) => OrderDetailScreen(
                                                                            selectedOrdeDate:
                                                                                BookingTabBarItem.listOfItems[index].date,
                                                                            selectedItems: orderDetail,
                                                                            selecedCustomer: BookingTabBarItem.listOfItems[index].partyName,
                                                                            fromDate: BookingTabBarItem.getFromDate(),
                                                                            toDate: BookingTabBarItem.getToDate(),
                                                                            orderId: BookingTabBarItem.listOfItems[index].iD)));
                                                              },
                                                    padding: EdgeInsets.zero,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              etradeMainColor,
                                                          // (MyApp.isDark)
                                                          //     ? Colors.white
                                                          //     : Colors
                                                          //         .grey.shade300,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                      child: Text(
                                                        ViewBookingScreen
                                                                .isSaleBooking
                                                            ? "Sale Detail"
                                                            : "Order Detail",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
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
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Slidable(
                                    key: const ValueKey(0),
                                    endActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: ((ViewBookingScreen
                                                  .isSaleBooking
                                              ? (context) async {
                                                  TakeOrderScreen.isEditOrder =
                                                      false;
                                                  TakeOrderScreen.isSaleSpot =
                                                      false;
                                                  TakeOrderScreen.isSelected =
                                                      false;
                                                  resetCartList();
                                                  var saleDetail =
                                                      await BookingTabBarItem
                                                          .getSaleDetail(
                                                              BookingTabBarItem
                                                                  .listOfItems[
                                                                      index]
                                                                  .iD);
                                                  TakeOrderScreen.isEditSale =
                                                      true;
                                                  Navigator.push(
                                                      context,
                                                      MyCustomRoute(
                                                          slide: "Right",
                                                          builder: (context) => MyNavigationBar(
                                                              selectedIndex: 1,
                                                              editRecovery:
                                                                  ViewRecovery
                                                                      .initializer(),
                                                              date: BookingTabBarItem
                                                                  .listOfItems[
                                                                      index]
                                                                  .date,
                                                              list: saleDetail,
                                                              partyName:
                                                                  BookingTabBarItem
                                                                      .listOfItems[
                                                                          index]
                                                                      .partyName,
                                                              id: BookingTabBarItem
                                                                  .listOfItems[
                                                                      index]
                                                                  .iD)));
                                                }
                                              : (context) async {
                                                  var orderDetail =
                                                      await BookingTabBarItem
                                                          .getOrderDetail(
                                                              BookingTabBarItem
                                                                  .listOfItems[
                                                                      index]
                                                                  .iD);
                                                  TakeOrderScreen.isEditSale =
                                                      false;
                                                  TakeOrderScreen.isEditOrder =
                                                      true;
                                                  TakeOrderScreen.isSaleSpot =
                                                      false;
                                                  TakeOrderScreen.isSelected =
                                                      false;
                                                  resetCartList();
                                                  Navigator.push(
                                                      context,
                                                      MyCustomRoute(
                                                          slide: "Right",
                                                          builder: (context) => MyNavigationBar(
                                                              selectedIndex: 1,
                                                              editRecovery:
                                                                  ViewRecovery
                                                                      .initializer(),
                                                              date: BookingTabBarItem
                                                                  .listOfItems[
                                                                      index]
                                                                  .date,
                                                              list: orderDetail,
                                                              partyName:
                                                                  BookingTabBarItem
                                                                      .listOfItems[
                                                                          index]
                                                                      .partyName,
                                                              id: BookingTabBarItem
                                                                  .listOfItems[
                                                                      index]
                                                                  .iD)));
                                                })),
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          icon: Icons.edit,
                                          label: 'Edit',
                                        ),
                                        SlidableAction(
                                          onPressed: ((context) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Really want to detele"),
                                                    action: SnackBarAction(
                                                        label: "Delete",
                                                        onPressed:
                                                            ViewBookingScreen
                                                                    .isSaleBooking
                                                                ? () async {
                                                                    await SQLHelper.deleteItem(
                                                                        "Sale",
                                                                        "InvoiceID",
                                                                        BookingTabBarItem
                                                                            .listOfItems[index]
                                                                            .iD);

                                                                    await SQLHelper.deleteItem(
                                                                        "SaleDetail",
                                                                        "InvoiceID",
                                                                        BookingTabBarItem
                                                                            .listOfItems[index]
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
                                                                      String
                                                                          todayDate =
                                                                          dateFormat
                                                                              .format(DateTime.now());
                                                                      _item = await SQLHelper
                                                                          .getSpecificViewSale(
                                                                              todayDate);
                                                                    } else if (widget
                                                                            .tabName ==
                                                                        "Yesterday") {
                                                                      String
                                                                          yesterdayDate =
                                                                          dateFormat
                                                                              .format(DateTime.now().subtract(Duration(days: 1)));
                                                                      _item = await SQLHelper
                                                                          .getSpecificViewSale(
                                                                              yesterdayDate);
                                                                    } else {
                                                                      _item = await SQLHelper
                                                                          .getAllViewSale();
                                                                    }
                                                                    BookingTabBarItem
                                                                            .listOfItems =
                                                                        ViewBooking.ViewSaleFromDb(
                                                                            _item);
                                                                    setState(
                                                                        () {
                                                                      BookingTabBarItem
                                                                          .listOfItems;
                                                                    });
                                                                    DashBoardScreen
                                                                            .dashBoard =
                                                                        await DashBoardScreen.getOrderHistory(
                                                                            false);
                                                                    Get.off(() =>
                                                                        MyNavigationBar.initializer(
                                                                            2));
                                                                  }
                                                                : () async {
                                                                    await SQLHelper.deleteItem(
                                                                        "Order",
                                                                        "OrderID",
                                                                        BookingTabBarItem
                                                                            .listOfItems[index]
                                                                            .iD);

                                                                    await SQLHelper.deleteItem(
                                                                        "OrderDetail",
                                                                        "OrderID",
                                                                        BookingTabBarItem
                                                                            .listOfItems[index]
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
                                                                      String
                                                                          todayDate =
                                                                          dateFormat
                                                                              .format(DateTime.now());
                                                                      _item = await SQLHelper
                                                                          .getSpecificViewOrder(
                                                                              todayDate);
                                                                    } else if (widget
                                                                            .tabName ==
                                                                        "Yesterday") {
                                                                      String
                                                                          yesterdayDate =
                                                                          dateFormat
                                                                              .format(DateTime.now().subtract(Duration(days: 1)));
                                                                      _item = await SQLHelper
                                                                          .getSpecificViewOrder(
                                                                              yesterdayDate);
                                                                    } else {
                                                                      _item = await SQLHelper
                                                                          .getAllViewOrder();
                                                                    }
                                                                    BookingTabBarItem
                                                                            .listOfItems =
                                                                        ViewBooking.ViewOrderFromDb(
                                                                            _item);
                                                                    setState(
                                                                        () {
                                                                      BookingTabBarItem
                                                                          .listOfItems;
                                                                    });
                                                                    DashBoardScreen
                                                                            .dashBoard =
                                                                        await DashBoardScreen.getOrderHistory(
                                                                            true);
                                                                  })));
                                          }),
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          icon: Icons.edit,
                                          label: 'DELETE',
                                        ),
                                      ],
                                    ),
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                              begin: Offset(1, 0),
                                              end: Offset(0, 0))
                                          .animate(_animationController),
                                      child: FadeTransition(
                                        opacity: _animationController,
                                        child: Card(
                                          child: Padding(
                                            padding: EdgeInsets.all(15.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Serial No: ${index + 1}",
                                                        // ViewBookingScreen

                                                        //         .isSaleBooking
                                                        //     ? "Sale Id: ${BookingTabBarItem.listOfItems[index].iD}"
                                                        //     : "Order Id: ${BookingTabBarItem.listOfItems[index].iD}",
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                      Text(
                                                        "${BookingTabBarItem.listOfItems[index].partyName}",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          // fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              ViewBookingScreen
                                                                      .isSaleBooking
                                                                  ? "Sale On"
                                                                  : "Order On",
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color:
                                                                    Colors.grey,
                                                                // fontWeight:
                                                                //     FontWeight
                                                                //         .bold
                                                              )),
                                                          Text(
                                                            ViewBookingScreen
                                                                    .isSaleBooking
                                                                ? "${BookingTabBarItem.listOfItems[index].date}"
                                                                : "${BookingTabBarItem.listOfItems[index].date}",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
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
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(4),
                                                        decoration:
                                                            BoxDecoration(
                                                                color:
                                                                    // etradeMainColor,
                                                                    Theme.of(
                                                                            context)
                                                                        .backgroundColor,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                        child: Text(
                                                          "${BookingTabBarItem.listOfItems[index].totalQuantity} items",
                                                          style: TextStyle(
                                                            // fontStyle: FontStyle.italic,
                                                            // color: Colors.white
                                                            color: ThemeData
                                                                    .light()
                                                                .cardColor,

                                                            // .of(context)
                                                            //     .cardColor,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      MaterialButton(
                                                        onPressed:
                                                            ViewBookingScreen
                                                                    .isSaleBooking
                                                                ? () async {
                                                                    var saleDetail =
                                                                        await BookingTabBarItem.getSaleDetail(BookingTabBarItem
                                                                            .listOfItems[index]
                                                                            .iD);
                                                                    Navigator.push(
                                                                        context,
                                                                        MyCustomRoute(
                                                                            slide:
                                                                                "Left",
                                                                            builder: (context) => SaleDetailScreen(
                                                                                selectedSaleDate: BookingTabBarItem.listOfItems[index].date,
                                                                                selectedItems: saleDetail,
                                                                                selecedCustomer: BookingTabBarItem.listOfItems[index].partyName,
                                                                                fromDate: BookingTabBarItem.getFromDate(),
                                                                                toDate: BookingTabBarItem.getToDate(),
                                                                                saleID: BookingTabBarItem.listOfItems[index].iD)));
                                                                  }
                                                                : () async {
                                                                    var orderDetail =
                                                                        await BookingTabBarItem.getOrderDetail(BookingTabBarItem
                                                                            .listOfItems[index]
                                                                            .iD);
                                                                    Navigator.push(
                                                                        context,
                                                                        MyCustomRoute(
                                                                            slide:
                                                                                "Left",
                                                                            builder: (context) => OrderDetailScreen(
                                                                                selectedOrdeDate: BookingTabBarItem.listOfItems[index].date,
                                                                                selectedItems: orderDetail,
                                                                                selecedCustomer: BookingTabBarItem.listOfItems[index].partyName,
                                                                                fromDate: BookingTabBarItem.getFromDate(),
                                                                                toDate: BookingTabBarItem.getToDate(),
                                                                                orderId: BookingTabBarItem.listOfItems[index].iD)));
                                                                  },
                                                        padding:
                                                            EdgeInsets.zero,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          decoration:
                                                              BoxDecoration(
                                                                  color:
                                                                      etradeMainColor,
                                                                  // (MyApp.isDark)
                                                                  //     ? Colors.white
                                                                  //     : Colors
                                                                  //         .grey.shade300,
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
                                                                color: Theme.of(
                                                                        context)
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
                                  ),
                                  // ),
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
