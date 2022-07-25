import 'package:eTrade/components/Sql_Connection.dart';

class EditOrder {
  EditOrder(
      {required this.amount,
      required this.itemId,
      required this.itemName,
      required this.quantity,
      required this.bonus,
      required this.discount,
      required this.to,
      required this.rate});
  String itemId;
  String itemName;
  int quantity;
  double rate;
  double amount;
  int discount;
  double bonus;
  double to;
  static List<EditOrder> ViewOrderFromDb(var _orderDetail) {
    List<EditOrder> _listOrderView = [];
    if (_orderDetail.isNotEmpty) {
      _orderDetail.forEach((element) {
        EditOrder viewOrder = EditOrder(
            to: 0,
            discount: 0,
            bonus: 0,
            quantity: 0,
            amount: 0,
            itemName: "",
            rate: 0,
            itemId: "");
        viewOrder.itemName = element['ItemName'];
        viewOrder.quantity = element['Quantity'];
        viewOrder.rate = element['RATE'];
        viewOrder.amount = element['Amount'];
        viewOrder.itemId = element['ItemID'];
        viewOrder.to = element['TO'];
        viewOrder.bonus = element['Bonus'];
        viewOrder.discount = element['Discount'];
        _listOrderView.add(viewOrder);
      });
    }
    return _listOrderView;
  }
}
