// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:eTrade/components/AddItemModelSheet.dart';
import 'package:eTrade/components/ListProduct.dart';
import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/NewCustomer.dart';
import 'package:eTrade/components/Sql_Connection.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/components/onldt_to_local_db.dart';
import 'package:eTrade/components/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Edit.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/CartScreen.dart';
import 'package:eTrade/screen/LoginScreen.dart';
import 'package:eTrade/screen/ViewBookingScreen.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";

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
      address: "", discount: 0, partyId: 0, partyName: "Search Customer");
  static List<Customer> partydb = [];
  static List<Product> productdb = [];
  static bool databaseExit = false;
  static bool isonloading = false;
  static int orderId = 0;
  static String orderDATE = "";
  static int saleId = 0;
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
    if (resetsync) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
    }
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

class _TakeOrderScreenState extends State<TakeOrderScreen> {
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
            discount: 0, partyId: 0, address: "", partyName: widget.partyName);
        selectedParty =
            selectedParty.selectedCustomer(DataBaseDataLoad.ListOCustomer);
        widget.setParty(selectedParty);
        if (TakeOrderScreen.isEditOrder) {
          TakeOrderScreen.orderId = widget.iD;
          TakeOrderScreen.orderDATE = widget.date;
        } else {
          TakeOrderScreen.saleId = widget.iD;
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF00620b),
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
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyNavigationBar(
                                selectedIndex: 2,
                                editRecovery: ViewRecovery(
                                    amount: 0,
                                    description: "",
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
                                partyName: "Search Customer")),
                        (route) => false);
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
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyNavigationBar(
                                    selectedIndex: 1,
                                    editRecovery: ViewRecovery(
                                        amount: 0,
                                        description: "",
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
                                    partyName: "Search Customer")),
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
                    onPressed:
                        (widget.getParty().partyName == "Search Customer")
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CartScreen(
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
                                                    ? TakeOrderScreen.saleId
                                                    : widget.iD,
                                          )),
                                );
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
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Flexible(
                                child: DropdownSearch<String>(
                              searchFieldProps: const TextFieldProps(
                                  autofocus: true,
                                  cursorColor: Color(0xff00620b),
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xff00620b)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      // borderRadius: BorderRadius.circular(20),
                                      borderSide:
                                          BorderSide(color: Color(0xff00620b)),
                                    ),
                                  )),

                              dropdownSearchDecoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 13, horizontal: 20),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xff00620b)),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xff00620b)),
                                ),
                              ),

                              mode: Mode.MENU,
                              showSearchBox: true,
                              showSelectedItems: true,

                              //list of dropdown items
                              items: DataBaseDataLoad.PartiesName ??
                                  ["  Not found data from database"],
                              onChanged: (value) {
                                setState(() {
                                  var selectedName = value as String;
                                  var selectedParty = Customer(
                                      discount: 0,
                                      address: "",
                                                                  userId: 0,
                                      partyId: 0,
                                      partyName: selectedName);
                                  selectedParty =
                                      selectedParty.selectedCustomer(
                                          DataBaseDataLoad.ListOCustomer);
                                  widget.setParty(selectedParty);
                                });
                              },
                              selectedItem: TakeOrderScreen.customer.partyName,
                            )),
                            const SizedBox(
                              width: 5,
                            ),
                            Material(
                              elevation: 4,
                              child: Container(
                                  height: 48,
                                  width: 58,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2)),
                                    // color: Colors.white,
                                    color: Color(0xff00620b),
                                    // color: Color(0xff424242),
                                  ),
                                  child: MaterialButton(
                                    elevation: 5,
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        elevation: 20.0,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(25.0))),
                                        isScrollControlled: true,
                                        builder: (context) => NewUsrAddLocalDB(
                                          index: 1,
                                          recovery: ViewRecovery(
                                              amount: 0,
                                              recoveryID: 0,
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
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
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
                                      BorderSide(color: Color(0xff00620b)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  // borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      BorderSide(color: Color(0xff00620b)),
                                ),
                                labelText: 'Search Product',
                                // labelStyle: TextStyle(color: Color(0xff00620b)),
                                suffixIcon: Icon(
                                  Icons.search,
                                  color: Color(0xff00620b),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          ListItems(
                            productItems: DataBaseDataLoad.ListOProduct,
                            editDiscount: TakeOrderScreen.customer.discount,
                            searchedInput: searchString,
                            route: MyNavigationBar(
                              selectedIndex: 1,
                              editRecovery: ViewRecovery(
                                  amount: 0,
                                  description: "",
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
