import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/entities/Products.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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

  static List<charts.Series<MonthOrderHistory, String>> series = [];
  static List<MonthOrderHistory> monthlyOrderList = [];
  static List<Items> itemdata = [];
  static List<String> monthName = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
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
  static Future<List<MonthOrderHistory>> getMonthlyRecorderDB() async {
    List<MonthOrderHistory> list = [];
    staticMonths = [];
    var months = await SQLHelper.getMonthOrderHistory();
    int count = 1;
    for (count = 1; count <= monthName.length - 1; count++) {
      MonthOrderHistory orderData = MonthOrderHistory(month: "", amount: 0);
      MonthOrderHistory orderStatic = MonthOrderHistory(month: "", amount: 0);
      double number = 100000;
      // orderData.month = element;
      orderData.amount = months[0][monthName[count]].toDouble();
      orderData.month = count.toString();
      list.add(orderData);
      orderStatic.amount = number;
      orderStatic.month = count.toString();
      // orderStatic.month = element;
      staticMonths.add(orderStatic);
    }
    return list;
  }

  static Future<List<Items>> getTopProduct() async {
    List<Items> list = [];
    var products = await SQLHelper.getTopTenProductByAmount();
    if (products.isNotEmpty) {
      for (var element in products) {
        Items item = Items(productName: "", amount: 0, ordered: 40);
        item.productName = element['ItemName'];
        item.amount = element['Amount'];
        item.ordered = element['Quantity'];
        list.add(item);
      }
    } else {
      list.add(Items(productName: "Nothing Order", amount: 0, ordered: 1));
    }
    return list;
  }

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  updateData() async {
    DashBoardScreen.dashBoard = await DashBoardScreen.getOrderHistory();
    DashBoardScreen.itemdata = await DashBoardScreen.getTopProduct();
    DashBoardScreen.monthlyOrderList =
        await DashBoardScreen.getMonthlyRecorderDB();
    setState(() {
      DashBoardScreen.itemdata;
      DashBoardScreen.dashBoard;
      DashBoardScreen.monthlyOrderList;
      DashBoardScreen.series = [
        charts.Series(
          id: "set",
          data: DashBoardScreen.staticMonths,
          domainFn: (MonthOrderHistory series, _) => series.month,
          measureFn: (MonthOrderHistory series, _) => series.amount,
          colorFn: (_, __) =>
              // MyApp.isDark
              //     ? charts.MaterialPalette.red.shadDe
              // :
              charts.MaterialPalette.red.shadeDefault,
        ),
        charts.Series(
          id: "Query",
          data: DashBoardScreen.monthlyOrderList,
          domainFn: (MonthOrderHistory series, _) => series.month,
          measureFn: (MonthOrderHistory series, _) => series.amount,
          colorFn: (_, __) =>
              // MyApp.isDark
              //     ? charts.MaterialPalette.gray.shade800
              //     :
              charts.MaterialPalette.green.shadeDefault,
        ),
      ];
    });
  }

  @override
  void initState() {
    setState(() {
      updateData();
    });
    super.initState();
  }

  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF00620b),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Order History",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 2.0,
                children:
                    List.generate(DashBoardScreen.dashBoard.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                          color:
                              (MyApp.isDark) ? Color(0xff424242) : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              // color: Color(0xff00620b),
                              offset: Offset(0.0, 0.5), //(x,y)
                              blurRadius: 4.0,
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                              child: Text(
                            DashBoardScreen.dashBoard[index].time,
                            style: TextStyle(
                                color: (MyApp.isDark)
                                    ? Colors.white
                                    : Color(0xff00620b),
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          )),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 8.0, right: 8.0, bottom: 8.0),
                            child: Divider(
                              thickness: 2,
                              height: 10,
                              color: (MyApp.isDark)
                                  ? Color(0xff00620b)
                                  : Colors.black,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (DashBoardScreen.dashBoard[index].order !=
                                      DashBoardScreen
                                          .dashBoard[index].compareOrder)
                                  ? Flexible(
                                      flex: 1,
                                      child: Icon(
                                        (DashBoardScreen
                                                    .dashBoard[index].order >
                                                DashBoardScreen.dashBoard[index]
                                                    .compareOrder)
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        size: 50,
                                        color: (DashBoardScreen
                                                    .dashBoard[index].order >
                                                DashBoardScreen.dashBoard[index]
                                                    .compareOrder)
                                            ? Colors.green
                                            : (DashBoardScreen.dashBoard[index]
                                                        .order ==
                                                    DashBoardScreen
                                                        .dashBoard[index]
                                                        .compareOrder)
                                                ? Color(0xff00620b)
                                                : Colors.red,
                                      ))
                                  : Flexible(
                                      flex: 1,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                              Flexible(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Orders:"),
                                          Text(
                                              "${DashBoardScreen.dashBoard[index].order}"),
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
                                              "${DashBoardScreen.dashBoard[index].compareTime}:"),
                                          Text(
                                              "${DashBoardScreen.dashBoard[index].compareOrder}"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Color(0xff00620b),
                  thickness: 2,
                  height: 50,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Sales History",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  height: 300,
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: charts.BarChart(
                    DashBoardScreen.series,
                    barGroupingType: charts.BarGroupingType.grouped,
                    animate: true,
                    // vertical: false,
                    defaultRenderer: new charts.BarRendererConfig(
                        // By default, bar renderer will draw rounded bars with a constant
                        // radius of 100.
                        // To not have any rounded corners, use [NoCornerStrategy]
                        // To change the radius of the bars, use [ConstCornerStrategy]
                        cornerStrategy: const charts.ConstCornerStrategy(30)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Color(0xff00620b),
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
                        xValueMapper: (Items data, _) => data.productName,
                        yValueMapper: (Items data, _) => data.ordered)
                  ],
                  legend: Legend(
                      // isResponsive: true,
                      legendItemBuilder:
                          ((legendText, series, point, seriesIndex) {
                        return Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            "${DashBoardScreen.itemdata[seriesIndex].ordered} - $legendText  (${DashBoardScreen.itemdata[seriesIndex].amount.toInt()})",
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

  double amount;
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
