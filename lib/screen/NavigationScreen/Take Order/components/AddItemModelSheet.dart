import 'dart:async';
import 'package:eTrade/components/CustomNavigator.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<dynamic> AddItemIntoCart(
  double discount,
  int quantity,
  BuildContext context,
  Product product,
  Widget route,
) {
  return showModalBottomSheet(
    context: context,
    elevation: 20.0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
    isScrollControlled: true,
    builder: (context) => AddItemModelSheet(
      discount: discount,
      selectedItem: product,
      screen: route,
      quantity: quantity,
    ),
  );
}

class AddItemModelSheet extends StatefulWidget {
  AddItemModelSheet(
      {required this.quantity,
      required this.selectedItem,
      required this.discount,
      required this.screen});
  final Product selectedItem;
  final double discount;
  final Widget screen;
  int quantity;

  @override
  State<AddItemModelSheet> createState() => _AddItemModelSheetState();
}

List<Product> CartList = [];
int getQuantity() {
  return quantity;
}

List<Product> getCartList() {
  return CartList;
}

var quantity = 0;
void resetCartList() {
  try {
    CartList.clear();
  } catch (e) {
    print("Something wrong during resest cartlist");
  }
}

void setCartList(Product tempCartlist) {
  bool match = false;
  if (CartList.isNotEmpty) {
    for (var element in CartList) {
      if (tempCartlist.ID == element.ID) {
        element.Quantity = tempCartlist.Quantity;
        element.bonus = tempCartlist.bonus;
        element.Price = tempCartlist.Price;
        element.to = tempCartlist.to;
        print("Quantity is updated");
        match = true;
      }
    }
    if (!match) {
      CartList.add(tempCartlist);
    }
  } else {
    CartList.add(tempCartlist);
  }
}

class _AddItemModelSheetState extends State<AddItemModelSheet> {
  double discount = 0;
  double discountRate = 0;
  final TextEditingController _discountcontroller = TextEditingController();
  final TextEditingController _quantitycontroller = TextEditingController();
  double rate = 0;
  final TextEditingController _ratecontroller = TextEditingController();
  int bonus = 0;
  final TextEditingController _bonuscontroller = TextEditingController();
  double tO = 0;
  final TextEditingController _tocontroller = TextEditingController();
  checkQuantity() {
    bool match = false;
    if (CartList.isNotEmpty) {
      for (var element in CartList) {
        if (widget.selectedItem.ID == element.ID) {
          if (widget.selectedItem.Quantity != 0) {
            setState(() {
              setQuantity(element.Quantity);
              match = true;
            });
          }
        }
      }
    }
    if (!match) {
      setState(() {
        setQuantity(0);
      });
    }
  }

  @override
  void initState() {
    checkQuantity();
    setState(() {
      _ratecontroller.text = ((widget.selectedItem.Price).toInt()).toString();
      rate = widget.selectedItem.Price;
      if (getQuantity() != 0)
        _quantitycontroller.text = getQuantity().toString();
      _discountcontroller.text = ((widget.discount).toInt()).toString();
      discount = widget.discount;
      _bonuscontroller.text = ((widget.selectedItem.bonus).toInt()).toString();
      bonus = widget.selectedItem.bonus;
      _tocontroller.text = ((widget.selectedItem.to).toInt()).toString();
      tO = widget.selectedItem.to;
    });
    super.initState();
  }

  void setQuantity(tempquantity) {
    setState(() {
      quantity = tempquantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Center(
        child: SingleChildScrollView(
          child: SizedBox(
              height: 400,
              width: double.infinity,
              child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        widget.selectedItem.Title,
                        style: TextStyle(
                            fontSize: 25,
                            // color: Colors.white,
                            decoration: TextDecoration.none),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              controller: _quantitycontroller,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                setState(() {
                                  if (value.isNotEmpty) {
                                    setQuantity(int.parse(value));
                                  } else {
                                    setQuantity(0);
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
                                labelStyle: TextStyle(color: eTradeGreen),
                                labelText: 'Quantity',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            controller: _ratecontroller,
                            onChanged: (value) {
                              setState(() {
                                if (value.isNotEmpty) {
                                  rate = double.parse(value);
                                } else {
                                  rate = 0;
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
                              labelText: 'Rate',
                              labelStyle: TextStyle(color: eTradeGreen),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            controller: _discountcontroller,
                            onChanged: (value) {
                              setState(() {
                                discount = double.parse(value);
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(width: 20.0)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: eTradeGreen),
                              ),
                              labelText: 'Discount',
                              labelStyle: TextStyle(color: eTradeGreen),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            autofocus: true,
                            enabled: (tO != 0) ? false : true,
                            keyboardType: TextInputType.number,
                            controller: _bonuscontroller,
                            onChanged: (value) {
                              setState(() {
                                if (value.isNotEmpty) {
                                  bonus = int.parse(value);
                                } else {
                                  bonus = 0;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(width: 20.0)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: eTradeGreen),
                              ),
                              labelText: 'Bonus',
                              labelStyle: TextStyle(
                                  color: (tO != 0) ? Colors.grey : eTradeGreen),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            autofocus: true,
                            enabled: (bonus != 0) ? false : true,
                            keyboardType: TextInputType.number,
                            controller: _tocontroller,
                            onChanged: (value) {
                              setState(() {
                                if (value.isNotEmpty) {
                                  tO = double.parse(value);
                                } else {
                                  tO = 0;
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
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelText: 'T.o.',
                              labelStyle: TextStyle(
                                  color:
                                      (bonus != 0) ? Colors.grey : eTradeGreen),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                        // disabledElevation: 10.0,
                        disabledColor: Colors.grey,
                        onPressed: getQuantity() == 0
                            ? null
                            : () {
                                // double totalRate = 0;
                                // totalRate = quantity * rate;
                                setState(() {
                                  Product selectedItem = Product(
                                      to: tO,
                                      bonus: bonus,
                                      discount: discount,
                                      Price: rate,
                                      Title: widget.selectedItem.Title,
                                      ID: widget.selectedItem.ID,
                                      Quantity: getQuantity());

                                  setCartList(selectedItem);
                                });

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MyCustomRoute(
                                        slide: "Left",
                                        builder: (context) => widget.screen),
                                    (route) => false);
                              },
                        elevation: 20.0,
                        color: eTradeGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0))),
                        minWidth: double.infinity,
                        height: 50,
                        child: Text(
                          "Add Item",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ))
                  ]))),
        ),
      ),
    );
  }
}
