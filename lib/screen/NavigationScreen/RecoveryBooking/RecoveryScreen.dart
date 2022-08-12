import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/NewCustomer.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/helper/onldt_to_local_db.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Recovery.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/main.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/ViewRecoveryScreen.dart';
import 'package:find_dropdown/find_dropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RecoveryScreen extends StatefulWidget {
  RecoveryScreen({required this.recovery, required this.userID});
  ViewRecovery recovery;
  int userID;
  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
  Customer customer = Customer(
      userId: 0,
      partyId: 0,
      address: "",
      partyName: "Search Customer",
      discount: 0);
  static List<Recovery> recoveryList = [];
  static bool addRecoveryOrder = false;
  static Customer tcustomer = Customer(
      userId: 0,
      partyId: 0,
      address: "",
      partyName: "Search Customer",
      discount: 0);
  static bool isEditRecovery = false;
  static List<Customer> partydb = [];
  static void setPartydb(List<Customer> list) {
    partydb = list;
  }

  static bool isSync = false;

  static Future<bool> getdataFromDb() async {
    bool isExist = await DataBaseDataLoad.DataLoading();
    if (isExist) {
      setPartydb(DataBaseDataLoad.ListOCustomer);

      if (partydb.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  List<Customer> getPartydb() {
    return partydb;
  }

  void setParty(Customer selectedCustomer) {
    customer.partyId = selectedCustomer.partyId;
    customer.partyName = selectedCustomer.partyName;
    customer.discount = selectedCustomer.discount;
  }

  Customer getParty() {
    return customer;
  }

  static bool getData = false;
  static final descriptioncontroller = TextEditingController();
  static final amountcontroller = TextEditingController();
}

class _RecoveryScreenState extends State<RecoveryScreen>
    with TickerProviderStateMixin {
  var _animationController;
  Future<List<Customer>> getData(String filter) async {
    return DataBaseDataLoad.ListOCustomer.where((element) =>
            element.partyName.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }

  String nameInp = "";
  double amount = 0;
  String description = "";
  DateFormat showdateFormat = DateFormat('dd-MM-yyyy');
  DateFormat storedateFormat = DateFormat('yyyy-MM-dd');
  bool partyListAvialable = false;
  Future<void> PreLoadDataBase() async {
    partyListAvialable = await RecoveryScreen.getdataFromDb();
    if (partyListAvialable) {
      setState(() {
        widget.getPartydb();
      });
    }
  }

  String _groupValue = "Cash";
  static bool isCash = true;
  // var _animationController;
  //                     SlideTransition(
  //                         position: Tween<Offset>(
  //                                 begin: Offset(1, 0), end: Offset(0, 0))
  //                             .animate(_animationController),
  //                         child: FadeTransition(
  //                           opacity: _animationController,
  //   _animationController =
  //       AnimationController(vsync: this, duration: Duration(milliseconds: 900));
  //   _animationController.forward();
  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: Duration(microseconds: 1000));
    PreLoadDataBase();
    setState(() {
      if (!RecoveryScreen.isSync) {
        if (RecoveryScreen.isEditRecovery) {
          if (!RecoveryScreen.getData) {
            RecoveryScreen.amountcontroller.text =
                widget.recovery.amount.toString();
            RecoveryScreen.descriptioncontroller.text =
                widget.recovery.description;
            amount = double.parse(RecoveryScreen.amountcontroller.text);
            description = RecoveryScreen.descriptioncontroller.text;
            isCash = widget.recovery.checkOrCash;
            widget.setParty(widget.recovery.party);
            RecoveryScreen.tcustomer = widget.recovery.party;
            RecoveryScreen.getData = true;
          } else {
            widget.setParty(RecoveryScreen.tcustomer);
            amount = double.parse(RecoveryScreen.amountcontroller.text);
            description = RecoveryScreen.descriptioncontroller.text;
          }
        } else {
          widget.setParty(RecoveryScreen.tcustomer);
          if (RecoveryScreen.amountcontroller.text.isNotEmpty &&
              RecoveryScreen.descriptioncontroller.text.isNotEmpty) {
            amount = double.parse(RecoveryScreen.amountcontroller.text);
            description = RecoveryScreen.descriptioncontroller.text;
          }
        }
      } else {
        widget.setParty(Customer(
            partyId: 0,
            userId: 0,
            address: "",
            discount: 0,
            partyName: "Search Customer"));
        RecoveryScreen.amountcontroller.clear();
        RecoveryScreen.descriptioncontroller.clear();
        RecoveryScreen.isSync = false;
      }
    });
    super.initState();
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: eTradeGreen,
          toolbarHeight: 80,
          shape: const RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          automaticallyImplyLeading: false,
          leading: (RecoveryScreen.isEditRecovery)
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () async {
                    setState(() {
                      RecoveryScreen.isEditRecovery = false;
                      RecoveryScreen.getData = false;
                      RecoveryScreen.tcustomer = Customer(
                          partyId: 0,
                          address: "",
                          userId: 0,
                          discount: 0,
                          partyName: "Search Customer");
                      widget.setParty(Customer(
                          partyId: 0,
                          userId: 0,
                          address: "",
                          discount: 0,
                          partyName: "Search Customer"));
                      RecoveryScreen.amountcontroller.clear();
                      RecoveryScreen.descriptioncontroller.clear();
                      amount = 0;
                      description = "";
                    });
                    Get.off(ViewRecoveryScreen(),
                        transition: Transition.leftToRight);
                  },
                )
              : Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(
                        Icons.menu,
                      ),
                      onPressed: () {
                        MyDrawer.isopen = true;
                        // dispose();
                        MyNavigationBar.currentIndex = 1;
                        Get.off(MyNavigationBar(
                          editRecovery: ViewRecovery(
                              amount: 0,
                              description: "",
                              checkOrCash: false,
                              recoveryID: 0,
                              dated: "",
                              party: Customer(
                                  discount: 0,
                                  userId: 0,
                                  address: "",
                                  partyId: 0,
                                  partyName: "")),
                          selectedIndex: 2,
                          list: [],
                          date: "",
                          id: 0,
                          partyName: "Search Customer",
                        ));

                        Scaffold.of(context).openDrawer();
                      },
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
                    );
                  },
                ),
          title: const Text(
            'Recovery',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        drawer: MyDrawer(),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SlideTransition(
                      position:
                          Tween<Offset>(begin: Offset(0, 0), end: Offset(0, 1))
                              .animate(_animationController),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            // width: double.infinity,
                            // height: 50,
                            padding: EdgeInsets.all(12.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Date: ",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    "${RecoveryScreen.isEditRecovery ? widget.recovery.dated : showdateFormat.format(DateTime.now())}",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ]),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Cash",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: !isCash
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                                Switch(
                                  value: isCash,
                                  activeColor: eTradeGreen,
                                  onChanged: (value) async {
                                    setState(() {
                                      isCash = value;
                                      _groupValue = !isCash ? "Cash" : "Check";
                                    });
                                  },
                                ),
                                Text(
                                  "Check",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: isCash
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: FindDropdown<Customer>(
                                  autofocus: true,
                                  onFind: (String filter) => getData(filter),
                                  onChanged: (Customer? value) {
                                    setState(() {
                                      widget.setParty(value!);
                                      RecoveryScreen.tcustomer = value;
                                    });
                                  },
                                  items: DataBaseDataLoad.ListOCustomer,
                                  dropdownBuilder:
                                      (BuildContext context, Customer? item) {
                                    return Container(
                                      height: 49,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .disabledColor),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(
                                                  20.0), // Set rounded corner radius
                                              bottomLeft:
                                                  Radius.circular(20.0)), //
                                          color: MyApp.isDark
                                              ? Color(0xff303030)
                                              : Color(0xfffafafa)),
                                      child: (item?.partyName == null)
                                          ? ListTile(
                                              leading: Text("Search Customer"))
                                          : ListTile(
                                              leading: Text(item!.partyName),
                                            ),
                                    );
                                  },
                                  selectedItem: widget.customer,
                                  dropdownItemBuilder: (BuildContext context,
                                      Customer item, bool isSelected) {
                                    return Container(
                                      decoration: !isSelected
                                          ? null
                                          : BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blue),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: MyApp.isDark
                                                  ? Color(0xff424242)
                                                  : Colors.white,
                                            ),
                                      child: ListTile(
                                          selected: isSelected,
                                          title: Text(
                                            item.partyName,
                                            style: TextStyle(
                                                color:
                                                    !isSelected && !MyApp.isDark
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
                                                          : Colors.black54))),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Material(
                                child: Container(
                                    height: 48,
                                    width: 58,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                      // color: Colors.white,
                                      color: eTradeGreen,
                                      // color: Color(0xff424242),
                                    ),
                                    child: MaterialButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          elevation: 20.0,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(
                                                          25.0))),
                                          isScrollControlled: true,
                                          builder: (context) =>
                                              NewUsrAddLocalDB(
                                            index: 2,
                                            recovery: widget.recovery,
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
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: RecoveryScreen.amountcontroller,
                            onChanged: (value) {
                              setState(() {
                                amount = double.parse(
                                    RecoveryScreen.amountcontroller.text);
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  borderSide: BorderSide(width: 30.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  borderSide: BorderSide(color: eTradeGreen)),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 13, horizontal: 20),
                              labelText: 'Enter Amount',
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            minLines: 3,
                            maxLines: 4,
                            maxLength: 270,
                            keyboardType: TextInputType.text,
                            controller: RecoveryScreen.descriptioncontroller,
                            onChanged: (value) {
                              setState(() {
                                description = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  borderSide: BorderSide(width: 30.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  borderSide: BorderSide(color: eTradeGreen)),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 13, horizontal: 20),
                              labelText: 'Description',
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          MaterialButton(
                              onPressed: (widget.getParty().partyName ==
                                          "Search Customer" ||
                                      amount == 0 ||
                                      description == "")
                                  ? null
                                  : RecoveryScreen.isEditRecovery
                                      ? () async {
                                          final snackBar = const SnackBar(
                                            content:
                                                Text("Recovery is update."),
                                          );
                                          await SQLHelper.updateRecoveryTable(
                                              widget.recovery.recoveryID,
                                              RecoveryScreen.tcustomer.partyId,
                                              amount,
                                              description,
                                              _groupValue);
                                          setState(() {
                                            RecoveryScreen.amountcontroller
                                                .clear();
                                            RecoveryScreen.descriptioncontroller
                                                .clear();
                                            amount = 0;
                                            description = "";
                                            RecoveryScreen.isEditRecovery =
                                                false;
                                            RecoveryScreen.getData = false;
                                            widget.setParty(Customer(
                                                discount: 0,
                                                userId: 0,
                                                partyId: 0,
                                                address: "",
                                                partyName: "Search Customer"));
                                            RecoveryScreen.tcustomer = Customer(
                                                discount: 0,
                                                userId: 0,
                                                address: "",
                                                partyId: 0,
                                                partyName: "Search Customer");
                                          });
                                          Get.off(ViewRecoveryScreen());
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        }
                                      : () async {
                                          var snackBar = const SnackBar(
                                            content: Text("Recovery is Saved."),
                                          );
                                          Recovery recovery = Recovery(
                                              amount: amount,
                                              recoveryID: 0,
                                              isCashOrCheck: isCash,
                                              userID: widget.userID,
                                              dated: storedateFormat
                                                  .format(DateTime.now()),
                                              party: Customer(
                                                  partyId:
                                                      widget.getParty().partyId,
                                                  userId:
                                                      widget.getParty().userId,
                                                  discount: widget
                                                      .getParty()
                                                      .discount,
                                                  address:
                                                      widget.getParty().address,
                                                  partyName: widget
                                                      .getParty()
                                                      .partyName),
                                              description: description,
                                              isPost: false);
                                          await SQLHelper.instance
                                              .createRecoveryitem(
                                                  recovery, false);
                                          setState(() {
                                            RecoveryScreen.amountcontroller
                                                .clear();
                                            RecoveryScreen.descriptioncontroller
                                                .clear();
                                            widget.setParty(Customer(
                                                partyId: 0,
                                                userId: 0,
                                                discount: 0,
                                                address: "",
                                                partyName: "Search Customer"));
                                            RecoveryScreen.tcustomer = Customer(
                                                discount: 0,
                                                userId: 0,
                                                address: "",
                                                partyId: 0,
                                                partyName: "Search Customer");
                                          });
                                          Get.off(MyNavigationBar(
                                            selectedIndex: 0,
                                            editRecovery: ViewRecovery(
                                                amount: 0,
                                                description: "",
                                                checkOrCash: false,
                                                recoveryID: 0,
                                                dated: "",
                                                party: Customer(
                                                    discount: 0,
                                                    partyId: 0,
                                                    userId: 0,
                                                    partyName: "",
                                                    address: "")),
                                            date: "",
                                            id: 0,
                                            list: [],
                                            partyName: "Search Customer",
                                          ));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        },
                              elevation: 20.0,
                              disabledColor: Color(0x0ff1e1e1),
                              disabledElevation: 1,
                              color: eTradeGreen,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0))),
                              minWidth: double.infinity,
                              height: 50,
                              child: Text(
                                RecoveryScreen.isEditRecovery
                                    ? "Update"
                                    : "Save",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              )),
                        ],
                      )))),
        ),
      ),
    );
  }
}
