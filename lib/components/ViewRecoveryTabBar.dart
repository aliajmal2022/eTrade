import 'dart:math';

import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/SearchListOrder.dart';
import 'package:eTrade/components/SearchListRecovery.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/components/sqlhelper.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/Edit.dart';
import 'package:eTrade/entities/Recovery.dart';
import 'package:eTrade/entities/ViewBooking.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/main.dart';
import 'package:eTrade/screen/TakeOrderScreen.dart';
import 'package:eTrade/screen/RecoveryScreen.dart';
import 'package:eTrade/screen/OrderDetailScreen.dart';
import 'package:eTrade/screen/RecoveryDetailScreen.dart';
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

class _RecoveryTabBarItemState extends State<RecoveryTabBarItem> {
  String range = 'Select Date';
  String searchString = "";
  TextEditingController controller = TextEditingController();
  String prerange = 'Select Date';
  var _recovery;
  void initState() {
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

  DateFormat dateFormat = DateFormat('dd/MM/yyyy');
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
      range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)}-'
          '${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
    }
  }

  void datePickerBox() {
    Widget cancelButton = TextButton(
        onPressed: (() {
          Navigator.pop(context);
        }),
        child: const Text(
          "Cancel",
          style: TextStyle(color: Color(0xff00620b)),
        ));
    Widget selectedButton = TextButton(
        onPressed: (() {
          setState(() {
            prerange = range;
            var splitDate = prerange.split('-');
            RecoveryTabBarItem.setFromDate(splitDate[0]);
            RecoveryTabBarItem.setToDate(splitDate[1]);
          });
          Navigator.pop(context);
        }),
        child:
            const Text("Select", style: TextStyle(color: Color(0xff00620b))));
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
          startRangeSelectionColor: Color(0xff00620b),
          endRangeSelectionColor: Color(0xff00620b),
          todayHighlightColor: Color(0xff00620b),

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
                Container(
                  padding: const EdgeInsets.all(20.0),
                  width: double.infinity,
                  child: Row(
                    children: [
                      Flexible(
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey, width: 1)),
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
                              primary: Color(0xff00620b)),
                          onPressed: prerange == "Select Date"
                              ? null
                              : () async {
                                  _recovery = await SQLHelper.getFromToRecovery(
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
                                      RecoveryTabBarItem.listOfRecovery = [];
                                    }
                                  });
                                },
                          child: const Text('Get Date'))
                    ],
                  ),
                ),
                const Divider(
                  color: Color(0xff00620b),
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
              borderSide: const BorderSide(color: Color(0xff00620b)),
            ),
            focusedBorder: const OutlineInputBorder(
              // borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xff00620b)),
            ),
            labelText: 'Search CustomerName',
            // labelStyle: const TextStyle(color: Colors.grey),
            suffixIcon: Icon(
              Icons.search,
              color: Color(0xff00620b),
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      (widget.tabName != "Search")
          ? Divider(
              color: Color(0xff00620b),
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
                    return Slidable(
                        key: const ValueKey(0),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SlidableAction(
                                  onPressed: (((context) async {
                                    RecoveryScreen.isEditRecovery = true;
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
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
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SlidableAction(
                                  onPressed: (((context) async {
                                    await SQLHelper.deleteItem(
                                        "Recovery",
                                        "RecoveryID",
                                        RecoveryTabBarItem
                                            .listOfRecovery[index].recoveryID);
                                    if (widget.tabName == "Search") {
                                      _recovery =
                                          await SQLHelper.getFromToRecovery(
                                              RecoveryTabBarItem.getFromDate(),
                                              RecoveryTabBarItem.getToDate());
                                    } else if (widget.tabName == "Today") {
                                      String todayDate =
                                          dateFormat.format(DateTime.now());
                                      _recovery =
                                          await SQLHelper.getSpecificRecovery(
                                              todayDate);
                                    } else if (widget.tabName == "Yesterday") {
                                      String yesterdayDate = dateFormat.format(
                                          DateTime.now()
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
                              ),
                            ),
                          ],
                        ),
                        child: Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Container(
                                height: 110,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: (MyApp.isDark)
                                        ? Color(0xff424242)
                                        : Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(0.0, 0.5), //(x,y)
                                        blurRadius: 3.0,
                                      ),
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "RecoveryID: #${RecoveryTabBarItem.listOfRecovery[index].recoveryID}",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          Text(
                                            " ${RecoveryTabBarItem.listOfRecovery[index].party.partyName}",
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
                                                      fontWeight:
                                                          FontWeight.bold)),
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
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                color: Color(0xff00620b),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5))),
                                            child: Text(
                                              "Rs ${RecoveryTabBarItem.listOfRecovery[index].amount}",
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.white),
                                            ),
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
                                                  color: (MyApp.isDark)
                                                      ? Colors.grey
                                                      : Colors.grey.shade300,
                                                  // border: Border.all(
                                                  //     color:
                                                  //         Color(0xff00620b),
                                                  //     width: 1),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5))),
                                              child: Text(
                                                "Recovery Detail",
                                                style: TextStyle(
                                                    color: Color(0xff00620b),
                                                    // fontStyle: FontStyle.italic,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ))));
                  },
                  itemCount: RecoveryTabBarItem.listOfRecovery.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(5),
                  scrollDirection: Axis.vertical,
                )
              : ListOfRecovery(
                  matchItem: searchString,
                  tabName: widget.tabName,
                ),
    ]);
  }
}
