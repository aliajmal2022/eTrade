import 'dart:math';

import 'package:eTrade/components/CustomNavigator.dart';
import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/components/SearchListOrder.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/components/SearchListRecovery.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Edit.dart';
import 'package:eTrade/entities/Recovery.dart';
import 'package:eTrade/entities/ViewBooking.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/main.dart';
import 'package:eTrade/screen/NavigationScreen/Take%20Order/TakeOrderScreen.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/RecoveryScreen.dart';
import 'package:eTrade/screen/NavigationScreen/Booking/OrderDetailScreen.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/RecoveryDetailScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class RecoveryTabBarItem extends StatefulWidget {
  RecoveryTabBarItem({required this.tabName});
  String tabName;
  static String fromDate = '';
  static String toDate = '';
  static setFromDate(String date) {
    fromDate = date;
  }

  static setToDate(String date) {
    toDate = date;
  }

  static getFromDate() {
    return fromDate;
  }

  static getToDate() {
    return toDate;
  }

  static List<ViewRecovery> listOfRecovery = [];
  @override
  State<RecoveryTabBarItem> createState() => _RecoveryTabBarItemState();
}

class _RecoveryTabBarItemState extends State<RecoveryTabBarItem>
    with TickerProviderStateMixin {
  var _animationController;
  String range = 'Select Date';
  String searchString = "";
  TextEditingController controller = TextEditingController();
  String prerange = 'Select Date';
  var _recovery;
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animationController.forward();
    RecoveryTabBarItem.listOfRecovery = [];
    if (widget.tabName == "Search") {
      range = RecoveryTabBarItem.getFromDate() +
              "-" +
              RecoveryTabBarItem.getToDate() ??
          RecoveryTabBarItem.getFromDate();
      if (RecoveryTabBarItem.getFromDate() != "" &&
          RecoveryTabBarItem.getToDate() != "") {
        setState(() {
          prerange = range;
        });
        checkListDateAvialable(widget.tabName);
      }
    } else if (widget.tabName == "Today") {
      checkListDateAvialable(widget.tabName);
    } else if (widget.tabName == "Yesterday") {
      checkListDateAvialable(widget.tabName);
    } else {
      checkListDateAvialable(widget.tabName);
    }

    super.initState();
  }

  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  checkListDateAvialable(String tabName) async {
    if (widget.tabName == "Search") {
      _recovery = await SQLHelper.getFromToRecovery(
          RecoveryTabBarItem.getFromDate(), RecoveryTabBarItem.getToDate());
    } else if (widget.tabName == "Today") {
      String todayDate = dateFormat.format(DateTime.now());
      _recovery = await SQLHelper.getSpecificRecovery(todayDate);
    } else if (widget.tabName == "Yesterday") {
      String yesterdayDate =
          dateFormat.format(DateTime.now().subtract(Duration(days: 1)));
      _recovery = await SQLHelper.getSpecificRecovery(yesterdayDate);
    } else {
      _recovery = await SQLHelper.getAllRecovery();
    }
    RecoveryTabBarItem.listOfRecovery =
        ViewRecovery.ViewRecoveryFromDb(_recovery);
    setState(() {
      if (RecoveryTabBarItem.listOfRecovery.isNotEmpty) {
        RecoveryTabBarItem.listOfRecovery;
      } else {
        RecoveryTabBarItem.listOfRecovery = [];
      }
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    // setState(() {
    if (args.value is PickerDateRange) {
      range = '${DateFormat('dd-MM-yyyy').format(args.value.startDate)}/'
          '${DateFormat('dd-MM-yyyy').format(args.value.endDate ?? args.value.startDate)}';
    }
  }

  void datePickerBox() {
    Widget cancelButton = TextButton(
        onPressed: (() {
          Navigator.pop(context);
        }),
        child: const Text(
          "Cancel",
          style: TextStyle(color: eTradeMainColor),
        ));
    Widget selectedButton = TextButton(
        onPressed: (() {
          setState(() {
            prerange = range;
            var splitDate = prerange.split('/');
            RecoveryTabBarItem.setFromDate(splitDate[0]);
            RecoveryTabBarItem.setToDate(splitDate[1]);
          });
          Navigator.pop(context);
        }),
        child: const Text("Select", style: TextStyle(color: eTradeMainColor)));
    List<Widget> LOWidget = [cancelButton, selectedButton];
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    Widget selectDateDialog = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(const Radius.circular(10.0))),
      actions: LOWidget,
      title: const Text("Select Date"),
      content: Container(
        height: (isLandscape) ? height : height / 3,
        width: (isLandscape) ? width / 2.5 : width / 4,
        child: SfDateRangePicker(
          onSelectionChanged: _onSelectionChanged,
          selectionMode: DateRangePickerSelectionMode.range,
          startRangeSelectionColor: eTradeMainColor,
          endRangeSelectionColor: eTradeMainColor,
          todayHighlightColor: eTradeMainColor,

          // view: ,
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (context) {
          return selectDateDialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      (widget.tabName == "Search")
          ? Column(
              children: [
                SlideTransition(
                    position:
                        Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                            .animate(_animationController),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      width: double.infinity,
                      child: Row(
                        children: [
                          Flexible(
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: Colors.grey, width: 1)),
                                onPressed: (() {
                                  datePickerBox();
                                }),
                                child: Text(
                                  "${prerange}",
                                  style: TextStyle(
                                      fontSize: 19,
                                      color: (MyApp.isDark)
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.normal),
                                )),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: eTradeMainColor),
                              onPressed: prerange == "Select Date"
                                  ? null
                                  : () async {
                                      _recovery =
                                          await SQLHelper.getFromToRecovery(
                                              RecoveryTabBarItem.getFromDate(),
                                              RecoveryTabBarItem.getToDate());
                                      RecoveryTabBarItem.listOfRecovery =
                                          ViewRecovery.ViewRecoveryFromDb(
                                              _recovery);
                                      setState(() {
                                        if (RecoveryTabBarItem
                                            .listOfRecovery.isNotEmpty) {
                                          RecoveryTabBarItem.listOfRecovery;
                                        } else {
                                          RecoveryTabBarItem.listOfRecovery =
                                              [];
                                        }
                                      });
                                    },
                              child: const Text('Get Date'))
                        ],
                      ),
                    )),
                const Divider(
                  color: eTradeMainColor,
                  thickness: 2,
                  height: 50,
                ),
              ],
            )
          : Padding(padding: EdgeInsets.all(10)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: TextFormField(
          keyboardType: TextInputType.name,
          controller: controller,
          onChanged: (value) {
            setState(() {
              searchString = value.toLowerCase();
            });
          },
          decoration: const InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: eTradeMainColor),
            ),
            focusedBorder: const OutlineInputBorder(
              // borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: eTradeMainColor),
            ),
            labelText: 'Search CustomerName',
            // labelStyle: const TextStyle(color: Colors.grey),
            suffixIcon: Icon(
              Icons.search,
              color: eTradeMainColor,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      (widget.tabName != "Search")
          ? Divider(
              color: eTradeMainColor,
              thickness: 2,
              height: 50,
            )
          : Container(),
      (RecoveryTabBarItem.listOfRecovery.isEmpty)
          ? Container()
          : (controller.text == "")
              ? ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext, index) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                              .animate(_animationController),
                      child: Padding(
                          padding: const EdgeInsets.all(5.0),
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
                                                          RecoveryTabBarItem
                                                                  .listOfRecovery[
                                                              index],
                                                      list: [],
                                                      partyName: "",
                                                      id: 0)));
                                    })),
                                    backgroundColor: const Color(0xFF21B7CA),
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Edit',
                                  ),
                                  SlidableAction(
                                    onPressed: (((context) async {
                                      await SQLHelper.deleteItem(
                                          "Recovery",
                                          "RecoveryID",
                                          RecoveryTabBarItem
                                              .listOfRecovery[index]
                                              .recoveryID);
                                      if (widget.tabName == "Search") {
                                        _recovery =
                                            await SQLHelper.getFromToRecovery(
                                                RecoveryTabBarItem
                                                    .getFromDate(),
                                                RecoveryTabBarItem.getToDate());
                                      } else if (widget.tabName == "Today") {
                                        String todayDate =
                                            dateFormat.format(DateTime.now());
                                        _recovery =
                                            await SQLHelper.getSpecificRecovery(
                                                todayDate);
                                      } else if (widget.tabName ==
                                          "Yesterday") {
                                        String yesterdayDate =
                                            dateFormat.format(DateTime.now()
                                                .subtract(Duration(days: 1)));
                                        _recovery =
                                            await SQLHelper.getSpecificRecovery(
                                                yesterdayDate);
                                      } else {
                                        _recovery =
                                            await SQLHelper.getAllRecovery();
                                      }
                                      RecoveryTabBarItem.listOfRecovery =
                                          ViewRecovery.ViewRecoveryFromDb(
                                              _recovery);
                                      setState(() {
                                        RecoveryTabBarItem.listOfRecovery;
                                      });
                                    })),
                                    backgroundColor: const Color(0xFFFE4A49),
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
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Recovery Id: ${RecoveryTabBarItem.listOfRecovery[index].recoveryID}",
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  "${RecoveryTabBarItem.listOfRecovery[index].party.partyName}",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    // fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
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
                                                      "${RecoveryTabBarItem.listOfRecovery[index].dated}",
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                              Radius.circular(
                                                                  5))),
                                                  child: Text(
                                                    "Rs ${RecoveryTabBarItem.listOfRecovery[index].amount}",
                                                    style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
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
                                                        color: eTradeMainColor,
                                                        // (MyApp.isDark)
                                                        // ? Colors.grey
                                                        // : Colors
                                                        //     .grey.shade300,
                                                        // border: Border.all(
                                                        //     color:
                                                        //         eTradeMainColor,
                                                        //     width: 1),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5))),
                                                    child: Text(
                                                      "Recovery Detail",
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .cardColor,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                  )))),
                      // )
                    );
                  },
                  itemCount: RecoveryTabBarItem.listOfRecovery.length,
                  shrinkWrap: true,
                  // padding: const EdgeInsets.all(2),
                  scrollDirection: Axis.vertical,
                )
              : ListOfRecovery(
                  matchItem: searchString,
                  tabName: widget.tabName,
                ),
    ]);
  }
}
