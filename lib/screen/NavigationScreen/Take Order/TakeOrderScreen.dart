// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/main.dart';
import 'package:eTrade/screen/NavigationScreen/DashBoard/DashboardScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/components/AddItemModelSheet.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/components/ListProduct.dart';
import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/NewCustomer.dart';
import 'package:eTrade/helper/Sql_Connection.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/helper/onldt_to_local_db.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Edit.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/CartScreen.dart';
import 'package:eTrade/screen/LoginScreen/LoginScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/ViewBookingScreen.dart';
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
  static Customer customer = new Customer(
      userId: 0,
      address: "",
      discount: 0,
      partyId: 0,
      partyName: "Search Customer");
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

  void setParty(Customer selectedCustomer) {
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
  static Future<void> onLoading(BuildContext context, bool resetsync) async {
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
        await SQLHelper.resetData("Sync");
        await Sql_Connection.PreLoadData(true);
      } else {
        await Sql_Connection.PreLoadData(false);
      }
      resetCartList();
      await DataBaseDataLoad.DataLoading();
      TakeOrderScreen.setPartydb(DataBaseDataLoad.ListOCustomer);
      TakeOrderScreen.setProductdb(DataBaseDataLoad.ListOProduct);

      DashBoardScreen.dashBoard = await DashBoardScreen.getOrderHistory();
      Navigator.pushAndRemoveUntil(
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
                            partyId: 0,
                            userId: 0,
                            partyName: "",
                            discount: 0,
                            address: "")),
                    selectedIndex: 0,
                    date: "",
                    list: [],
                    id: 0,
                    partyName: "Search Customer",
                  )),
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
            discount: 0,
            partyId: 0,
            address: "",
            partyName: widget.partyName);
        selectedParty =
            selectedParty.selectedCustomer(DataBaseDataLoad.ListOCustomer);
        widget.setParty(selectedParty);
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
        AnimationController(vsync: this, duration: Duration(milliseconds: 900));
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
          widget.setParty(TakeOrderScreen.customer);
        });
      } else if (!TakeOrderScreen.isEditOrder || !TakeOrderScreen.isEditSale) {
        setState(() {
          widget.setParty(Customer(
              discount: 0,
              partyId: 0,
              userId: 0,
              address: "",
              partyName: "Search Customer"));
        });
      }
      TakeOrderScreen.isSync = false;
      TakeOrderScreen.isordered = false;
    }
    super.initState();
  }

  Future<List<Customer>> getData(String filter) async {
    return DataBaseDataLoad.ListOCustomer.where((element) =>
            element.partyName.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: eTradeGreen,
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
                      widget.setParty(Customer(
                          partyId: 0,
                          discount: 0,
                          userId: 0,
                          address: "",
                          partyName: "Search Customer"));
                      resetCartList();
                    });
                    await TakeOrderScreen.getdataFromDb();
                    Get.off(
                        () => MyNavigationBar(
                            selectedIndex: 2,
                            editRecovery: ViewRecovery(
                                amount: 0,
                                description: "",
                                checkOrCash: "",
                                recoveryID: 0,
                                dated: "",
                                party: Customer(
                                    partyId: 0,
                                    partyName: "",
                                    userId: 0,
                                    address: "",
                                    discount: 0)),
                            list: [],
                            date: widget.date,
                            id: widget.iD,
                            partyName: "Search Customer"),
                        transition: Transition.leftToRight);
                  },
                )
              : (TakeOrderScreen.isSaleSpot)
                  ? IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () async {
                        setState(() {
                          TakeOrderScreen.isSaleSpot = false;
                          widget.setParty(Customer(
                              partyId: 0,
                              discount: 0,
                              userId: 0,
                              address: "",
                              partyName: "Search Customer"));
                          resetCartList();
                        });
                        await TakeOrderScreen.getdataFromDb();
                        Get.off(
                            () => MyNavigationBar(
                                selectedIndex: 1,
                                editRecovery: ViewRecovery(
                                    amount: 0,
                                    description: "",
                                    recoveryID: 0,
                                    checkOrCash: "",
                                    dated: "",
                                    party: Customer(
                                        partyId: 0,
                                        partyName: "",
                                        userId: 0,
                                        address: "",
                                        discount: 0)),
                                list: [],
                                date: widget.date,
                                id: widget.iD,
                                partyName: "Search Customer"),
                            transition: Transition.leftToRight);
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
                    onPressed:
                        (widget.getParty().partyName == "Search Customer")
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
                                    duration: Duration(milliseconds: 700));
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
                                      onChanged: (Customer? value) {
                                        setState(() {
                                          widget.setParty(value!);
                                          TakeOrderScreen.customer = value;
                                        });
                                      },
                                      items: DataBaseDataLoad.ListOCustomer,
                                      dropdownBuilder: (BuildContext context,
                                          Customer? item) {
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
                                              (item!.partyName ==
                                                      "Search Customer")
                                                  ? "Type Here..."
                                                  : item.partyName,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        );
                                      },
                                      selectedItem: TakeOrderScreen.customer,
                                      dropdownItemBuilder:
                                          (BuildContext context, Customer item,
                                              bool isSelected) {
                                        return Container(
                                          height: 60,
                                          decoration: !isSelected
                                              ? null
                                              : BoxDecoration(
                                                  border: Border.all(
                                                      color: eTradeGreen),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: MyApp.isDark
                                                      ? Color(0xff424242)
                                                      : Colors.white,
                                                ),
                                          child: Center(
                                            child: ListTile(
                                                selected: isSelected,
                                                title: Text(
                                                  item.partyName,
                                                  style: TextStyle(
                                                      color: !isSelected &&
                                                              !MyApp.isDark
                                                          ? Colors.black54
                                                          : MyApp.isDark
                                                              ? Colors.white
                                                              : Colors.black),
                                                ),
                                                subtitle: Text(
                                                    item.address.toString(),
                                                    style: TextStyle(
                                                        color: !isSelected &&
                                                                !MyApp.isDark
                                                            ? Colors.grey
                                                            : MyApp.isDark
                                                                ? Colors.white
                                                                : Colors
                                                                    .black54))),
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
                                          color: eTradeGreen,
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
                                                recovery: ViewRecovery(
                                                    amount: 0,
                                                    recoveryID: 0,
                                                    checkOrCash: "",
                                                    party: Customer(
                                                        discount: 0,
                                                        address: "",
                                                        userId: 0,
                                                        partyId: 0,
                                                        partyName: ""),
                                                    dated: "",
                                                    description: ""),
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
                                          BorderSide(color: eTradeGreen),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(20),
                                      borderSide:
                                          BorderSide(color: eTradeGreen),
                                    ),
                                    labelText: 'Search Product',
                                    // labelStyle: TextStyle(color: eTradeGreen),
                                    suffixIcon: Icon(
                                      Icons.search,
                                      color: eTradeGreen,
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
                                        style: TextStyle(color: eTradeGreen),
                                      )),
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            color: eTradeGreen,
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
                              editRecovery: ViewRecovery(
                                  amount: 0,
                                  description: "",
                                  checkOrCash: "",
                                  recoveryID: 0,
                                  dated: "",
                                  party: Customer(
                                      partyId: 0,
                                      partyName: "",
                                      userId: 0,
                                      discount: 0,
                                      address: "")),
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
