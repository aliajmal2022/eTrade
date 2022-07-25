import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:flutter/material.dart';

class MySplashScreen extends StatefulWidget {
  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
        const Duration(milliseconds: 3000),
        () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MyNavigationBar(
                        selectedIndex: 0,
                        editRecovery: ViewRecovery(
                            amount: 0,
                            description: "",
                            recoveryID: 0,
                            dated: "",
                            party: Customer(
                                partyId: 0, partyName: "", discount: 0)),
                        orderId: 0,
                        orderList: [],
                        orderDate: "",
                        orderPartyName: "Search Customer",
                      )),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Image.asset("images/logo.gif",
                  gaplessPlayback: true, fit: BoxFit.fill))),
    );
  }
}
