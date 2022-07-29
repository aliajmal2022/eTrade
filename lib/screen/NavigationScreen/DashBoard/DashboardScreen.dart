import 'package:eTrade/components/drawer.dart';
import 'package:eTrade/helper/sqlhelper.dart';
import 'package:eTrade/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashBoardScreen extends StatefulWidget {
  static List<DashBoard> dashBoard = [];
  static Future<List<DashBoard>> getOrderHistory() async {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
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
      dashBoard = [
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
    return dashBoard;
  }

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  // List<SalesData> saledata = [
  //   SalesData(months: "Jan", sales: 35),
  //   SalesData(months: "Feb", sales: 28),
  //   SalesData(months: "Mar", sales: 34),
  //   SalesData(months: "Apr", sales: 32),
  //   SalesData(months: "May", sales: 40),
  //   SalesData(months: "May", sales: 40),
  //   SalesData(months: "Jun", sales: 40),
  //   SalesData(months: "Jul", sales: 40),
  //   SalesData(months: "Aug", sales: 40),
  //   SalesData(months: "Sep", sales: 40),
  //   SalesData(months: "Oct", sales: 40),
  //   SalesData(months: "Nov", sales: 40),
  //   SalesData(months: "Dec", sales: 40),
  // ];
  List<SalesData> saledata = [
    SalesData(months: 1, sales: 35),
    SalesData(months: 2, sales: 28),
    SalesData(months: 3, sales: 34),
    SalesData(months: 4, sales: 32),
    SalesData(months: 5, sales: 40)
  ];
  List<Items> itemdata = [
    Items(name: "Hoor Oil", ordered: 40),
    Items(name: "Surf Excel", ordered: 35),
    Items(name: "Dalda Ghee", ordered: 64),
    Items(name: "Lemon Max Bar", ordered: 85),
    Items(name: "Soap Palmolive", ordered: 12),
    Items(name: "Lux", ordered: 23),
    Items(name: "Dove", ordered: 78),
    Items(name: "SunSlik", ordered: 55),
    Items(name: "Clear Shampoo", ordered: 42),
    Items(name: "Mardan Surf", ordered: 50),
  ];
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);
  @override
  void initState() {
    // getOrderHistory();
    super.initState();
  }

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
                  "Salesman History",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: SfCartesianChart(series: <ChartSeries<SalesData, int>>[
                  // Renders column chart
                  ColumnSeries<SalesData, int>(
                      dataSource: saledata,
                      width: 0.3,
                      color: Color(0xff00620b),
                      xValueMapper: (SalesData data, _) => data.months,
                      yValueMapper: (SalesData data, _) => data.sales)
                ]),
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
              SfCircularChart(
                tooltipBehavior: _tooltipBehavior,
                series: [
                  // Renders column chart

                  PieSeries<Items, String>(
                      explode: true,
                      dataSource: itemdata,
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                      xValueMapper: (Items data, _) => data.name,
                      yValueMapper: (Items data, _) => data.ordered)
                ],
                legend: Legend(
                    // isResponsive: true,
                    isVisible: true,
                    overflowMode: LegendItemOverflowMode.wrap),
              ),
            ],
          ),
        ));
  }
}

class Items {
  Items({required this.name, required this.ordered});

  String name;
  int ordered;
}

class SalesData {
  SalesData({required this.months, required this.sales});

  int months;
  double sales;
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
