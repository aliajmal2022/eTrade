import 'package:eTrade/components/CustomNavigator.dart';
import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/helper/onldt_to_local_db.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/searchCustomerBalance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CustomerBalanceScreen extends StatefulWidget {
  static bool isCustomerBalance = false;
  static bool isCompleteLoading = false;
  @override
  State<CustomerBalanceScreen> createState() => _CustomerBalanceScreenState();
}

class _CustomerBalanceScreenState extends State<CustomerBalanceScreen> {
  TextEditingController controller = TextEditingController();
  String searchString = "";
  static var formatter = NumberFormat('#,###,000');
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() async => false),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: Theme.of(context).cardColor,
              toolbarHeight: 180,
              title: Column(children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.off(() => MyNavigationBar.initializer(0),
                            transition: Transition.leftToRight,
                            duration: Duration(milliseconds: 500));
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: eTradeMainColor,
                      ),
                    ),
                    // Expanded(child: Text('Customer Balance')),
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: TextField(
                            controller: controller,
                            onChanged: (value) {
                              setState(() {
                                searchString = value.toLowerCase();
                              });
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 13, horizontal: 20),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: eTradeMainColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                // borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: eTradeMainColor),
                              ),
                              labelText: 'Search Customer',
                              // labelStyle: TextStyle(color: eTradeMainColor),
                              suffixIcon: Icon(
                                Icons.search,
                                // color:
                                //  eTradeMainColor,
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                'Customer Name ',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: eTradeMainColor),
                              )),
                          Expanded(
                              flex: 1,
                              child: Center(
                                  child: Text('Balance',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: eTradeMainColor)))),
                          Expanded(flex: 1, child: Center(child: Text(''))),
                        ],
                      ),
                    ),
                    Divider(
                      color: eTradeMainColor,
                      thickness: 1.5,
                      height: 10,
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ])),
          body:

              // Column(children: [
              // Padding(
              //    padding: const EdgeInsets.all(12.0),
              //   child: Row(
              //     children: [
              //       Expanded(
              //           flex: 2,
              //           child: Text(
              //             'Customer Name ',
              //             style: TextStyle(
              //                 fontSize: 15,
              //                 fontWeight: FontWeight.bold,
              //                 color: eTradeMainColor),
              //           )),
              //       Expanded(
              //           flex: 1,
              //           child: Center(
              //               child: Text('Balance',
              //                   style: TextStyle(
              //                       fontSize: 15,
              //                       fontWeight: FontWeight.bold,
              //                       color: eTradeMainColor)))),
              //       Expanded(flex: 1, child: Center(child: Text(''))),
              //     ],
              //   ),
              // ),
              // Divider(
              //   color: eTradeMainColor,
              //   thickness: 1.5,
              //   height: 10,
              // ),
              searchString == ""
                  ? Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ListOfCustomerBalance(
                          scrollController: scrollController,
                          formatter: formatter))
                  : searchCustomerBalance(searchString, context),
          //       ],
          //     ),
          // ]),
        ),
      ),
    );
  }
}

class ListOfCustomerBalance extends StatelessWidget {
  const ListOfCustomerBalance({
    Key? key,
    required this.scrollController,
    required this.formatter,
  }) : super(key: key);

  final ScrollController scrollController;
  final NumberFormat formatter;

  onloading(context) {
    return ListView.builder(
      controller: scrollController,
      itemBuilder: (BuildContext, index) {
        return Padding(
          padding: EdgeInsets.zero,
          child: Card(
            elevation: 2,
            color: Theme.of(context).cardColor,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DataBaseDataLoad.ListOCustomer[index].partyName,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          "${DataBaseDataLoad.ListOCustomer[index].address}",
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                          "${DataBaseDataLoad.ListOCustomer[index].balance.toInt() < 999 ? DataBaseDataLoad.ListOCustomer[index].balance.toInt() : formatter.format(DataBaseDataLoad.ListOCustomer[index].balance.toInt())}"),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        CustomerBalanceScreen.isCustomerBalance = true;
                        Navigator.pushAndRemoveUntil(
                            context,
                            MyCustomRoute(
                                builder: (context) => MyNavigationBar(
                                    selectedIndex: 3,
                                    list: [],
                                    id: 0,
                                    date: "",
                                    editRecovery: ViewRecovery(
                                        party: DataBaseDataLoad
                                            .ListOCustomer[index],
                                        amount: DataBaseDataLoad
                                            .ListOCustomer[index].balance,
                                        dated: "",
                                        description: "",
                                        recoveryID: 0,
                                        checkOrCash: false),
                                    partyName: ""),
                                slide: "Left"),
                            (route) => false);
                      },
                      child: Text('Receive'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      itemCount: DataBaseDataLoad.ListOCustomer.length,
      // itemCount: 10,
      shrinkWrap: true,
      padding: EdgeInsets.all(5),
      scrollDirection: Axis.vertical,
    );
  }

  @override
  Widget build(BuildContext context) {
    return onloading(context);
  }
}
