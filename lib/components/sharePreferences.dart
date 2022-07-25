// ignore_for_file: unused_field

import 'package:shared_preferences/shared_preferences.dart';

class UserSharePreferences {
  static var prefs;
  static const ip = "Ip Address";
  static const flag = "User Login";
  static const id = "UserId";
  static const mode = "Light/Dark";
  static Future init() async => prefs = await SharedPreferences.getInstance();
  static Future setIp(String usrip) async => await prefs.setString(ip, usrip);
  static String getIp() => prefs.getString(ip);
  static Future setflag(bool isusrlogin) async =>
      await prefs.setBool(flag, isusrlogin);
  static bool getflag() => prefs.getBool(flag);
  static Future setmode(bool isLight) async =>
      await prefs.setBool(mode, isLight);
  static bool getmode() => prefs.getBool(mode);
  static Future setId(int usrid) async => await prefs.setInt(id, usrid);
  static int getId() => prefs.getInt(id);
}
