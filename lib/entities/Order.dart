import 'package:eTrade/entities/Customer.dart';

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
