import 'package:etrade/entities/Order.dart';
import 'package:etrade/helper/Sql_Connection.dart';
import 'package:etrade/helper/sqlhelper.dart';
import 'package:etrade/entities/Customer.dart';
import 'package:etrade/entities/Products.dart';
import 'package:etrade/screen/NavigationScreen/Booking/ViewBookingScreen.dart';
import 'package:intl/intl.dart';

class OrderDetail {
  int id;
  int quantity;
  double rate;
  double amount;
  int userID;
  int orderID;
  double discount;
  int bonus;
  double to;
  String itemID;
  String date;
  OrderDetail(
      {required this.id,
      required this.quantity,
      required this.orderID,
      required this.userID,
      required this.rate,
      required this.to,
      required this.bonus,
      required this.discount,
      required this.date,
      required this.amount,
      required this.itemID});
  static Future<List<OrderDetail>> ExecutionForAdmin(
      String start, String end) async {
    var list = await Sql_Connection().read(
            "SELECT d.BillNo as OrderID, s.SRId_Mobile as UserID, d.ItemID, abs(d.Quantity) AS Quantity, d.Rate,d.Amount, d.Dated, d.Discount_line as Discount, d.TradeOffer, d.Bonus FROM dbo.Sale AS s INNER JOIN Detail AS d ON d.BillNo = s.BillNo WHERE ISNULL(s.InvoiceId_Mobile,0)>0 AND ISNULL(s.IsOrder_Mobile,0)=1 AND convert(date,d.Dated) BETWEEN '$start' and '$end'") ??
        [];
    if (list.isNotEmpty) {
      List<OrderDetail> orderDetailList = [];
      var dateStore = DateFormat('yyyy-MM-dd');
      list.forEach((element) {
        OrderDetail orderDetail = OrderDetail(
            id: 0,
            quantity: 0,
            orderID: 0,
            userID: 0,
            rate: 0,
            to: 0,
            bonus: 0,
            discount: 0,
            date: "",
            amount: 0,
            itemID: "");
        orderDetail.quantity = element['Quantity'].toInt();
        orderDetail.orderID = element['OrderID'];
        orderDetail.userID = element['UserID'];
        orderDetail.itemID = element['ItemID'].toString();
        orderDetail.amount = element['Amount'];
        orderDetail.rate = element['Rate'];
        orderDetail.discount = element['Discount'];
        orderDetail.bonus = element['Bonus'].toInt();
        orderDetail.to = element['TradeOffer'];
        orderDetail.date = dateStore.format(DateTime.parse(element['Dated']));
        orderDetailList.add(orderDetail);
        // orderDetail.isCash = element['IsCashInvoice'] == 0 ? false : true;
      });
      return orderDetailList;
    } else {
      return [];
    }
  }

  static Future<List<OrderDetail>> OrderDetailForAdmin(
      String start, String end) async {
    var list = await Sql_Connection().read("""     SELECT 
	d.OrderID,
	d.UserId,
	d.ItemID,
	d.Quantity,
	d.Rate,d.Amount,
	d.Dated,
	d.Discount,
	d.TradeOffer,
	d.Bonus
FROM dbo_m.OrderDetail AS d
WHERE CONVERT(DATE,d.Dated) BETWEEN '$start' AND '$end'""") ?? [];
    if (list.isNotEmpty) {
      List<OrderDetail> orderDetailList = [];
      var dateStore = DateFormat('yyyy-MM-dd');
      list.forEach((element) {
        OrderDetail orderDetail = OrderDetail(
            id: 0,
            quantity: 0,
            orderID: 0,
            userID: 0,
            rate: 0,
            to: 0,
            bonus: 0,
            discount: 0,
            date: "",
            amount: 0,
            itemID: "");
        orderDetail.quantity = element['Quantity'].toInt();
        orderDetail.orderID = element['OrderID'];
        orderDetail.userID = element['UserId'] ?? 0;
        orderDetail.itemID = element['ItemID'].toString();
        orderDetail.amount = element['Amount'];
        orderDetail.rate = element['Rate'];
        orderDetail.discount = element['Discount'] ?? 0;
        orderDetail.bonus =
            element['Bonus'] == null ? 0 : element['Bonus'].toInt();
        orderDetail.to = element['TradeOffer'] ?? 0;
        orderDetail.date = dateStore.format(DateTime.parse(element['Dated']));
        orderDetailList.add(orderDetail);
        // orderDetail.isCash = element['IsCashInvoice'] == 0 ? false : true;
      });
      return orderDetailList;
    } else {
      return [];
    }
  }
}
