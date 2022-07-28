// ignore_for_file: prefer_const_constructors

import 'package:eTrade/components/AddItemModelSheet.dart';
import 'package:eTrade/components/SearchListProduct.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:flutter/material.dart';

class ListItems extends StatefulWidget {
  ListItems(
      {required this.route,
      required this.editDiscount,
      required this.productItems,
      required this.searchedInput});
  final List<Product> productItems;
  final String searchedInput;
  Widget route;
  double editDiscount;

  @override
  State<ListItems> createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  final ScrollController _controller = ScrollController();
  int totalprice = 0;
  List<Product> selectedItem = getCartList();
  bool match = false;

  @override
  @override
  Widget build(BuildContext context) {
    return widget.searchedInput == ""
        ? ListView.builder(
            controller: _controller,
            itemBuilder: (BuildContext, index) {
              for (var element in selectedItem) {
                if (widget.productItems[index].ID == element.ID) {
                  widget.productItems[index].Quantity = element.Quantity;
                }
              }

              return Card(
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      AddItemIntoCart(
                          widget.editDiscount,
                          widget.productItems[index].Quantity,
                          context,
                          widget.productItems[index],
                          widget.route);
                    });
                  },
                  child: ListTile(
                    leading: widget.productItems[index].Quantity == 0
                        ? null
                        : CircleAvatar(
                            backgroundColor: Color(0xff00620b),
                            // radius: 100,
                            minRadius: 10,
                            maxRadius: 30,
                            child:
                                Text("${widget.productItems[index].Quantity}"),
                            foregroundColor: Colors.white,
                          ),
                    title: Text(widget.productItems[index].Title),
                    subtitle: Text("${widget.productItems[index].Price}"),
                    trailing: Icon(Icons.add),
                  ),
                ),
              );
            },
            itemCount: widget.productItems.length,
            shrinkWrap: true,
            padding: EdgeInsets.all(5),
            scrollDirection: Axis.vertical,
          )
        : SearchListProduct(context, widget.productItems, widget.searchedInput,
            quantity, widget.route, widget.editDiscount);
  }
}
