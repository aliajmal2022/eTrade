import 'package:dropdown_search/dropdown_search.dart';
import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/NewCustomer.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/components/onldt_to_local_db.dart';
import 'package:eTrade/components/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Recovery.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/ViewRecoveryScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class RecoveryScreen extends StatefulWidget {
  RecoveryScreen({required this.recovery, required this.userID});
  ViewRecovery recovery;
  int userID;
  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
  Customer customer = Customer(
      partyId: 0, address: "", partyName: "Search Customer", discount: 0);
  static List<Recovery> recoveryList = [];
  static bool addRecoveryOrder = false;
  static Customer tcustomer = Customer(
      partyId: 0, address: "", partyName: "Search Customer", discount: 0);
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

class _RecoveryScreenState extends State<RecoveryScreen> {
  String nameInp = "";
  double amount = 0;
  String description = "";
  DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  bool partyListAvialable = false;
  Future<void> PreLoadDataBase() async {
    partyListAvialable = await RecoveryScreen.getdataFromDb();
    if (partyListAvialable) {
      setState(() {
        widget.getPartydb();
      });
    }
  }

  @override
  void initState() {
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

  String _groupValue = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF00620b),
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
                          discount: 0,
                          partyName: "Search Customer");
                      widget.setParty(Customer(
                          partyId: 0,
                          address: "",
                          discount: 0,
                          partyName: "Search Customer"));
                      RecoveryScreen.amountcontroller.clear();
                      RecoveryScreen.descriptioncontroller.clear();
                      amount = 0;
                      description = "";
                    });
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewRecoveryScreen()),
                        (route) => false);
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
                                              discount: 0,
                                              address: "",
                                              partyId: 0,
                                              partyName: "")),
                                      selectedIndex: 2,
                                      orderList: [],
                                      orderDate: "",
                                      orderId: 0,
                                      orderPartyName: "Search Customer",
                                    )),
                            (e) => false);

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
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    height: 90,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                "Date: ",
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              "${RecoveryScreen.isEditRecovery ? widget.recovery.dated : dateFormat.format(DateTime.now())}",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ]),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: DropdownSearch<String>(
                        searchFieldProps: const TextFieldProps(
                          autofocus: true,
                        ),

                        dropdownSearchDecoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 13, horizontal: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20))),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff00620b)),
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
                                partyId: 0,
                                address: "",
                                partyName: selectedName);
                            selectedParty = selectedParty.selectedCustomer(
                                DataBaseDataLoad.ListOCustomer);
                            widget.setParty(selectedParty);
                            RecoveryScreen.tcustomer = selectedParty;
                          });
                        },
                        selectedItem: widget.getParty().partyName,
                      )),
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
                              color: Color(0xff00620b),
                              // color: Color(0xff424242),
                            ),
                            child: MaterialButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  elevation: 20.0,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25.0))),
                                  isScrollControlled: true,
                                  builder: (context) => NewUsrAddLocalDB(
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Check Your Payment Method.",
                        style: TextStyle(fontSize: 18),
                      ),
                      RadioListTile(
                        value: "Check",
                        groupValue: _groupValue,
                        title: Text("Check"),
                        onChanged: (newValue) =>
                            setState(() => _groupValue = newValue.toString()),
                        activeColor: Color(0xff00620b),
                        selected: false,
                      ),
                      RadioListTile(
                        value: "Cash",
                        groupValue: _groupValue,
                        title: Text("Cash"),
                        onChanged: (newValue) =>
                            setState(() => _groupValue = newValue.toString()),
                        activeColor: Color(0xff00620b),
                        selected: false,
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
                        amount =
                            double.parse(RecoveryScreen.amountcontroller.text);
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(width: 30.0)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
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
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(width: 30.0)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
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
                                    content: Text("Recovery is update."),
                                  );
                                  await SQLHelper.updateRecoveryTable(
                                      widget.recovery.recoveryID,
                                      RecoveryScreen.tcustomer.partyId,
                                      amount,
                                      description);
                                  RecoveryScreen.amountcontroller.clear();
                                  RecoveryScreen.descriptioncontroller.clear();
                                  amount = 0;
                                  description = "";
                                  RecoveryScreen.isEditRecovery = false;
                                  RecoveryScreen.getData = false;
                                  widget.setParty(Customer(
                                      discount: 0,
                                      partyId: 0,
                                      address: "",
                                      partyName: "Search Customer"));
                                  RecoveryScreen.tcustomer = Customer(
                                      discount: 0,
                                      address: "",
                                      partyId: 0,
                                      partyName: "Search Customer");
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ViewRecoveryScreen()),
                                      (route) => false);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              : () {
                                  Recovery recovery = Recovery(
                                      amount: amount,
                                      recoveryID: 0,
                                      userID: widget.userID,
                                      dated: dateFormat.format(DateTime.now()),
                                      party: Customer(
                                          partyId: widget.getParty().partyId,
                                          discount: widget.getParty().discount,
                                          address: widget.getParty().address,
                                          partyName:
                                              widget.getParty().partyName),
                                      description: description,
                                      isPost: false);
                                  SQLHelper.instance
                                      .createRecoveryitem(recovery, false);
                                  final snackBar = const SnackBar(
                                    content: Text("Recovery is Saved."),
                                  );
                                  RecoveryScreen.amountcontroller.clear();
                                  RecoveryScreen.descriptioncontroller.clear();
                                  widget.setParty(Customer(
                                      partyId: 0,
                                      discount: 0,
                                      address: "",
                                      partyName: "Search Customer"));
                                  RecoveryScreen.tcustomer = Customer(
                                      discount: 0,
                                      address: "",
                                      partyId: 0,
                                      partyName: "Search Customer");
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyNavigationBar(
                                                selectedIndex: 0,
                                                editRecovery: ViewRecovery(
                                                    amount: 0,
                                                    description: "",
                                                    recoveryID: 0,
                                                    dated: "",
                                                    party: Customer(
                                                        discount: 0,
                                                        partyId: 0,
                                                        partyName: "",
                                                        address: "")),
                                                orderDate: "",
                                                orderId: 0,
                                                orderList: [],
                                                orderPartyName:
                                                    "Search Customer",
                                              )),
                                      (route) => false);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                      elevation: 20.0,
                      disabledColor: Color(0x0ff1e1e1),
                      disabledElevation: 1,
                      color: Color(0xff00620b),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0))),
                      minWidth: double.infinity,
                      height: 50,
                      child: Text(
                        RecoveryScreen.isEditRecovery ? "Update" : "Save",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )),
                ],
              )),
        ),
      ),
    );
  }
}
