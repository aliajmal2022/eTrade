// ignore_for_file: prefer_const_constructors

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/helper/onldt_to_local_db.dart';
import 'package:eTrade/components/sharePreferences.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/entities/User.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({required this.ip, required this.fromMasterReset});
  String ip;
  bool fromMasterReset;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool flag = false;
  bool valid = true;
  String userInp = "";
  String passwd = "";
  final _pdcontroller = TextEditingController();
  final _usrcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: 200,
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: eTradeGreen,
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
                          "Login",
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
              height: 30,
            ),
            valid
                ? Container(
                    child: Text("Enter Username and Password",
                        style: TextStyle(
                          fontSize: 20,
                        )),
                  )
                : Container(
                    child: Text("Please Enter Valid Username or Password",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.red.shade400,
                        ))),
            SizedBox(
              height: 10,
            ),
            Expanded(
                flex: 4,
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _usrcontroller,
                          onChanged: (value) {
                            setState(() {
                              userInp = value.toUpperCase();
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                borderSide: BorderSide(width: 30.0)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              borderSide: BorderSide(color: eTradeGreen),
                            ),
                            labelText: 'Username',
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          obscureText: true,
                          controller: _pdcontroller,
                          onChanged: (value) {
                            setState(() {
                              passwd = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                borderSide: BorderSide(width: 30.0)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              borderSide: BorderSide(color: eTradeGreen),
                            ),
                            labelText: 'Password',
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        MaterialButton(
                            onPressed: (userInp == "" || passwd == "")
                                ? null
                                : () async {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        });
                                    Future.delayed(Duration(seconds: 2),
                                        () async {
                                      User usr = await User.CheckExist(
                                          userInp, passwd);

                                      if (usr.id != 0) {
                                        if (widget.fromMasterReset) {
                                          await SQLHelper.resetData("Reset");

                                          await TakeOrderScreen.onLoading(
                                              context, false);

                                          await DataBaseDataLoad.DataLoading();
                                        } else {
                                          UserSharePreferences.setId(usr.id);
                                          UserSharePreferences.SetTargetScreen(
                                              usr.monthlyTarget);
                                          UserSharePreferences.setIp(widget.ip);
                                          UserSharePreferences.setflag(flag);
                                          UserSharePreferences.setmode(false);
                                          await TakeOrderScreen.onLoading(
                                              context, false);
                                        }
                                      } else {
                                        setState(() {
                                          valid = false;
                                          Navigator.pop(context);
                                        });
                                      }
                                    });
                                  },
                            elevation: 20.0,
                            disabledColor: Colors.grey,
                            // disabledColor: Color(0x0ff1e1e1),
                            color: eTradeGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0))),
                            minWidth: double.infinity,
                            height: 50,
                            child: Text(
                              "Login",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            )),
                      ],
                    ))),
          ],
        ),
      ),
    );
  }
}
