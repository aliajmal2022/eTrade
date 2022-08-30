import 'package:etrade/helper/Sql_Connection.dart';
import 'package:etrade/helper/sqlhelper.dart';
import 'package:etrade/entities/Customer.dart';
import 'package:etrade/entities/Products.dart';
import 'package:etrade/screen/NavigationScreen/Booking/ViewBookingScreen.dart';
import 'package:intl/intl.dart';

class SaleDetail {
  int id;
  int quantity;
  double rate;
  double amount;
  int userID;
  int invoiceID;

  double discount;
  int bonus;
  double to;
  String itemID;
  String date;
  SaleDetail(
      {required this.id,
      required this.quantity,
      required this.invoiceID,
      required this.userID,
      required this.rate,
      required this.to,
      required this.discount,
      required this.bonus,
      required this.date,
      required this.amount,
      required this.itemID});
  static Future<List<SaleDetail>> ExecutionForAdmin(
      String start, String end) async {
    var list = await Sql_Connection().read(
        "SELECT d.BillNo as InvoiceID, ISNULL(s.SRId_Mobile,0) as UserID, d.ItemID, abs(d.Quantity) AS Quantity, d.Rate,d.Amount, d.Dated, d.Discount_line as Discount, d.TradeOffer, d.Bonus FROM dbo.Sale AS s INNER JOIN Detail AS d ON d.BillNo = s.BillNo WHERE ISNULL(s.InvoiceId_Mobile,1)>0 AND ISNULL(s.IsOrder_Mobile,0)=0 AND convert(date,d.Dated) BETWEEN '$start' and '$end'");
    if (list.isNotEmpty) {
      List<SaleDetail> saleDetailList = [];
      var dateStore = DateFormat('yyyy-MM-dd');
      list.forEach((element) {
        SaleDetail saleDetail = SaleDetail(
            id: 0,
            quantity: 0,
            invoiceID: 0,
            userID: 0,
            rate: 0,
            to: 0,
            bonus: 0,
            discount: 0,
            date: "",
            amount: 0,
            itemID: "");
        saleDetail.quantity = element['Quantity'].toInt();
        saleDetail.invoiceID = element['InvoiceID'];
        saleDetail.userID = element['UserID'];
        saleDetail.itemID = element['ItemID'].toString();
        saleDetail.amount = element['Amount'];
        saleDetail.rate = element['Rate'];
        saleDetail.discount = element['Discount'];
        saleDetail.bonus = element['Bonus'].toInt();
        saleDetail.to = element['TradeOffer'];
        saleDetail.date = dateStore.format(DateTime.parse(element['Dated']));
        saleDetailList.add(saleDetail);
      });
      return saleDetailList;
    } else {
      return [];
    }
  }

  static Future<List<SaleDetail>> SaleDetailForAdmin(
      String start, String end) async {
    var list = await Sql_Connection().read("""
SELECT 
	d.InvoiceID,
	d.UserId,
	d.ItemID,
	d.Quantity,
	d.Rate,d.Amount,
	d.Dated,
	d.Discount,
	d.TradeOffer,
	d.Bonus
FROM dbo_m.SaleDetail AS d
WHERE CONVERT(DATE,d.Dated) BETWEEN '$start' AND '$end'
""") ?? [];
    if (list.isNotEmpty) {
      List<SaleDetail> saleDetailList = [];
      var dateStore = DateFormat('yyyy-MM-dd');
      list.forEach((element) {
        SaleDetail saleDetail = SaleDetail(
            id: 0,
            quantity: 0,
            invoiceID: 0,
            userID: 0,
            rate: 0,
            to: 0,
            bonus: 0,
            discount: 0,
            date: "",
            amount: 0,
            itemID: "");
        saleDetail.quantity = element['Quantity'].toInt();
        saleDetail.invoiceID = element['InvoiceID'];
        saleDetail.userID = element['UserID'];
        saleDetail.itemID = element['ItemID'].toString();
        saleDetail.amount = element['Amount'];
        saleDetail.rate = element['Rate'];
        saleDetail.discount = element['Discount'];
        saleDetail.bonus = element['Bonus'].toInt();
        saleDetail.to = element['TradeOffer'];
        saleDetail.date = dateStore.format(DateTime.parse(element['Dated']));
        saleDetailList.add(saleDetail);
      });
      return saleDetailList;
    } else {
      return [];
    }
  }
}
