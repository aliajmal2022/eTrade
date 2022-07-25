import 'package:eTrade/components/Sql_Connection.dart';
import 'package:eTrade/components/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:eTrade/screen/ViewBookingScreen.dart';

class OrderDetail {
  int id;
  int quantity;
  double rate;
  double amount;
  int userID;
  int orderID;
  String itemID;
  String date;
  OrderDetail(
      {required this.id,
      required this.quantity,
      required this.orderID,
      required this.userID,
      required this.rate,
      required this.date,
      required this.amount,
      required this.itemID});
}
