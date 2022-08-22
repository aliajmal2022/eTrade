import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:eTrade/entities/User.dart';

class DataBaseDataLoad {
  static bool isFirstTime = false;
  static List<Customer> ListOCustomer = [];
  static List<Product> ListOProduct = [];
  static List<User> ListOUser = [];
  static var PartiesName;
  static Future<bool> DataLoading() async {
    try {
      ListOProduct = await Product.ProductLOdb(true);
      ListOCustomer = await Customer.CustomerLOdb(true);
      PartiesName = Customer.customerList(ListOCustomer);

      ListOUser = await User.UserList(true);
    } catch (e) {
      isFirstTime = true;
      return false;
    }

    return true;
  }
}
