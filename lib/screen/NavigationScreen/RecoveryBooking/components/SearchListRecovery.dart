import 'package:etrade/components/CustomNavigator.dart';
import 'package:etrade/components/NavigationBar.dart';
import 'package:etrade/components/constants.dart';
import 'package:etrade/screen/NavigationScreen/RecoveryBooking/components/ViewRecoveryTabBar.dart';
import 'package:etrade/helper/sqlhelper.dart';
import 'package:etrade/entities/ViewBooking.dart';
import 'package:etrade/entities/ViewRecovery.dart';
import 'package:etrade/main.dart';
import 'package:etrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:etrade/screen/NavigationScreen/RecoveryBooking/RecoveryScreen.dart';
import 'package:etrade/screen/NavigationScreen/RecoveryBooking/RecoveryDetailScreen.dart';
import 'package:etrade/screen/NavigationScreen/Booking/OrderDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class ListOfRecovery extends StatefulWidget {
  ListOfRecovery({required this.matchItem, required this.tabName});
  String matchItem;
  String tabName;
  @override
  State<ListOfRecovery> createState() => _ListOfRecoveryState();
}

class _ListOfRecoveryState extends State<ListOfRecovery>
    with TickerProviderStateMixin {
  List<ViewRecovery> dummyOrderList = [];
  CheckList(List list) {
    dummyOrderList.clear();

    for (var element in list) {
      if (element.party.partyName.toLowerCase().contains(widget.matchItem)) {
        setState(() {
          dummyOrderList.add(element);
        });
      }
    }
  }

  var _animationController;
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animationController.forward();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = ScrollController();
    CheckList(RecoveryTabBarItem.listOfRecovery);
    return dummyOrderList.isNotEmpty
        ? ListView.builder(
            controller: _controller,
            itemBuilder: (BuildContext context, index) {
              return MyNavigationBar.isAdmin
                  ? SlideTransition(
                      position:
                          Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                              .animate(_animationController),
                      child: FadeTransition(
                          opacity: _animationController,
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.0),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Recovery Id: ${dummyOrderList[index].recoveryID}",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            Text(
                                              "${dummyOrderList[index].party.partyName}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                // fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Recovery On",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                      // fontWeight:
                                                      //     FontWeight
                                                      //         .bold
                                                    )),
                                                Text(
                                                  "${dummyOrderList[index].dated}",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .backgroundColor,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5))),
                                              child: Text(
                                                "Rs ${formatter.format(dummyOrderList[index].amount)} ",
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: ThemeData.light()
                                                      .cardColor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            MaterialButton(
                                              onPressed: () async {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RecoveryDetailScreen(
                                                              selectedRecovery:
                                                                  RecoveryTabBarItem
                                                                          .listOfRecovery[
                                                                      index],
                                                            )));
                                              },
                                              padding: EdgeInsets.zero,
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    color: etradeMainColor,
                                                    // (MyApp.isDark)
                                                    // ? Colors.grey
                                                    // : Colors
                                                    //     .grey.shade300,
                                                    // border: Border.all(
                                                    //     color:
                                                    //         etradeMainColor,
                                                    //     width: 1),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5))),
                                                child: Text(
                                                  "Recovery Detail",
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .cardColor,
                                                      // fontStyle: FontStyle.italic,
                                                      fontSize: 13),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ))))
                  : Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: SlideTransition(
                          position: Tween<Offset>(
                                  begin: Offset(1, 0), end: Offset(0, 0))
                              .animate(_animationController),
                          child: FadeTransition(
                              opacity: _animationController,
                              child: Slidable(
                                  key: const ValueKey(0),
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (((context) async {
                                          RecoveryScreen.isEditRecovery = true;
                                          Navigator.push(
                                              context,
                                              MyCustomRoute(
                                                  slide: "Left",
                                                  builder: (context) =>
                                                      MyNavigationBar(
                                                        selectedIndex: 3,
                                                        date: "",
                                                        editRecovery:
                                                            dummyOrderList[
                                                                index],
                                                        list: [],
                                                        id: 0,
                                                        partyName: "",
                                                      )));
                                        })),
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        icon: Icons.edit,
                                        label: 'Edit',
                                      ),
                                      SlidableAction(
                                        onPressed: ((context) async {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Really want to detele"),
                                                  action: SnackBarAction(
                                                      label: "Delete",
                                                      onPressed: () async {
                                                        await SQLHelper
                                                            .deleteItem(
                                                                "Recovery",
                                                                "RecoveryID",
                                                                dummyOrderList[
                                                                        index]
                                                                    .recoveryID);

                                                        var _recovery;
                                                        DateFormat dateFormat =
                                                            DateFormat(
                                                                'dd-MM-yyyy');
                                                        if (widget.tabName ==
                                                            "Search") {
                                                          _recovery = await SQLHelper
                                                              .getFromToRecovery(
                                                                  RecoveryTabBarItem
                                                                      .getFromDate(),
                                                                  RecoveryTabBarItem
                                                                      .getToDate());
                                                        } else if (widget
                                                                .tabName ==
                                                            "Today") {
                                                          String todayDate =
                                                              dateFormat.format(
                                                                  DateTime
                                                                      .now());
                                                          _recovery = await SQLHelper
                                                              .getSpecificRecovery(
                                                                  todayDate);
                                                        } else if (widget
                                                                .tabName ==
                                                            "Yesterday") {
                                                          String yesterdayDate =
                                                              dateFormat.format(DateTime
                                                                      .now()
                                                                  .subtract(
                                                                      Duration(
                                                                          days:
                                                                              1)));
                                                          _recovery = await SQLHelper
                                                              .getSpecificRecovery(
                                                                  yesterdayDate);
                                                        } else {
                                                          _recovery =
                                                              await SQLHelper
                                                                  .getAllRecovery();
                                                        }
                                                        setState(() {
                                                          RecoveryTabBarItem
                                                                  .listOfRecovery =
                                                              ViewRecovery
                                                                  .ViewRecoveryFromDb(
                                                                      _recovery);
                                                          if (RecoveryTabBarItem
                                                              .listOfRecovery
                                                              .isNotEmpty) {
                                                            CheckList(
                                                                RecoveryTabBarItem
                                                                    .listOfRecovery);
                                                          }
                                                        });
                                                      })));
                                        }),
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Delete',
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Recovery Id: ${dummyOrderList[index].recoveryID}",
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    ),
                                                    Text(
                                                      "${dummyOrderList[index].party.partyName}",
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        // fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text("Recovery On",
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.grey,
                                                              // fontWeight:
                                                              //     FontWeight
                                                              //         .bold
                                                            )),
                                                        Text(
                                                          "${dummyOrderList[index].dated}",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 13),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                          color: Theme.of(
                                                                  context)
                                                              .backgroundColor,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                      child: Text(
                                                        "Rs ${formatter.format(dummyOrderList[index].amount)}",
                                                        style: TextStyle(
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color:
                                                              ThemeData.light()
                                                                  .cardColor,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    MaterialButton(
                                                      onPressed: () async {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        RecoveryDetailScreen(
                                                                          selectedRecovery:
                                                                              RecoveryTabBarItem.listOfRecovery[index],
                                                                        )));
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                                color:
                                                                    etradeMainColor,
                                                                // (MyApp.isDark)
                                                                // ? Colors.grey
                                                                // : Colors
                                                                //     .grey.shade300,
                                                                // border: Border.all(
                                                                //     color:
                                                                //         etradeMainColor,
                                                                //     width: 1),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                        child: Text(
                                                          "Recovery Detail",
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .cardColor,
                                                              // fontStyle: FontStyle.italic,
                                                              fontSize: 13),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )))
                              // ),
                              )));
            },
            itemCount: dummyOrderList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.all(5),
            scrollDirection: Axis.vertical,
          )
        : const Center(
            child: const Text("Not Found"),
          );
  }
}
