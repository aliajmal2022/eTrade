// ignore_for_file: non_constant_identifier_names

import 'package:etrade/helper/Sql_Connection.dart';
import 'package:etrade/helper/sqlhelper.dart';

class Product {
  Product(
      {required this.Title,
      required this.Price,
      required this.ID,
      required this.discount,
      required this.bonus,
      required this.to,
      required this.Quantity});

  String Title;
  String ID;
  double Price;
  int Quantity;
  double discount;
  int bonus;
  double to;

  static Future<List<Product>> ProductLOdb(islocaldb) async {
    List _products;
    List<Product> _listProduct = [];
    if (islocaldb) {
      _products = await SQLHelper.instance.getTable("Item", "ItemID");
    } else {
      _products = await Sql_Connection().read(
          "SELECT replace(i.ItemID,'\\','')as ItemID,replace(i.ItemName,'\\','') as ItemName,i.TradePrice FROM Item AS i");
    }
    Product product;
    if (_products.isNotEmpty) {
      _products.forEach((element) {
        product = Product(
            Title: "",
            ID: "",
            Price: 0,
            Quantity: 0,
            discount: 0,
            bonus: 0,
            to: 0);
        if (islocaldb)
          product.ID = element['ItemID'];
        else
          product.ID = element['ItemID'].toString();
        product.Title = element['ItemName'];
        product.Price = element['TradePrice'];
        _listProduct.add(product);
      });
    }
    return _listProduct;
  }
}
