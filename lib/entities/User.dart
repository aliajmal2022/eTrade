import 'package:eTrade/components/Sql_Connection.dart';
import 'package:eTrade/components/sqlhelper.dart';

class User {
  User({required this.userName, required this.password, required this.id});
  int id;
  String userName;
  String password;
  static Future<List<User>> UserList(bool islocaldb) async {
    List<dynamic> _user = [];
    List<User> _listUser = [];
    if (islocaldb) {
      _user = await SQLHelper.instance.getTable("User", "ID");
    } else {
      _user = await Sql_Connection()
          .read('SELECT ID,UserName,[PASSWORD] FROM [Login] AS l');
    }
    if (_user.isNotEmpty) {
      _user.forEach((element) {
        User user = User(id: 0, userName: "", password: "");
        user.id = element['ID'];
        user.userName = element['UserName'];
        user.password = element['PASSWORD'];
        _listUser.add(user);
      });
    }
    return _listUser;
  }

  static List<dynamic> userListdb(
    int _length,
    var _name,
    var _id,
    var _password,
  ) {
    User _user;
    List<dynamic> _listUser = [];
    for (int i = 0; i < _length; i++) {
      _user = User(userName: "", password: "", id: 0);
      _user.id = _id[i];
      _user.userName = _name[i];
      _user.password = _password[i];
      _listUser.add(_user);
    }
    return _listUser;
  }

  static Future<int> CheckExist(String userInp, String passwd) async {
    List<User> userList = await User.UserList(false);
    int usrid = 0;
    for (var element in userList) {
      print(element.id);
      if (element.userName == userInp && element.password == passwd) {
        usrid = element.id;
      }
    }
    return usrid;
  }
}
