import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/helper/Sql_Connection.dart';
import 'package:intl/intl.dart';

class Sale {
  Customer customer;
  int totalQuantity;
  double totalValue;
  String description;
  bool isCash;
  int userID;
  int saleID;

  String date;
  Sale(
      {required this.customer,
      required this.isCash,
      required this.totalQuantity,
      required this.saleID,
      required this.userID,
      required this.totalValue,
      required this.date,
      required this.description});
  static Future<List<Sale>> SaleForAdmin(bool islocal) async {
    var list = await Sql_Connection().read(
        "SELECT o.BillNo as InvoiceID,o.SRId_Mobile as UserID,[PartyID] as PartyID,	TotalQuantity, o.NetAmount,o.Remarks, o.Dated,CASE WHEN o.PayMode=2 THEN 1 ELSE 0 END AS IsCashInvoice  FROM dbo.[Sale] AS o WHERE ISNULL(o.InvoiceId_Mobile,0)>0 AND ISNULL(o.IsOrder_Mobile,0)=0");
    // "SELECT s.BillNo as InvoiceID,s.SRId_Mobile as UserID,[PartyID],TotalQuantity,s.NetAmount,s.Remarks,s.Dated,CASE WHEN s.PayMode=1 THEN 1 ELSE 0 END AS IsCashInvoice FROM dbo.[Sale] AS s WHERE ISNULL(s.InvoiceId_Mobile,0)>0 AND ISNULL(s.IsOrder_Mobile,0)=0");
    if (list.isNotEmpty) {
      List<Sale> saleList = [];
      var dateStore = DateFormat('yyyy-MM-dd');
      list.forEach((element) {
        Sale sale = Sale(
            customer: Customer.initializer(),
            totalQuantity: 0,
            saleID: 0,
            userID: 0,
            totalValue: 0,
            date: "",
            isCash: false,
            description: "");
        sale.customer.partyId = element['PartyID'];
        sale.totalQuantity = element['TotalQuantity'].toInt();
        sale.saleID = element['InvoiceID'];
        sale.userID = element['UserID'];
        sale.totalValue = element['NetAmount'];
        sale.description = element['Remarks'];
        sale.isCash = element['IsCashInvoice'] == 0 ? false : true;
        sale.date = dateStore.format(DateTime.parse(element['Dated']));
        saleList.add(sale);
      });
      return saleList;
    } else {
      return [];
    }
  }
}
