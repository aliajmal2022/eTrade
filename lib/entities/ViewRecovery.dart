import 'package:etrade/helper/Sql_Connection.dart';
import 'package:etrade/entities/Customer.dart';
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
  bool checkOrCash;
  String description;
  static ViewRecovery initializer() {
    return ViewRecovery(
        recoveryID: 0,
        amount: 0,
        dated: "",
        checkOrCash: false,
        description: "",
        party: Customer.initializer());
  }

  static List<ViewRecovery> ViewRecoveryFromDb(List _recovery) {
    List<ViewRecovery> _listRecovery = [];
    if (_recovery.isNotEmpty) {
      _recovery.forEach((element) {
        int isCash = 0;
        ViewRecovery recovery = initializer();
        recovery.party.partyName = element['PartyName'];
        recovery.party.partyId = element['PartyID'];
        recovery.amount = element['Amount'];
        recovery.recoveryID = int.parse(element['RecoveryID']);
        recovery.description = element['Description'];
        recovery.dated = element['Dated'];
        isCash = element['isCash'];
        if (isCash == 1) {
          recovery.checkOrCash = true;
        } else {
          recovery.checkOrCash = false;
        }
        _listRecovery.add(recovery);
      });
    }
    return _listRecovery;
  }
}
