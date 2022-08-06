import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/sharePreferences.dart';
import 'package:eTrade/screen/Connection/ConnectionScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:eTrade/screen/SplashScreen/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:core';

import 'package:get/get_navigation/get_navigation.dart';

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

  final contrller = Get.put(Controller());
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: MyApp.themeNotifier,
        builder: (context, ThemeMode currentMode, __) {
          return GetMaterialApp(
            title: 'eTrade',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'NunitoSans'),
            darkTheme: ThemeData(
                brightness: Brightness.dark, fontFamily: 'NunitoSans'),
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

class Controller extends GetxController {
  var count = 0.obs;
  increment() => count++;
}
