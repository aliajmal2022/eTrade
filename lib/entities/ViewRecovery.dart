import 'package:eTrade/components/Sql_Connection.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:flutter/animation.dart';

class ViewRecovery {
  ViewRecovery(
      {required this.amount,
      required this.description,
      required this.dated,
      required this.recoveryID,
      required this.party});

  int recoveryID;
  Customer party;
  double amount;
  String dated;
  String description;

  static List<ViewRecovery> ViewRecoveryFromDb(List _order) {
    List<ViewRecovery> _listRecoveryOrder = [];
    if (_order.isNotEmpty) {
      _order.forEach((element) {
        ViewRecovery recoveryOrder = ViewRecovery(
            recoveryID: 0,
            amount: 0,
            dated: "",
            description: "",
            party: Customer(
                partyId: 0,
                partyName: "",
                discount: 0,
                address: "",
                userId: 0));
        recoveryOrder.party.partyName = element['PartyName'];
        recoveryOrder.party.partyId = element['PartyID'];
        recoveryOrder.amount = element['Amount'];
        recoveryOrder.recoveryID = element['RecoveryID'];
        recoveryOrder.description = element['Description'];
        recoveryOrder.dated = element['Dated'];
        _listRecoveryOrder.add(recoveryOrder);
      });
    }
    return _listRecoveryOrder;
  }
}
