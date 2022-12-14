// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:etrade/components/CustomNavigator.dart';
import 'package:etrade/components/constants.dart';
import 'package:etrade/main.dart';
import 'package:etrade/screen/NavigationScreen/DashBoard/DashboardScreen.dart';
import 'package:etrade/screen/NavigationScreen/Take%20Order/components/AddItemModelSheet.dart';
import 'package:etrade/screen/NavigationScreen/Take%20Order/components/ListProduct.dart';
import 'package:etrade/components/NavigationBar.dart';
import 'package:etrade/components/NewCustomer.dart';
import 'package:etrade/helper/Sql_Connection.dart';
import 'package:etrade/components/drawer.dart';
import 'package:etrade/helper/onldt_to_local_db.dart';
import 'package:etrade/helper/sqlhelper.dart';
import 'package:etrade/entities/Customer.dart';
import 'package:etrade/entities/Edit.dart';
import 'package:etrade/entities/Products.dart';
import 'package:etrade/entities/ViewRecovery.dart';
import 'package:etrade/screen/NavigationScreen/Take%20Order/CartScreen.dart';
import 'package:etrade/screen/LoginScreen/LoginScreen.dart';
import 'package:etrade/screen/NavigationScreen/Booking/ViewBookingScreen.dart';
import 'package:find_dropdown/find_dropdown.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';

class TakeOrderScreen extends StatefulWidget {
  TakeOrderScreen(
      {required this.iD,
      required this.list,
      required this.date,
      required this.partyName});
  List<Edit> list;
  int iD;
  String date;
  String partyName;
  @override
  State<TakeOrderScreen> createState() => _TakeOrderScreenState();
  static Customer customer = Customer.initializer();
  static List<Customer> partydb = [];
  static List<Product> productdb = [];
  static bool databaseExit = false;
  static bool isonloading = false;
  static int orderId = 0;
  static String orderDATE = "";
  static int InvoiceID = 0;
  static String saleDATE = "";
  static bool isSaleSpot = false;
  static bool isEditSale = false;

  static Future<bool> getdataFromDb() async {
    bool isExist = await DataBaseDataLoad.DataLoading();
    if (isExist) {
      setPartydb(DataBaseDataLoad.ListOCustomer);

      setProductdb(DataBaseDataLoad.ListOProduct);
      if (partydb.isNotEmpty && productdb.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  static void setPartydb(List<Customer> list) {
    partydb = list;
  }

  static void setProductdb(List<Product> list) {
    productdb = list;
  }

  List<Customer> getPartydb() {
    return partydb;
  }

  List<Product> getProductdb() {
    return productdb;
  }

  static void setParty(Customer selectedCustomer) {
    customer.partyId = selectedCustomer.partyId;
    customer.partyName = selectedCustomer.partyName;
    customer.discount = selectedCustomer.discount;
  }

  Customer getParty() {
    return customer;
  }

  static bool isEditOrder = false;
  static bool isSync = false;
  static bool isordered = false;
  static Future<void> onLoading(
      BuildContext context, bool resetsync, bool isLogin) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          if (resetsync) {
            return Image.asset("images/syncing.gif",
                gaplessPlayback: true, fit: BoxFit.fill);
          }
          return Container();
        });

    Future.delayed(const Duration(seconds: 3), () async {
      isonloading = true;
      if (resetsync) {
        if (MyNavigationBar.isAdmin) {
          await SQLHelper.resetData("Reset", false);
        } else {
          await SQLHelper.resetData("Sync", isLogin);
        }
        await Sql_Connection.PreLoadData(true);
      } else {
        await Sql_Connection.PreLoadData(false);
      }
      resetCartList();
      await DataBaseDataLoad.DataLoading();
      TakeOrderScreen.setPartydb(DataBaseDataLoad.ListOCustomer);
      TakeOrderScreen.setProductdb(DataBaseDataLoad.ListOProduct);

      DashBoardScreen.dashBoard = await DashBoardScreen.getOrderHistory(true);
      Navigator.pushAndRemoveUntil(
          context,
          MyCustomRoute(
              slide: "Left",
              builder: (context) => MyNavigationBar.initializer(0)),
          (route) => false);
    });
  }

  static bool isSelected = false;
  static Future<void> forSaleInVoice() async {
    customer.partyId = 0;
    customer.partyName = "Search Customer";
    customer.discount = 0;
    resetCartList();
    await TakeOrderScreen.getdataFromDb();
  }
}

class _TakeOrderScreenState extends State<TakeOrderScreen>
    with TickerProviderStateMixin {
  var _animationController;
  String searchString = "";
  var controller;
  int quantity = 0;
  bool isConnected = false;

  // static bool ispreloaded = false;
  Future<void> PreLoadDataBase() async {
    if (!TakeOrderScreen.isonloading &&
        !TakeOrderScreen.isEditOrder &&
        !TakeOrderScreen.isEditSale) {
      await TakeOrderScreen.getdataFromDb();
    } else if (TakeOrderScreen.isEditOrder || TakeOrderScreen.isEditSale) {
      if (!TakeOrderScreen.isSelected) {
        TakeOrderScreen.isSelected = true;
        widget.list.forEach((element) {
          Product product = Product(
              Title: element.itemName,
              Price: element.rate,
              ID: element.itemId,
              bonus: element.bonus,
              to: element.to,
              discount: element.discount,
              Quantity: element.quantity);
          setCartList(product);
        });
        var selectedParty = Customer(
            userId: 0,
            balance: 0,
            discount: 0,
            partyIdMobile: 0,
            partyId: 0,
            address: "",
            partyName: widget.partyName);
        selectedParty =
            selectedParty.selectedCustomer(DataBaseDataLoad.ListOCustomer);
        TakeOrderScreen.setParty(selectedParty);
        if (TakeOrderScreen.isEditOrder) {
          TakeOrderScreen.orderId = widget.iD;
          TakeOrderScreen.orderDATE = widget.date;
        } else {
          TakeOrderScreen.InvoiceID = widget.iD;
          TakeOrderScreen.saleDATE = widget.date;
        }
      } else {
        await TakeOrderScreen.getdataFromDb();
      }
    }
    setState(() {
      widget.getPartydb();
      widget.getProductdb();
    });
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _animationController.forward();
    if (TakeOrderScreen.databaseExit ||
        TakeOrderScreen.isEditOrder ||
        TakeOrderScreen.isEditSale ||
        TakeOrderScreen.isSelected ||
        TakeOrderScreen.isSync ||
        TakeOrderScreen.isonloading ||
        TakeOrderScreen.isSaleSpot ||
        TakeOrderScreen.isordered) {
      PreLoadDataBase();
      if (!TakeOrderScreen.isSync && !TakeOrderScreen.isordered) {
        setState(() {
          TakeOrderScreen.setParty(TakeOrderScreen.customer);
        });
      } else if (!TakeOrderScreen.isEditOrder || !TakeOrderScreen.isEditSale) {
        setState(() {
          TakeOrderScreen.setParty(Customer.initializer());
        });
      }
      TakeOrderScreen.isSync = false;
      TakeOrderScreen.isordered = false;
    }
    super.initState();
  }

  Future<List<Customer>> getData(String filter) async {
    List<Customer> customerlist = [];
    DataBaseDataLoad.ListOCustomer.forEach((element) {
      if (element.partyName.toLowerCase().contains(filter.toLowerCase())) {
        customerlist.add(element);
      }
    });
    return customerlist;
  }

  @override
  void dispose() {
    _animationController.dispose();
    build(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: etradeMainColor,
          toolbarHeight: 80,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          automaticallyImplyLeading: false,
          leading: (TakeOrderScreen.isEditOrder || TakeOrderScreen.isEditSale)
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () async {
                    setState(() {
                      if (TakeOrderScreen.isEditOrder) {
                        TakeOrderScreen.isEditOrder = false;
                        TakeOrderScreen.isSelected = false;
                      } else {
                        TakeOrderScreen.isEditSale = false;
                        TakeOrderScreen.isSelected = false;
                      }
                      TakeOrderScreen.setParty(Customer.initializer());
                      resetCartList();
                    });
                    await TakeOrderScreen.getdataFromDb();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MyCustomRoute(
                            builder: (context) => MyNavigationBar(
                                selectedIndex: 2,
                                editRecovery: ViewRecovery.initializer(),
                                list: [],
                                date: widget.date,
                                id: widget.iD,
                                partyName: "Search Customer"),
                            slide: "Left"),
                        (route) => false);
                  },
                )
              : (TakeOrderScreen.isSaleSpot)
                  ? IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () async {
                        setState(() {
                          TakeOrderScreen.isSaleSpot = false;
                          TakeOrderScreen.setParty(Customer.initializer());
                          resetCartList();
                        });
                        await TakeOrderScreen.getdataFromDb();

                        Navigator.pushAndRemoveUntil(
                            context,
                            MyCustomRoute(
                                builder: (context) =>
                                    MyNavigationBar.initializer(1),
                                slide: "Right"),
                            (route) => false);
                      },
                    )
                  : Builder(
                      builder: (BuildContext context) {
                        return IconButton(
                          icon: Icon(
                            Icons.menu,
                          ),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          tooltip: MaterialLocalizations.of(context)
                              .openAppDrawerTooltip,
                        );
                      },
                    ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 6,
                child: Center(
                  child: Text(
                    TakeOrderScreen.isEditOrder
                        ? 'Edit Order'
                        : TakeOrderScreen.isSaleSpot
                            ? 'Sale Invoice'
                            : TakeOrderScreen.isEditSale
                                ? 'Edit Invoice'
                                : 'Take Order',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                    onPressed: (widget.getParty().partyId == 0)
                        ? null
                        : () {
                            Get.off(
                                () => CartScreen(
                                      selectedItems: getCartList(),
                                      userID: MyNavigationBar.userID,
                                      selecedCustomer: widget.getParty(),
                                      date: (TakeOrderScreen.isEditOrder)
                                          ? TakeOrderScreen.orderDATE
                                          : (TakeOrderScreen.isEditSale)
                                              ? TakeOrderScreen.saleDATE
                                              : widget.date,
                                      iD: TakeOrderScreen.isEditOrder
                                          ? TakeOrderScreen.orderId
                                          : (TakeOrderScreen.isEditSale)
                                              ? TakeOrderScreen.InvoiceID
                                              : widget.iD,
                                    ),
                                transition: Transition.rightToLeft,
                                duration: Duration(milliseconds: 500));
                          },
                    // disabledColor: Color(0xff424242),
                    disabledColor: Colors.grey,
                    color: Colors.white,
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 30,
                    )),
              ),
            ],
          ),
        ),
        drawer: MyDrawer(),
        body: (widget.getPartydb().isEmpty && widget.getProductdb().isEmpty)
            ? Center(child: Text("Not Data found in database"))
            : Container(
                padding: EdgeInsets.only(top: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SlideTransition(
                          position: Tween<Offset>(
                                  begin: Offset(1, 0), end: Offset(0, 0))
                              .animate(_animationController),
                          child: FadeTransition(
                            opacity: _animationController,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: FindDropdown<Customer>(
                                      autofocus: true,
                                      label: "Search Customer",
                                      onFind: (String filter) =>
                                          getData(filter),
                                      onChanged: (value) {
                                        setState(() {
                                          TakeOrderScreen.setParty(value!);
                                          TakeOrderScreen.customer = value;
                                        });
                                      },
                                      items: DataBaseDataLoad.ListOCustomer,
                                      dropdownBuilder: (context, item) {
                                        return Container(
                                          height: 49,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                      .disabledColor),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: MyApp.isDark
                                                  ? Color(0xff303030)
                                                  : Color(0xfffafafa)),
                                          child: ListTile(
                                            leading: Text(
                                              (item == null ||
                                                      item.partyId == 0)
                                                  ? "Type Here..."
                                                  : item.partyName,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        );
                                      },
                                      selectedItem: TakeOrderScreen.customer,
                                      searchBoxDecoration: InputDecoration(
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: etradeMainColor,
                                              width: 2,
                                            ),
                                          ),
                                          suffixIcon: Icon(
                                            Icons.search,
                                            color: etradeMainColor,
                                          ),
                                          labelStyle: TextStyle(
                                              color: etradeMainColor)),
                                      dropdownItemBuilder:
                                          (BuildContext context, Customer item,
                                              bool isSelected) {
                                        return Container(
                                          decoration: !isSelected
                                              ? null
                                              : BoxDecoration(
                                                  border: Border.all(
                                                      color: etradeMainColor),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: MyApp.isDark
                                                      ? Color(0xff424242)
                                                      : Colors.white,
                                                ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.partyName,
                                                    style: TextStyle(
                                                        color: !isSelected &&
                                                                !MyApp.isDark
                                                            ? Colors.black54
                                                            : MyApp.isDark
                                                                ? Colors.white
                                                                : Colors.black,
                                                        fontSize: 16),
                                                  ),
                                                  Text(item.address.toString(),
                                                      style: TextStyle(
                                                          color: !isSelected &&
                                                                  !MyApp.isDark
                                                              ? Colors.grey
                                                              : MyApp.isDark
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .black54,
                                                          fontSize: 14)),
                                                ]),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Material(
                                    elevation: 4,
                                    child: Container(
                                        height: 49,
                                        width: 58,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(2)),
                                          // color: Colors.white,
                                          color: etradeMainColor,
                                          // color: Color(0xff424242),
                                        ),
                                        child: MaterialButton(
                                          elevation: 5,
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              elevation: 20.0,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      25.0))),
                                              isScrollControlled: true,
                                              builder: (context) =>
                                                  NewUsrAddLocalDB(
                                                index: 1,
                                                recovery:
                                                    ViewRecovery.initializer(),
                                              ),
                                            );
                                          },
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            // color: Color(0xff424242),
                                            size: 20,
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          SlideTransition(
                            position: Tween<Offset>(
                                    begin: Offset(1, 0), end: Offset(0, 0))
                                .animate(_animationController),
                            child: FadeTransition(
                              opacity: _animationController,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: TextField(
                                  controller: controller,
                                  onChanged: (value) {
                                    setState(() {
                                      searchString = value.toLowerCase();
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 13, horizontal: 20),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: etradeMainColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(20),
                                      borderSide:
                                          BorderSide(color: etradeMainColor),
                                    ),
                                    labelText: 'Search Product',
                                    // labelStyle: TextStyle(color: etradeMainColor),
                                    suffixIcon: Icon(
                                      Icons.search,
                                      color: etradeMainColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SlideTransition(
                            position: Tween<Offset>(
                                    begin: Offset(1, 0), end: Offset(0, 0))
                                .animate(_animationController),
                            child: FadeTransition(
                              opacity: _animationController,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          resetCartList();
                                          TakeOrderScreen.getdataFromDb();
                                        });
                                      },
                                      child: Text(
                                        "Clear List",
                                        style:
                                            TextStyle(color: etradeMainColor),
                                      )),
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            color: etradeMainColor,
                            thickness: 2,
                            height: 10,
                          ),
                          ListItems(
                            controller: _animationController,
                            productItems: DataBaseDataLoad.ListOProduct,
                            editDiscount: TakeOrderScreen.customer.discount,
                            searchedInput: searchString,
                            route: MyNavigationBar(
                              selectedIndex: 1,
                              editRecovery: ViewRecovery.initializer(),
                              date: widget.date,
                              id: widget.iD,
                              list: const [],
                              partyName: "Search Customer",
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
