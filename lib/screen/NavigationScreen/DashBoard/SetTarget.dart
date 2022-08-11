import 'package:eTrade/components/constants.dart';
import 'package:eTrade/entities/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class SetTargetScreen extends StatefulWidget {
  @override
  State<SetTargetScreen> createState() => _SetTargetScreenState();
}

class SetTarget {
  SetTarget(
      {required this.controller,
      required this.monthName,
      required this.target});
  int target;
  TextEditingController controller;
  String monthName;
}

class _SetTargetScreenState extends State<SetTargetScreen> {
  List<SetTarget> targetList = [
    SetTarget(
        monthName: "Januanry", target: 0, controller: TextEditingController()),
    SetTarget(
        monthName: "Febuary", target: 0, controller: TextEditingController()),
    SetTarget(
        monthName: "March", target: 0, controller: TextEditingController()),
    SetTarget(
        monthName: "April", target: 0, controller: TextEditingController()),
    SetTarget(monthName: "May", target: 0, controller: TextEditingController()),
    SetTarget(
        monthName: "June", target: 0, controller: TextEditingController()),
    SetTarget(
        monthName: "July", target: 0, controller: TextEditingController()),
    SetTarget(
        monthName: "August", target: 0, controller: TextEditingController()),
    SetTarget(
        monthName: "September", target: 0, controller: TextEditingController()),
    SetTarget(
        monthName: "October", target: 0, controller: TextEditingController()),
    SetTarget(
        monthName: "November", target: 0, controller: TextEditingController()),
    SetTarget(
        monthName: "December", target: 0, controller: TextEditingController()),
  ];
  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  bool check = true;
  void CheckAnyOneEmpty(List<SetTarget> list) {
    bool contain = false;
    try {
      for (var element in list) {
        if (element.target == 0) {
          setState(() {
            check = true;
            contain = true;
            throw "";
          });
        }
      }
    } catch (e) {
      debugPrint("help");
    }
    if (!contain) {
      setState(() {
        check = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: eTradeGreen,
        ),
        body: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                          child: Text(
                        targetList[index].monthName,
                        style: TextStyle(fontSize: 20),
                      )),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(4),
                          child: TextField(
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            controller: targetList[index].controller,
                            onChanged: (value) {
                              setState(() {
                                if (value.isNotEmpty) {
                                  targetList[index].target = int.parse(value);
                                  CheckAnyOneEmpty(targetList);
                                } else {
                                  targetList[index].target = 0;
                                  check = true;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(width: 20.0)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: eTradeBlue),
                              ),
                              labelText: 'Set Target',
                              labelStyle: TextStyle(color: eTradeGreen),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
            );
          },
          itemCount: targetList.length,
          shrinkWrap: true,
          padding: EdgeInsets.all(5),
          scrollDirection: Axis.vertical,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: eTradeGreen,
          onPressed: check
              ? null
              : () {
                  UserTarget userTarget = UserTarget(
                      januanryTarget: 0,
                      febuaryTarget: 0,
                      marchTarget: 0,
                      aprilTarget: 0,
                      mayTarget: 0,
                      juneTarget: 0,
                      julyTarget: 0,
                      augustTarget: 0,
                      septemberTarget: 0,
                      octoberTarget: 0,
                      novemberTarget: 0,
                      decemberTarget: 0);
                  userTarget.januanryTarget = targetList[0].target;
                  userTarget.febuaryTarget = targetList[1].target;
                  userTarget.marchTarget = targetList[2].target;
                  userTarget.aprilTarget = targetList[3].target;
                  userTarget.mayTarget = targetList[4].target;
                  userTarget.juneTarget = targetList[5].target;
                  userTarget.julyTarget = targetList[6].target;
                  userTarget.augustTarget = targetList[7].target;
                  userTarget.septemberTarget = targetList[8].target;
                  userTarget.octoberTarget = targetList[9].target;
                  userTarget.novemberTarget = targetList[10].target;
                  userTarget.decemberTarget = targetList[11].target;
                  print(userTarget);
                },
          child: Icon(
            Icons.done_all,
          ),
        ));
  }
}

class UserTarget {
  UserTarget({
    required this.januanryTarget,
    required this.febuaryTarget,
    required this.marchTarget,
    required this.aprilTarget,
    required this.mayTarget,
    required this.juneTarget,
    required this.julyTarget,
    required this.augustTarget,
    required this.septemberTarget,
    required this.octoberTarget,
    required this.novemberTarget,
    required this.decemberTarget,
  });
  int januanryTarget;
  int febuaryTarget;
  int marchTarget;
  int aprilTarget;
  int mayTarget;
  int juneTarget;
  int julyTarget;
  int augustTarget;
  int septemberTarget;
  int octoberTarget;
  int novemberTarget;
  int decemberTarget;
}
