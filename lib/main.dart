import 'package:eTrade/components/sharePreferences.dart';
import 'package:eTrade/screen/ConnectionScreen.dart';
import 'package:eTrade/screen/TakeOrderScreen.dart';
import 'package:eTrade/screen/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'dart:core';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSharePreferences.init();
  MyApp.isExist = await MyApp.PreLoadDataBase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static var isExist;
  static Future<bool> PreLoadDataBase() async {
    bool exist = await TakeOrderScreen.getdataFromDb();
    return exist;
  }

  static bool isDark = false;
  var isexist = isExist;

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, ThemeMode currentMode, __) {
          return MaterialApp(
            title: 'eTrade',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(),
            darkTheme: ThemeData.dark(),
            themeMode: currentMode,
            home: (isexist)
                ? MySplashScreen()
                : ConnectionScreen(
                    isConnectionfromdrawer: false,
                  ),
          );
        });
  }
}
