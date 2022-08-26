import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/helper/Sql_Connection.dart';
import 'package:eTrade/helper/sqlhelper.dart';

class User {
  User(
      {required this.userName,
      required this.password,
      required this.monthlyTarget,
      required this.id});
  int id;
  String userName;
  String password;
  int monthlyTarget;
  static Future<List<User>> UserList(bool islocaldb) async {
    List<dynamic> _user = [];
    List<User> _listUser = [];
    if (islocaldb) {
      _user = await SQLHelper.instance.getTable("User", "ID");
    } else {
      _user = await Sql_Connection().read(
          'SELECT SrID AS ID,sr.SRName AS UserName,sr.[Password],sr.MobileAccess FROM SaleRap AS sr WHERE ISNULL(sr.MobileAccess,0)=1');
    }
    if (_user.isNotEmpty) {
      _user.forEach((element) {
        User user = User(id: 0, userName: "", password: "", monthlyTarget: 0);
        user.id = element['ID'];
        user.userName = element['UserName'];
        user.password = element['Password'];
        // user.monthlyTarget = element['MonthlyTarget'];
        _listUser.add(user);
      });
    }
    return _listUser;
  }

  static User initializer() {
    return User(id: 0, userName: "", password: "", monthlyTarget: 0);
  }
  // static List<dynamic> userListdb(
  //     int _length, var _name, var _id, var _password, var _monthlyTarget) {
  //   User _user;
  //   List<dynamic> _listUser = [];
  //   for (int i = 0; i < _length; i++) {
  //     _user = User(userName: "", password: "", id: 0, monthlyTarget: 0);
  //     _user.id = _id[i];
  //     _user.userName = _name[i];
  //     _user.password = _password[i];
  //     _user.monthlyTarget = _monthlyTarget[i];
  //     _listUser.add(_user);
  //   }
  //   return _listUser;
  // }

  static Future<User> getUserID(String name) async {
    List<User> userList = await User.UserList(true);
    for (var element in userList) {
      if (element.userName.toUpperCase() == name.toUpperCase()) {
        return element;
      }
    }
    return initializer();
  }

  static Future<User> CheckExist(String userInp, String passwd) async {
    List<User> userList = await User.UserList(false);
    User usr = User(userName: "", password: "", monthlyTarget: 0, id: 0);
    for (var element in userList) {
      if (element.userName.toUpperCase() == userInp &&
          element.password == passwd) {
        return element;
      }
    }
    return usr;
  }
}
