import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/User.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class SetTargetScreen extends StatefulWidget {
  static bool isTargetDataAvailable = false;
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
        monthName: "January", target: 0, controller: TextEditingController()),
    SetTarget(
        monthName: "February", target: 0, controller: TextEditingController()),
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

  PreLoadDataBase() async {
    List<String> staticMonthName = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    int count;
    List<SetTarget> list = [];
    var months = await SQLHelper.instance.getTable("UserTarget", "ID");

    setState(() {
      if (months.isNotEmpty) {
        SetTargetScreen.isTargetDataAvailable = true;
        int count;
        targetList.clear();
        for (count = 0; count < staticMonthName.length; count++) {
          SetTarget setTarget = SetTarget(
              controller: TextEditingController(), monthName: "", target: 0);
          setTarget.target = months[0][staticMonthName[count]];
          setTarget.monthName = staticMonthName[count];
          setTarget.controller.text = setTarget.target.toString();
          // orderStatic.month = element;
          targetList.add(setTarget);
        }
      } else {
        SetTargetScreen.isTargetDataAvailable = false;
      }
    });
  }

  @override
  void initState() {
    setState(() {
      PreLoadDataBase();
    });
    super.initState();
  }

  bool check = true;
  void CheckAnyOneEmpty(List<SetTarget> list) {
    bool contain = false;
    try {
      for (var element in list) {
        if (element.target != 0) {
          setState(() {
            check = false;
            contain = true;
            throw "";
          });
        }
      }
    } catch (e) {
      debugPrint("help");
    }
    // if (contain) {
    //   setState(() {
    //     check = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Set Target'),
          backgroundColor: eTradeGreen,
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          child: Text(
                        targetList[index].monthName,
                        style: TextStyle(fontSize: 20),
                      )),
                      Flexible(
                        child: Container(
                          height: 50,
                          width: 100,
                          // padding: EdgeInsets.all(5),
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
                                borderSide: BorderSide(color: eTradeGreen),
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
          backgroundColor: check ? Colors.green.shade100 : eTradeGreen,
          onPressed: check
              ? null
              : () async {
                  UserTarget userTarget = UserTarget(
                      januaryTarget: 0,
                      februaryTarget: 0,
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
                  userTarget.januaryTarget = targetList[0].target;
                  userTarget.februaryTarget = targetList[1].target;
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
                  SetTargetScreen.isTargetDataAvailable
                      ? await SQLHelper.updateUserTargetTable(userTarget)
                      : await SQLHelper.instance.createUserTarget(userTarget);

                  Get.off(
                      MyNavigationBar(
                        editRecovery: ViewRecovery(
                            amount: 0,
                            description: "",
                            checkOrCash: false,
                            recoveryID: 0,
                            dated: "",
                            party: Customer(
                                userId: 0,
                                partyIdMobile: 0,
                                address: "",
                                partyId: 0,
                                partyName: "",
                                discount: 0)),
                        selectedIndex: 0,
                        list: [],
                        date: "",
                        id: 0,
                        partyName: "Search Customer",
                      ),
                      transition: Transition.rightToLeft);
                },
          child: Icon(
            SetTargetScreen.isTargetDataAvailable ? Icons.edit : Icons.done_all,
          ),
        ));
  }
}

class UserTarget {
  UserTarget({
    required this.januaryTarget,
    required this.februaryTarget,
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
  int januaryTarget;
  int februaryTarget;
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
