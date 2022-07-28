// ignore_for_file: non_constant_identifier_names

import 'package:eTrade/components/Sql_Connection.dart';
import 'package:eTrade/components/sqlhelper.dart';
import 'package:intl/intl.dart';

class ViewOrderBooking {
  ViewOrderBooking(
      {required this.orderID,
      required this.orderDate,
      required this.partyName,
      required this.totalQuantity});

  int orderID;
  String orderDate;
  int totalQuantity;
  String partyName;

  static List<ViewOrderBooking> ViewOrderFromDb(List _order) {
    List<ViewOrderBooking> _listOrderView = [];
    if (_order.isNotEmpty) {
      _order.forEach((element) {
        ViewOrderBooking viewOrder = ViewOrderBooking(
            orderID: 0, orderDate: "", partyName: "", totalQuantity: 0);
        viewOrder.orderDate = element['Dated'];
        viewOrder.totalQuantity = element['TotalQuantity'];
        viewOrder.partyName = element['PartyName'];
        viewOrder.orderID = element['OrderID'];
        viewOrder.orderID = element['OrderID'];
        _listOrderView.add(viewOrder);
      });
    }
    return _listOrderView;
  }
}
