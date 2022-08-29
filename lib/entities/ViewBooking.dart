// ignore_for_file: non_constant_identifier_names

import 'package:etrade/helper/Sql_Connection.dart';
import 'package:etrade/helper/sqlhelper.dart';
import 'package:intl/intl.dart';

class ViewBooking {
  ViewBooking(
      {required this.iD,
      required this.date,
      required this.partyName,
      required this.totalQuantity});

  int iD;
  String date;
  int totalQuantity;
  String partyName;

  static List<ViewBooking> ViewSaleFromDb(List _sale) {
    List<ViewBooking> _listOrderView = [];
    if (_sale.isNotEmpty) {
      _sale.forEach((element) {
        ViewBooking viewOrder =
            ViewBooking(iD: 0, date: "", partyName: "", totalQuantity: 0);
        viewOrder.date = element['Dated'];
        viewOrder.totalQuantity = element['TotalQuantity'];
        viewOrder.partyName = element['PartyName'];
        viewOrder.iD = element['InvoiceID'];
        _listOrderView.add(viewOrder);
      });
    }
    return _listOrderView;
  }

  static List<ViewBooking> ViewOrderFromDb(List _order) {
    List<ViewBooking> _listOrderView = [];
    if (_order.isNotEmpty) {
      _order.forEach((element) {
        ViewBooking viewOrder =
            ViewBooking(iD: 0, date: "", partyName: "", totalQuantity: 0);
        viewOrder.date = element['Dated'];
        viewOrder.totalQuantity = element['TotalQuantity'];
        viewOrder.partyName = element['PartyName'];
        viewOrder.iD = element['OrderID'];
        _listOrderView.add(viewOrder);
      });
    }
    return _listOrderView;
  }
}
