import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/sharePreferences.dart';
import 'package:eTrade/screen/ConnectionScreen.dart';
import 'package:eTrade/screen/TakeOrderScreen.dart';
import 'package:eTrade/screen/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'dart:core';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSharePreferences.init();
  // MyApp.isDark = await UserSharePreferences.setmode(false);
  MyApp.isExist = await MyApp.PreLoadDataBase();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static var isExist;
  static Future<bool> PreLoadDataBase() async {
    bool exist = await TakeOrderScreen.getdataFromDb();
    return exist;
  }

  static bool isDark = false;
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var isexist = MyApp.isExist;
  @override
  void initState() {
    setState(() {
      if (!isexist) {
        UserSharePreferences.setmode(false);
      }
      MyApp.isDark = UserSharePreferences.getmode();
      MyApp.themeNotifier.value =
          (MyApp.isDark) ? ThemeMode.dark : ThemeMode.light;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: MyApp.themeNotifier,
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
