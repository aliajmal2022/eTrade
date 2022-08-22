import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/helper/Sql_Connection.dart';
import 'package:intl/intl.dart';
import 'package:sql_conn/sql_conn.dart';

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
  static Future<List<Order>> OrderForAdmin(bool islocal) async {
    var list = await Sql_Connection().read(
        "SELECT o.BillNo as OrderID,o.SRId_Mobile as UserID,[PartyID] as PartyID,	TotalQuantity, o.NetAmount,o.Remarks, o.Dated FROM dbo.[Sale] AS o WHERE ISNULL(o.InvoiceId_Mobile,0)>0 AND ISNULL(o.IsOrder_Mobile,0)=1");
    if (list.isNotEmpty) {
      List<Order> orderList = [];
      var dateStore = DateFormat('yyyy-MM-dd');
      list.forEach((element) {
        Order order = Order(
            customer: Customer.initializer(),
            totalQuantity: 0,
            orderID: 0,
            userID: 0,
            totalValue: 0,
            date: "",
            description: "");
        order.customer.partyId = element['PartyID'];
        order.totalQuantity = element['TotalQuantity'].toInt();
        order.orderID = element['OrderID'];
        order.userID = element['UserID'];
        order.totalValue = element['NetAmount'];
        order.description = element['Remarks'];

        order.date = dateStore.format(DateTime.parse(element['Dated']));
        orderList.add(order);
      });
      return orderList;
    } else {
      return [];
    }
  }
}
