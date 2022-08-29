import 'package:etrade/components/NavigationBar.dart';
import 'package:etrade/entities/Customer.dart';
import 'package:etrade/entities/Products.dart';
import 'package:etrade/entities/User.dart';
import 'package:etrade/screen/NavigationScreen/DashBoard/SetTarget.dart';

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
