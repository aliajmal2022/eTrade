// ignore_for_file: unused_field

import 'package:eTrade/entities/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSharePreferences {
  static var prefs;
  static const ip = "Ip Address";
  static const flag = "User Login";
  static const id = "UserId";
  static const isAdmin = "Is Admin";
  static const name = "UserName";
  static const adminName = "AdminName";
  static const adminPassword = "Password";
  static const mode = "Dark";
  static Future setAdmin() async {
    await setAdminName();
    await setAdminPassword();
  }

  static bool isAdminOrNot(User user) {
    return (getAdminName() == user.userName &&
            getAdminPassword() == user.password)
        ? true
        : false;
  }

  static Future init() async => prefs = await SharedPreferences.getInstance();

  static Future setAdminName() async =>
      await prefs.setString(adminName, "ADMIN");
  static String getAdminName() => prefs.getString(adminName);
  static Future setAdminPassword() async =>
      await prefs.setString(adminPassword, "ALLAH");
  static String getAdminPassword() => prefs.getString(adminPassword);
  static Future setIp(String usrip) async => await prefs.setString(ip, usrip);
  static String getIp() => prefs.getString(ip) ?? "";
  static Future setName(String usrname) async =>
      await prefs.setString(name, usrname);
  static String getName() => prefs.getString(name) ?? "";
  static Future setflag(bool isusrlogin) async =>
      await prefs.setBool(flag, isusrlogin);
  static bool getflag() => prefs.getBool(flag) ?? false;
  static Future setmode(bool isDark) async {
    await prefs.setBool(mode, isDark);
  }

  static Future setisAdminOrNot(bool isadmin) async =>
      await prefs.setBool(isAdmin, isadmin);
  static bool getisAdminOrNot() => prefs.getBool(isAdmin) ?? false;
  static bool getmode() => prefs.getBool(mode);
  static Future setId(int usrid) async => await prefs.setInt(id, usrid);
  static int getId() => prefs.getInt((id)) ?? 0;
}
