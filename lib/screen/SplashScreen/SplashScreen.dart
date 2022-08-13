import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/main.dart';
import 'package:eTrade/screen/NavigationScreen/DashBoard/DashboardScreen.dart';
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
        () => MyNavigationBar(
          selectedIndex: 0,
          editRecovery: ViewRecovery(
              amount: 0,
              description: "",
              checkOrCash: false,
              recoveryID: 0,
              dated: "",
              party: Customer(
                  address: "",
                  partyId: 0,
                  userId: 0,
                  partyIdMobile: 0,
                  partyName: "",
                  discount: 0)),
          id: 0,
          list: [],
          date: "",
          partyName: "Search Customer",
        ),
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
