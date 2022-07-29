import 'package:eTrade/helper/Sql_Connection.dart';
import 'package:eTrade/helper/onldt_to_local_db.dart';
import 'package:eTrade/helper/sqlhelper.dart';

class Customer {
  Customer({
    required this.partyId,
    required this.discount,
    required this.partyName,
    required this.userId,
    required this.address,
  });
  double discount;
  int partyId;
  int userId;
  String address;
  String partyName = "Search Customer";
  bool match = false;
  Customer selectedCustomer(List<Customer> customer) {
    Customer selectedcustomer = Customer(
        partyId: 0, partyName: "", discount: 0, address: "", userId: 0);
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
      _party = await SQLHelper.instance.getTable("Party", "PartyID");
    } else {
      _party = await Sql_Connection().read(
          'SELECT p.PartyID,p.PartyName,p.Discount,p.Address FROM Party AS p WHERE p.AccTypeID=6');
    }
    if (_party.isNotEmpty) {
      _party.forEach((element) {
        Customer _customer = Customer(
            partyId: 0, partyName: "", discount: 0, address: "", userId: 0);
        _customer.partyId = element['PartyID'];
        _customer.partyName = element['PartyName'];
        _customer.discount = element['Discount'];
        _customer.address = element['Address'];

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
