import 'package:eTrade/components/Sql_Connection.dart';
import 'package:eTrade/components/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:eTrade/screen/ViewBookingScreen.dart';

class Order {
  Customer customer;
  int totalQuantity;
  double totalValue;
  String description;
  int userID;
  int orderID;
  String date;
  Order(
      {required this.customer,
      required this.totalQuantity,
      required this.orderID,
      required this.userID,
      required this.totalValue,
      required this.date,
      required this.description});
}
