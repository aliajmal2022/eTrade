import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/helper/onldt_to_local_db.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Recovery.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  void initState() {
    setState(() {
      valid = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(

            // resizeToAvoidBottomInset: false,
            body: Center(
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
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(width: 20.0)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xff00620b)),
                            ),
                            labelText: 'Enter Customer Name',
                            labelStyle: TextStyle(color: Color(0xff00620b)),
                            errorText:
                                msg ? null : "The Customer is already exist.",
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          autofocus: true,
                          keyboardType: TextInputType.number,
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
                                  const BorderSide(color: Color(0xff00620b)),
                            ),
                            labelText: 'Enter Discount',
                            labelStyle: TextStyle(color: Color(0xff00620b)),
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
                                address = value.toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(width: 20.0)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Color(0xff00620b)),
                              ),
                              labelText: 'Address',
                              labelStyle: TextStyle(color: Color(0xff00620b)),
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
                    onPressed: InpName == ""
                        ? null
                        : () async {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
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
                                int id = await SQLHelper.getIDForNCustomer();
                                Customer nCustomer = Customer(
                                    address: address,
                                    userId: MyNavigationBar.userID,
                                    partyId: id,
                                    partyName: InpName,
                                    discount: discount);
                                await SQLHelper.instance.createParty(nCustomer);
                                await DataBaseDataLoad.DataLoading();

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyNavigationBar(
                                              date: "",
                                              editRecovery: widget.recovery,
                                              selectedIndex: widget.index,
                                              list: [],
                                              partyName: "Search Customer",
                                              id: 0,
                                            )),
                                    (route) => false);
                              } else {
                                setState(() {
                                  _controller.clear();
                                  _discountcontroller.clear();
                                  InpName = "";
                                  msg = false;
                                  valid = true;
                                });
                                Navigator.pop(context);
                              }
                            });
                          },
                    // elevation: 20.0,
                    color: Color(0xff00620b),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    minWidth: double.infinity,
                    height: 50,
                    child: Text(
                      "Add Customer",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ))
              ]))),
    )));
  }
}
