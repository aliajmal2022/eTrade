import 'package:eTrade/entities/Customer.dart';

class Sale {
  Customer customer;
  int totalQuantity;
  double totalValue;
  String description;
  bool isCash;
  int userID;
  int orderID;
  String date;
  Sale(
      {required this.customer,
      required this.isCash,
      required this.totalQuantity,
      required this.orderID,
      required this.userID,
      required this.totalValue,
      required this.date,
      required this.description});
}
