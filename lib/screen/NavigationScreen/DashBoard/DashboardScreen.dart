import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:eTrade/entities/Sale.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get_navigation/src/routes/default_transitions.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashBoardScreen extends StatefulWidget {
  static List<DashBoard> dashBoard = [];
  static Future<List<DashBoard>> getOrderHistory() async {
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
      today = await SQLHelper.getOrderCount("Today", exactDate);
      yesterday = await SQLHelper.getOrderCount("Yesterday", yesterdayDate);
      week = await SQLHelper.getOrderCount("Week", exactDate);
      lastWeek = await SQLHelper.getOrderCount("PWeek", exactDate);
      month = await SQLHelper.getOrderCount("Month", exactDate);
      lastMonth = await SQLHelper.getOrderCount("PMonth", exactDate);
      year = await SQLHelper.getOrderCount("Year", exactDate);
      lastYear = await SQLHelper.getOrderCount("PYear", exactDate);
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
    greatestTarget = 100000;
    var months = await SQLHelper.instance.getTable("UserTarget", "ID");
    List<MonthOrderHistory> list = [];
    for (count = 0; count < staticMonthName.length; count++) {
      staticMonths = [];
      MonthOrderHistory orderStatic = MonthOrderHistory(month: "", amount: 0);
      orderStatic.amount = months[0][staticMonthName[count]].toDouble();
      if (months[0][staticMonthName[count]] > greatestTarget) {
        greatestTarget = orderStatic.amount.toInt();
      }
      orderStatic.month = (count + 1).toString();
      list.add(orderStatic);
    }
    return list;
  }

  static Future<List<Items>> getTopProduct() async {
    List<Items> list = [];
    var products = await SQLHelper.getTopTenProductByAmount();
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
  bool isOrder = true;
  updateData() async {
    DashBoardScreen.dashBoard = await DashBoardScreen.getOrderHistory();
    DashBoardScreen.itemdata = await DashBoardScreen.getTopProduct();
    DashBoardScreen.monthlyList =
        await DashBoardScreen.getMonthlyRecordDB(isOrder);
    DashBoardScreen.staticMonths =
        await DashBoardScreen.getMonthlyTargetDB(isOrder);
    setState(() {
      DashBoardScreen.itemdata;
      DashBoardScreen.dashBoard;
      DashBoardScreen.monthlyList;
      DashBoardScreen.staticMonths;
    });
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
          backgroundColor: eTradeGreen,
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
                      isOrder ? "Order" : "Sale",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  Switch(
                    activeColor: eTradeGreen,
                    value: isOrder,
                    onChanged: (value) async {
                      setState(() {
                        isOrder = value;
                      });
                      DashBoardScreen.monthlyList =
                          await DashBoardScreen.getMonthlyRecordDB(isOrder);
                      DashBoardScreen.staticMonths =
                          await DashBoardScreen.getMonthlyTargetDB(isOrder);
                      setState(() {
                        DashBoardScreen.monthlyList;
                        DashBoardScreen.staticMonths;
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
                          color: Color(0xff00174b),
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
                          color: eTradeGreen,
                          spacing: 0.1,
                          xValueMapper: (MonthOrderHistory sales, _) =>
                              sales.month,
                          yValueMapper: (MonthOrderHistory sales, _) =>
                              sales.amount),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: eTradeGreen,
                  thickness: 2,
                  height: 50,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Order History",
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
                      child: Container(
                        height: 90,
                        // width: double.infinity,
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                // color: eTradeGreen,
                                // color: Colors.white,
                                color: Theme.of(context).dividerColor,
                                blurRadius: 1.0,
                              ),
                            ],
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_calendar,
                                    size: 40,
                                    color: (DashBoardScreen
                                                .dashBoard[index].order >
                                            DashBoardScreen
                                                .dashBoard[index].compareOrder)
                                        ? eTradeGreen
                                        : (DashBoardScreen
                                                    .dashBoard[index].order ==
                                                DashBoardScreen.dashBoard[index]
                                                    .compareOrder)
                                            ? eTradeBlue
                                            : eTradeRed,
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
                                          "Orders:",
                                          // style: TextStyle(
                                          //     color: Colors.white),
                                        ),
                                        Text(
                                          "${DashBoardScreen.dashBoard[index].order}",
                                          // style: TextStyle(
                                          //     color: Colors.white),
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
                                          // style: TextStyle(
                                          //     color: Colors.white),
                                        ),
                                        Text(
                                          "${DashBoardScreen.dashBoard[index].compareOrder}",
                                          // style: TextStyle(
                                          //     color: Colors.white),
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
                                      (DashBoardScreen.dashBoard[index].order >
                                              DashBoardScreen.dashBoard[index]
                                                  .compareOrder)
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      size: 30,
                                      color: (DashBoardScreen
                                                  .dashBoard[index].order >
                                              DashBoardScreen.dashBoard[index]
                                                  .compareOrder)
                                          ? eTradeGreen
                                          : (DashBoardScreen
                                                      .dashBoard[index].order ==
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
                    );
                  }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: eTradeGreen,
                  thickness: 2,
                  height: 50,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Top 10 Ordered Products",
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
                        xValueMapper: (Items? data, _) =>
                            data?.productName ?? null,
                        yValueMapper: (Items? data, _) => data?.ordered ?? null)
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
                      position: LegendPosition.bottom,
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
