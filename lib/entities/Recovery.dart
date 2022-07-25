import 'package:eTrade/components/Sql_Connection.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:flutter/animation.dart';

class Recovery {
  Recovery(
      {required this.amount,
      required this.description,
      required this.isPost,
      required this.dated,
      required this.userID,
      required this.recoveryID,
      required this.party});
  String dated;
  Customer party;
  int userID;
  double amount;
  int recoveryID;
  String description;
  bool isPost;

  static List<Recovery> ViewOrderFromDb(List _order) {
    List<Recovery> _listRecoveryOrder = [];
    if (_order.isNotEmpty) {
      _order.forEach((element) {
        Recovery recoveryOrder = Recovery(
            amount: 0,
            recoveryID: 0,
            userID: 0,
            dated: "",
            description: "",
            isPost: false,
            party: Customer(partyName: "", partyId: 0, discount: 0));
        recoveryOrder.party.partyId = element['PartyID'];
        recoveryOrder.party.partyName = element['PartyName'];
        recoveryOrder.amount = element['TotalValue'];
        recoveryOrder.description = element['Description'];
        recoveryOrder.isPost = false;
        _listRecoveryOrder.add(recoveryOrder);
      });
    }
    return _listRecoveryOrder;
  }
}
