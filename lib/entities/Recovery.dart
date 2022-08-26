import 'package:eTrade/helper/Sql_Connection.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:flutter/animation.dart';
import 'package:intl/intl.dart';

class Recovery {
  Recovery(
      {required this.amount,
      required this.description,
      required this.isPost,
      required this.dated,
      required this.userID,
      required this.recoveryID,
      required this.isCashOrCheck,
      required this.party});
  String dated;
  Customer party;
  int userID;
  double amount;
  bool isCashOrCheck;
  int recoveryID;
  String description;
  bool isPost;

  static Future<List<Recovery>> RecoveryForAdmin(bool islocal) async {
    var list = await Sql_Connection().read(
            "SELECT l.RecoveryId_Mobile As RecoveryID,l.SRId_Mobile as UserID,l.PartyID ,l.Amount,l.Dated,l.Detail as Description ,1 as isCash FROM dbo.Ledger AS l WHERE ISNULL(l.SRId_Mobile,0)>0 AND l.Amount<0") ??
        [];
    if (list.isNotEmpty) {
      List<Recovery> recoverylist = [];
      var dateStore = DateFormat('yyyy-MM-dd');
      list.forEach((element) {
        Recovery recovery = Recovery(
            amount: 0,
            description: "",
            isPost: false,
            dated: "",
            userID: 0,
            recoveryID: 0,
            isCashOrCheck: false,
            party: Customer.initializer());
        recovery.party.partyId = element['PartyID'];
        recovery.userID = element['UserID'];
        recovery.amount = element['Amount'];
        recovery.isCashOrCheck = element['isCash'] == 0
            ? false
            : element['isCash'] == false
                ? false
                : true;
        recovery.description =
            element['Remarks'] == null ? "" : element['Remarks'];
        recovery.dated = dateStore.format(DateTime.parse(element['Dated']));
        recoverylist.add(recovery);
      });
      return recoverylist;
    } else {
      return [];
    }
  }

  static List<Recovery> ViewOrderFromDb(List _order) {
    List<Recovery> _listRecoveryOrder = [];
    if (_order.isNotEmpty) {
      _order.forEach((element) {
        Recovery recoveryOrder = Recovery(
            isCashOrCheck: false,
            amount: 0,
            recoveryID: 0,
            userID: 0,
            dated: "",
            description: "",
            isPost: false,
            party: Customer.initializer());
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
