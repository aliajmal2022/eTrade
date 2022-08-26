import 'package:eTrade/helper/Sql_Connection.dart';
import 'package:eTrade/helper/onldt_to_local_db.dart';
import 'package:eTrade/helper/sqlhelper.dart';

class Customer {
  Customer({
    required this.partyId,
    required this.discount,
    required this.balance,
    required this.partyName,
    required this.partyIdMobile,
    required this.userId,
    required this.address,
  });
  double discount;
  int partyId;
  int userId;
  int partyIdMobile;
  double balance;
  String address;
  String partyName = "Search Customer";
  bool match = false;
  static Customer initializer() {
    return Customer(
        partyIdMobile: 0,
        partyId: 0,
        partyName: "",
        discount: 0,
        balance: 0,
        address: "",
        userId: 0);
  }

  Customer selectedCustomer(List<Customer> customer) {
    Customer selectedcustomer = initializer();
    try {
      for (var element in customer) {
        if (element.partyName == partyName) {
          selectedcustomer.partyId = element.partyId;
          selectedcustomer.partyName = element.partyName;
          selectedcustomer.discount = element.discount;
          throw "";
        }
      }
    } catch (e) {
      return selectedcustomer;
    }
    return selectedcustomer;
  }

  static Future<List<Customer>> CustomerLOdb(bool islocaldb) async {
    List _party;
    List<Customer> _listProduct = [];
    if (islocaldb) {
      _party = await SQLHelper.getAllDataFromParty();
      // SQLHelper.instance.getTable("Party", "PartyID");
    } else {
      _party = await Sql_Connection().read('''
SELECT p.PartyID,replace(p.PartyName,'\\','') as PartyName,p.Discount,replace(p.Address,'\\','') as Address,
isnull(p.PartyID_Mobile,0)as PartyID_Mobile,ISNULL(lb.Balance,0) AS Balance  FROM Party AS p
LEFT JOIN
(SELECT l.PartyID,SUM(l.Amount) AS Balance FROM Ledger AS l WHERE l.PartyID between 22000 and 29999
 GROUP BY l.PartyID) AS lb
ON p.PartyID=lb.PartyID
WHERE p.AccTypeID=6
''');
    }
    if (_party.isNotEmpty) {
      _party.forEach((element) {
        Customer _customer = initializer();
        _customer.partyId = element['PartyID'];
        _customer.partyIdMobile = element['PartyID_Mobile'] ?? 0;
        _customer.partyName = element['PartyName'];
        _customer.discount = element['Discount'];
        _customer.balance = element['Balance'];
        _customer.address = element['Address'].toString();

        _listProduct.add(_customer);
      });
    }
    return _listProduct;
  }

  static List<String> customerList(List<Customer> clist) {
    List<String> _listProduct = [];
    for (int i = 0; i < clist.length - 1; i++) {
      String partyName = clist[i].partyName;
      _listProduct.add(partyName);
    }
    return _listProduct;
  }
}
