// ignore_for_file: unused_field

import 'package:shared_preferences/shared_preferences.dart';

class UserSharePreferences {
  static var prefs;
  static const ip = "Ip Address";
  static const flag = "User Login";
  static const id = "UserId";
  static const isAdmin = "Is Admin";
  static const mode = "Dark";
  static Future init() async => prefs = await SharedPreferences.getInstance();
  static Future setIp(String usrip) async => await prefs.setString(ip, usrip);
  static String getIp() => prefs.getString(ip) ?? "";
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
