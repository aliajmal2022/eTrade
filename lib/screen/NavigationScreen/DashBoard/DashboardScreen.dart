import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:eTrade/entities/Sale.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get_navigation/src/routes/default_transitions.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashBoardScreen extends StatefulWidget {
  static List<DashBoard> dashBoard = [];
  static bool isOrder = true;
  static Future<List<DashBoard>> getOrderHistory(isOrder) async {
    List<DashBoard> list = [];
    DateFormat dateFormat = DateFormat("dd-MM-yyyy");
    String exactDate = dateFormat.format(DateTime.now());
    String yesterdayDate =
        dateFormat.format(DateTime.now().subtract(Duration(days: 1)));
    int yesterday = 0;
    int week = 0;
    int lastWeek = 0;
    int month = 0;
    int lastMonth = 0;
    int year = 0;
    int lastYear = 0;
    int today = 0;
    try {
      if (isOrder) {
        today = await SQLHelper.getOrderCount("Today", exactDate);
        yesterday = await SQLHelper.getOrderCount("Yesterday", yesterdayDate);
        week = await SQLHelper.getOrderCount("Week", exactDate);
        lastWeek = await SQLHelper.getOrderCount("PWeek", exactDate);
        month = await SQLHelper.getOrderCount("Month", exactDate);
        lastMonth = await SQLHelper.getOrderCount("PMonth", exactDate);
        year = await SQLHelper.getOrderCount("Year", exactDate);
        lastYear = await SQLHelper.getOrderCount("PYear", exactDate);
      } else {
        today = await SQLHelper.getSaleCount("Today", exactDate);
        yesterday = await SQLHelper.getSaleCount("Yesterday", yesterdayDate);
        week = await SQLHelper.getSaleCount("Week", exactDate);
        lastWeek = await SQLHelper.getSaleCount("PWeek", exactDate);
        month = await SQLHelper.getSaleCount("Month", exactDate);
        lastMonth = await SQLHelper.getSaleCount("PMonth", exactDate);
        year = await SQLHelper.getSaleCount("Year", exactDate);
        lastYear = await SQLHelper.getSaleCount("PYear", exactDate);
      }
      list = [
        DashBoard(
            compareOrder: yesterday,
            compareTime: "Yesterday",
            order: today,
            time: "Today"),
        DashBoard(
            compareOrder: lastWeek,
            compareTime: "Last Week",
            order: week,
            time: "Week"),
        DashBoard(
            compareOrder: lastMonth,
            compareTime: "Last Month",
            order: month,
            time: "Month"),
        DashBoard(
            compareOrder: lastYear,
            compareTime: "Last Year",
            order: year,
            time: "Year"),
      ];
    } catch (e) {
      debugPrint("$e");
    }
    return list;
  }

  static List<MonthOrderHistory> monthlyList = [];
  static List<Items> itemdata = [];
  static List<String> monthName = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  static List<MonthOrderHistory> staticMonths = [];
  static Future<List<MonthOrderHistory>> getMonthlyRecordDB(isOrder) async {
    List<MonthOrderHistory> list = [];
    var months = isOrder
        ? await SQLHelper.getMonthOrderHistory()
        : await SQLHelper.getMonthSaleHistory();
    int count = 1;
    for (count = 0; count < monthName.length; count++) {
      MonthOrderHistory orderData = MonthOrderHistory(month: "", amount: 0);
      // orderData.month = element;
      orderData.amount = months[0][monthName[count]].toDouble();
      orderData.month = (count + 1).toString();
      list.add(orderData);
    }
    return list;
  }

  static int greatestTarget = 10000;
  static Future<List<MonthOrderHistory>> getMonthlyTargetDB(isOrder) async {
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
    List<MonthOrderHistory> list = [];
    greatestTarget = 100000;
    List<Map<String, dynamic>> months =
        await SQLHelper.instance.getTable("UserTarget", "ID");
    try {
      if (months.isEmpty) {
        for (count = 0; count < staticMonthName.length; count++) {
          MonthOrderHistory orderStatic =
              MonthOrderHistory(month: "", amount: 0);
          orderStatic.amount = 0;

          orderStatic.month = (count + 1).toString();
          list.add(orderStatic);
        }
      } else {
        for (count = 0; count < staticMonthName.length; count++) {
          MonthOrderHistory orderStatic =
              MonthOrderHistory(month: "", amount: 0);
          orderStatic.amount =
              months[0][staticMonthName[count]]!.toDouble() ?? 100000;
          if (months[0][staticMonthName[count]] > greatestTarget) {
            greatestTarget = orderStatic.amount.toInt();
          }

          orderStatic.month = (count + 1).toString();
          list.add(orderStatic);
        }
      }
    } catch (e) {
      print("Error ::::::::::  ${e.toString()}");
    }
    return list;
  }

  static Future<List<Items>> getTopProduct(isOrder) async {
    List<Items> list = [];

    var products = isOrder
        ? await SQLHelper.getTopTenProductByOrder()
        : await SQLHelper.getTopTenProductBySale();
    if (products.isNotEmpty) {
      var formatter = NumberFormat('#,###,000');
      for (var element in products) {
        Items item = Items(productName: "", amount: "", ordered: 40);
        item.productName = element['ItemName'];
        item.amount = formatter.format(element['Amount'].toInt());
        item.ordered = element['Quantity'];
        list.add(item);
      }
    } else {
      list.add(Items(productName: "Nothing Order", amount: "", ordered: 1));
    }
    return list;
  }

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with TickerProviderStateMixin {
  updateData() async {
    await DashBoardScreen.getMonthlyTargetDB(DashBoardScreen.isOrder);
    DashBoardScreen.dashBoard =
        await DashBoardScreen.getOrderHistory(DashBoardScreen.isOrder);
    DashBoardScreen.itemdata =
        await DashBoardScreen.getTopProduct(DashBoardScreen.isOrder);
    DashBoardScreen.monthlyList =
        await DashBoardScreen.getMonthlyRecordDB(DashBoardScreen.isOrder);
    DashBoardScreen.staticMonths =
        await DashBoardScreen.getMonthlyTargetDB(DashBoardScreen.isOrder);

    setState(() {
      DashBoardScreen.itemdata;
      DashBoardScreen.dashBoard;
      DashBoardScreen.monthlyList;
      DashBoardScreen.staticMonths;
    });
  }

  void getWorkingDaysInMonth() {
    DateTime now = new DateTime.now();
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    int count = 0;
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      var day = DateFormat('EEEE').format(lastDayOfMonth);
      if (day != "Friday") {
        count++;
      }
    }
// print("${lastDayOfMonth.day}");
    print("${count}");
  }

  var _animationController;
  @override
  void initState() {
    setState(() {
      _animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 100));
      _animationController.forward();
      updateData();
    });
    super.initState();
  }

  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);
  TooltipBehavior _columntooltipBehavior = TooltipBehavior(enable: true);
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: eTradeMainColor,
          toolbarHeight: 80,
          shape: const RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(
                  Icons.menu,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          title: const Text(
            'Home',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        drawer: MyDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      DashBoardScreen.isOrder ? "Order" : "Sale",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  Switch(
                    activeColor: eTradeMainColor,
                    value: DashBoardScreen.isOrder,
                    onChanged: (value) async {
                      setState(() {
                        DashBoardScreen.isOrder = value;
                      });
                      DashBoardScreen.dashBoard =
                          await DashBoardScreen.getOrderHistory(
                              DashBoardScreen.isOrder);
                      DashBoardScreen.itemdata =
                          await DashBoardScreen.getTopProduct(
                              DashBoardScreen.isOrder);
                      DashBoardScreen.monthlyList =
                          await DashBoardScreen.getMonthlyRecordDB(
                              DashBoardScreen.isOrder);
                      DashBoardScreen.staticMonths =
                          await DashBoardScreen.getMonthlyTargetDB(
                              DashBoardScreen.isOrder);
                      setState(() {
                        DashBoardScreen.monthlyList;
                        DashBoardScreen.staticMonths;
                        DashBoardScreen.itemdata;
                        DashBoardScreen.dashBoard;
                      });
                    },
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  height: 300,
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: SfCartesianChart(
                    // Initialize category axis

                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(text: "Months"),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(text: "Value"),
                      minimum: 0,
                      maximum: DashBoardScreen.greatestTarget.toDouble(),
                    ),
                    // ),
                    tooltipBehavior: _columntooltipBehavior,
                    margin: EdgeInsets.all(0),

                    series: <ColumnSeries<MonthOrderHistory, String>>[
                      ColumnSeries<MonthOrderHistory, String>(
                          // Bind data source
                          dataSource: DashBoardScreen.staticMonths,
                          name: "Target",
                          color: Colors.red,
                          // color: Color(0xff00174b),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15)),
                          xValueMapper: (MonthOrderHistory sales, _) =>
                              sales.month,
                          yValueMapper: (MonthOrderHistory sales, _) =>
                              sales.amount),
                      ColumnSeries<MonthOrderHistory, String>(
                          // Bind data source
                          dataSource: DashBoardScreen.monthlyList,
                          name: "Achievement",
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15)),
                          color: Colors.green,
                          spacing: 0.1,
                          xValueMapper: (MonthOrderHistory sales, _) =>
                              sales.month,
                          yValueMapper: (MonthOrderHistory sales, _) =>
                              sales.amount),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "• ",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: eTradeMainColor),
                  ),
                  Text(
                    "Time gone : 45%",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: eTradeMainColor,
                  thickness: 2,
                  height: 50,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  DashBoardScreen.isOrder ? "Order History" : "Sale History",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: DashBoardScreen.dashBoard.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        elevation: 5,
                        child: Container(
                          height: 90,
                          // width: double.infinity,
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (DashBoardScreen.dashBoard[index].order >
                                              DashBoardScreen.dashBoard[index]
                                                  .compareOrder)
                                          ? eTradeMainColor
                                          : (DashBoardScreen
                                                      .dashBoard[index].order ==
                                                  DashBoardScreen
                                                      .dashBoard[index]
                                                      .compareOrder)
                                              ? eTradeBlue
                                              : eTradeRed,
                                  // color: eTradeMainColor,
                                  // color: Theme.of(context).dividerColor,
                                  blurRadius: 1.0,
                                ),
                              ],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.edit_calendar,
                                      size: 40,
                                      // color: (DashBoardScreen
                                      //             .dashBoard[index].order >
                                      //         DashBoardScreen
                                      //             .dashBoard[index].compareOrder)
                                      //     ? eTradeMainColor
                                      //     : (DashBoardScreen
                                      //                 .dashBoard[index].order ==
                                      //             DashBoardScreen.dashBoard[index]
                                      //                 .compareOrder)
                                      //         ? eTradeBlue
                                      //         : eTradeRed,
                                    ),
                                    Text(
                                      "${DashBoardScreen.dashBoard[index].time}",
                                      style: TextStyle(
                                          // color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: VerticalDivider(
                                    thickness: 2,
                                    width: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DashBoardScreen.isOrder
                                                ? "Order "
                                                : "Sale ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "${DashBoardScreen.dashBoard[index].order}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${DashBoardScreen.dashBoard[index].compareTime}:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "${DashBoardScreen.dashBoard[index].compareOrder}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: VerticalDivider(
                                    thickness: 2,
                                    width: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              (DashBoardScreen.dashBoard[index].order !=
                                      DashBoardScreen
                                          .dashBoard[index].compareOrder)
                                  ? Expanded(
                                      flex: 2,
                                      child: Icon(
                                        (DashBoardScreen
                                                    .dashBoard[index].order >
                                                DashBoardScreen.dashBoard[index]
                                                    .compareOrder)
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        size: 30,
                                        color: (DashBoardScreen
                                                    .dashBoard[index].order >
                                                DashBoardScreen.dashBoard[index]
                                                    .compareOrder)
                                            ? eTradeMainColor
                                            : (DashBoardScreen.dashBoard[index]
                                                        .order ==
                                                    DashBoardScreen
                                                        .dashBoard[index]
                                                        .compareOrder)
                                                ? eTradeBlue
                                                : eTradeRed,
                                      ))
                                  : Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.arrow_upward,
                                            size: 25,
                                          ),
                                          Icon(
                                            Icons.arrow_downward,
                                            size: 25,
                                          ),
                                        ],
                                      )),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: eTradeMainColor,
                  thickness: 2,
                  height: 50,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  DashBoardScreen.isOrder
                      ? "Top 10 Ordered Products"
                      : "Top 10 Sell Products",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Container(
                height: 300,
                width: double.infinity,
                child: SfCircularChart(
                  tooltipBehavior: _tooltipBehavior,
                  series: [
                    // Renders column chart

                    PieSeries<Items, String>(
                        explode: true,
                        strokeWidth: 500,
                        dataSource: DashBoardScreen.itemdata,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                        xValueMapper: (Items? data, _) => data?.productName,
                        yValueMapper: (Items? data, _) => data?.ordered)
                  ],
                  legend: Legend(
                      // isResponsive: true,
                      legendItemBuilder:
                          ((legendText, series, point, seriesIndex) {
                        return Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            "${DashBoardScreen.itemdata[seriesIndex].ordered} - $legendText  (${DashBoardScreen.itemdata[seriesIndex].amount})",
                          ),
                        );
                      }),
                      isVisible: true,
                      position: LegendPosition.top,
                      overflowMode: LegendItemOverflowMode.wrap),
                ),
              ),
            ],
          ),
        ));
  }
}

class Items {
  Items(
      {required this.productName, required this.amount, required this.ordered});

  String productName;

  String amount;
  int ordered;
}

class MonthOrderHistory {
  MonthOrderHistory({required this.month, required this.amount});

  String month;
  double amount;
}

class DashBoard {
  String time;
  String compareTime;
  int order;
  int compareOrder;
  DashBoard(
      {required this.compareOrder,
      required this.compareTime,
      required this.order,
      required this.time});
}
