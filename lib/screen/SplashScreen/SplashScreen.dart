import 'package:etrade/components/NavigationBar.dart';
import 'package:etrade/entities/Customer.dart';
import 'package:etrade/entities/ViewRecovery.dart';
import 'package:etrade/main.dart';
import 'package:etrade/screen/NavigationScreen/DashBoard/DashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MySplashScreen extends StatefulWidget {
  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
      Get.off(
        () => MyNavigationBar.initializer(0),
        transition: Transition.circularReveal,
        duration: Duration(seconds: 2),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Image.asset("images/splash.gif",
                  gaplessPlayback: true, fit: BoxFit.fill))),
    );
  }
}
