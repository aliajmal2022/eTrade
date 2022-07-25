import 'package:eTrade/components/AddItemModelSheet.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:flutter/material.dart';

SearchListProduct(BuildContext context, List<Product> product, String matchItem,
    int quantity, Widget route) {
  ScrollController _controller = ScrollController();
  List<Product> dummyProductList = [];
  dummyProductList.clear();
  for (var element in product) {
    if (element.Title.toLowerCase().contains(matchItem)) {
      dummyProductList.add(element);
      print(dummyProductList);
    }
  }
  return dummyProductList.isNotEmpty
      ? ListView.builder(
          controller: _controller,
          itemBuilder: (BuildContext, index) {
            return Card(
              child: MaterialButton(
                onPressed: () {
                  AddItemIntoCart(
                      quantity, context, dummyProductList[index], route);
                },
                child: ListTile(
                  leading: dummyProductList[index].Quantity == 0
                      ? null
                      : CircleAvatar(
                          backgroundColor: Colors.blue,
                          // radius: 100,
                          minRadius: 10,
                          maxRadius: 30,
                          child: Text(
                            "${dummyProductList[index].Quantity}",
                          ),
                          foregroundColor: Colors.white,
                        ),
                  title: Text(dummyProductList[index].Title),
                  subtitle: Text("${dummyProductList[index].Price}"),
                  trailing: const Icon(Icons.add),
                ),
              ),
            );
          },
          itemCount: dummyProductList.length,
          shrinkWrap: true,
          padding: const EdgeInsets.all(5),
          scrollDirection: Axis.vertical,
        )
      : const Center(
          child: Text("Not Found"),
        );
}
