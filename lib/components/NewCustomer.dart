import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/onldt_to_local_db.dart';
import 'package:eTrade/components/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Recovery.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/TakeOrderScreen.dart';
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
  final TextEditingController _controller = TextEditingController();
  double discount = 0;
  final TextEditingController _discountcontroller = TextEditingController();
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
          height: 400,
          width: double.infinity,
          child: Padding(
              padding: const EdgeInsets.all(40.0),
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
                  flex: 2,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: TextField(
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
                        flex: 1,
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
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                    disabledElevation: 10.0,
                    disabledColor: Color(0x0ff1e1e1),
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
                                    partyId: id,
                                    partyName: InpName,
                                    discount: discount);
                                await SQLHelper.instance.createParty(nCustomer);
                                await DataBaseDataLoad.DataLoading();

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyNavigationBar(
                                              orderDate: "",
                                              editRecovery: widget.recovery,
                                              selectedIndex: widget.index,
                                              orderList: [],
                                              orderPartyName: "Search Customer",
                                              orderId: 0,
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
                    elevation: 20.0,
                    color: Color(0xff00620b),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    minWidth: double.infinity,
                    height: 50,
                    child: Text(
                      "Add Customer",
                      style: TextStyle(
                          color: (InpName == "") ? null : Colors.white,
                          fontSize: 20),
                    ))
              ]))),
    )));
  }
}
