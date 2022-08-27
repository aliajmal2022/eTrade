// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eTrade/components/CustomNavigator.dart';
import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/helper/Sql_Connection.dart';
import 'package:eTrade/components/sharePreferences.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/screen/LoginScreen/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectionScreen extends StatefulWidget {
  ConnectionScreen({required this.isConnectionfromdrawer});
  bool isConnectionfromdrawer;
  static bool isLocal = true;
  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  String userIp = "";
  final _controller = TextEditingController();
  bool indRun = true;
  final _error = "Please Enter Correct Ip or Near to the Router";
  bool valid = true;
  bool islocal = true;
  @override
  void initState() {
    setState(() {
      if (widget.isConnectionfromdrawer) {
        islocal = ConnectionScreen.isLocal;
        _controller.text = UserSharePreferences.getIp();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 200,
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: eTradeMainColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 9,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Center(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 30.0,
                      fontFamily: 'Bobbers',
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          "Please Make Connection.",
                          speed: const Duration(milliseconds: 150),
                        ),
                      ],
                      pause: const Duration(milliseconds: 1000),
                      repeatForever: true,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        ConnectionScreen.isLocal
                            ? "Local DataBase"
                            : "Online DataBase",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Switch(
                    value: islocal,
                    onChanged: (value) async {
                      setState(() {
                        islocal = value;
                        ConnectionScreen.isLocal = islocal;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _controller,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      // inputFormatters: <TextInputFormatter>[
                      //   FilteringTextInputFormatter.digitsOnly,
                      // ],
                      onChanged: (value) {
                        setState(() {
                          userIp = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(width: 30.0)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(color: eTradeMainColor),
                        ),
                        labelText: '  IP Address',
                        errorText: valid ? null : _error,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MaterialButton(
                        disabledElevation: 10.0,
                        disabledColor: Color(0x0ff1e1e1),
                        // disabledColor: Color(0x0ff1e1e1),
                        onPressed: () async {
                          String ip = '';
                          String port = '';
                          if (userIp.isNotEmpty && userIp.contains(',')) {
                            var strToList = userIp.split(",");
                            ip = strToList[0];
                            port = strToList[1];
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                });
                            Future.delayed(Duration(seconds: 1), () async {
                              bool isconnected = await Sql_Connection.connect(
                                  context, ip, port);
                              if (isconnected) {
                                setState(() {
                                  isconnected = false;
                                  _controller.clear();
                                  Navigator.pop(context);
                                });
                                if (MyDrawer.makeConnection) {
                                  UserSharePreferences.setIp(userIp);
                                  MyDrawer.makeConnection = false;
                                  Get.to(MyNavigationBar.initializer(0));
                                } else {
                                  await UserSharePreferences.setAdmin();
                                  Navigator.push(
                                      context,
                                      MyCustomRoute(
                                          slide: "Left",
                                          builder: (context) => LoginScreen(
                                                ip: userIp,
                                              )));
                                }
                              } else {
                                setState(() {
                                  valid = false;
                                  Navigator.pop(context);
                                });
                              }
                            });
                          } else {
                            setState(() {
                              valid = false;
                            });
                          }
                        },
                        elevation: 20.0,
                        color: eTradeMainColor,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0))),
                        minWidth: double.infinity,
                        height: 50,
                        child: Text(
                          "Make Connection",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
