import 'package:eTrade/helper/Sql_Connection.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:flutter/animation.dart';

class ViewRecovery {
  ViewRecovery(
      {required this.amount,
      required this.description,
      required this.dated,
      required this.recoveryID,
      required this.checkOrCash,
      required this.party});

  int recoveryID;
  Customer party;
  double amount;
  String dated;
  String checkOrCash;
  String description;

  static List<ViewRecovery> ViewRecoveryFromDb(List _recovery) {
    List<ViewRecovery> _listRecovery = [];
    if (_recovery.isNotEmpty) {
      _recovery.forEach((element) {
        ViewRecovery recovery = ViewRecovery(
            recoveryID: 0,
            amount: 0,
            dated: "",
            checkOrCash: "",
            description: "",
            party: Customer(
                partyId: 0,
                partyName: "",
                discount: 0,
                address: "",
                userId: 0));
        recovery.party.partyName = element['PartyName'];
        recovery.party.partyId = element['PartyID'];
        recovery.amount = element['Amount'];
        recovery.recoveryID = element['RecoveryID'];
        recovery.description = element['Description'];
        recovery.dated = element['Dated'];
        recovery.checkOrCash = element['CheckOrCash'];
        _listRecovery.add(recovery);
      });
    }
    return _listRecovery;
  }
}
