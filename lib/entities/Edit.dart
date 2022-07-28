import 'package:eTrade/helper/Sql_Connection.dart';

class Edit {
  Edit(
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
  double discount;
  int bonus;
  double to;
  static List<Edit> ViewOrderFromDb(var _orderDetail) {
    List<Edit> _listOrderView = [];
    if (_orderDetail.isNotEmpty) {
      _orderDetail.forEach((element) {
        Edit viewOrder = Edit(
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
