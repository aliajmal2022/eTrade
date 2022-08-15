import 'package:eTrade/components/CustomNavigator.dart';
import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/helper/onldt_to_local_db.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Recovery.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewUsrAddLocalDB extends StatefulWidget {
  NewUsrAddLocalDB({required this.index, required this.recovery});
  int index;
  ViewRecovery recovery;
  @override
  State<NewUsrAddLocalDB> createState() => _NewUsrAddLocalDBState();
}

class _NewUsrAddLocalDBState extends State<NewUsrAddLocalDB> {
  String InpName = "";
  String address = "";
  final TextEditingController _controller = TextEditingController();
  double discount = 0;
  final TextEditingController _discountcontroller = TextEditingController();
  final TextEditingController _addresscontroller = TextEditingController();
  bool valid = true;
  bool msg = true;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      valid = true;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        // resizeToAvoidBottomInset: false,
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
                height: 500,
                width: double.infinity,
                child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(children: [
                      const Expanded(
                        flex: 1,
                        child: Text(
                          "Add New Customer.",
                          style: TextStyle(
                              fontSize: 30,
                              // color: Colors.white,
                              decoration: TextDecoration.none),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                maxLength: 70,
                                autofocus: true,
                                keyboardType: TextInputType.name,
                                controller: _controller,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isNotEmpty) {
                                      InpName = value.toUpperCase();
                                    } else {
                                      InpName = "";
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(width: 20.0)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: eTradeGreen),
                                  ),
                                  labelText: 'Enter Customer Name',
                                  labelStyle: TextStyle(color: eTradeGreen),
                                  errorText: msg
                                      ? null
                                      : "The Customer is already exist.",
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                controller: _discountcontroller,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isNotEmpty) {
                                      discount = double.parse(value);
                                    } else {
                                      discount = 0;
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide(width: 20.0)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: eTradeGreen),
                                  ),
                                  labelText: 'Enter Discount',
                                  labelStyle: TextStyle(color: eTradeGreen),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: TextField(
                                  minLines:
                                      2, // any number you need (It works as the rows for the textarea)
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  maxLength: 270,
                                  controller: _addresscontroller,
                                  onChanged: (value) {
                                    setState(() {
                                      address = value.toUpperCase();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide(width: 20.0)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: eTradeGreen),
                                    ),
                                    labelText: 'Address',
                                    labelStyle: TextStyle(color: eTradeGreen),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      MaterialButton(
                          // disabledElevation: 10.0,
                          disabledColor: Colors.grey,
                          onPressed: InpName == "" && address == ""
                              ? null
                              : () async {
                                  showDialog(
                                      context: ctx,
                                      barrierDismissible: false,
                                      builder: (BuildContext ctx) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      });
                                  Future.delayed(const Duration(seconds: 1),
                                      () async {
                                    List<Customer> customerList =
                                        await Customer.CustomerLOdb(true);
                                    for (var element in customerList) {
                                      if (element.partyName.toUpperCase() ==
                                          InpName) {
                                        setState(() {
                                          valid = false;
                                        });
                                      }
                                    }
                                    if (valid) {
                                      int id =
                                          await SQLHelper.getIDForNCustomer();
                                      Customer nCustomer = Customer(
                                          address: address,
                                          partyIdMobile: id,
                                          userId: MyNavigationBar.userID,
                                          partyId: id,
                                          partyName: InpName,
                                          discount: discount);
                                      await SQLHelper.instance
                                          .createParty(nCustomer);
                                      await DataBaseDataLoad.DataLoading();
                                      Navigator.pushAndRemoveUntil(
                                          ctx,
                                          MyCustomRoute(
                                              builder: (ctx) => MyNavigationBar(
                                                    date: "",
                                                    editRecovery:
                                                        widget.recovery,
                                                    selectedIndex: widget.index,
                                                    list: [],
                                                    partyName:
                                                        "Search Customer",
                                                    id: 0,
                                                  ),
                                              slide: "Left"),
                                          (route) => false);
                                    } else {
                                      setState(() {
                                        _controller.clear();
                                        _discountcontroller.clear();
                                        InpName = "";
                                        msg = false;
                                        valid = true;
                                      });
                                      Navigator.pop(ctx);
                                    }
                                  });
                                },
                          // elevation: 20.0,
                          color: eTradeGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0))),
                          minWidth: double.infinity,
                          height: 50,
                          child: Text(
                            "Add Customer",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ))
                    ]))),
          ),
        ));
  }
}
