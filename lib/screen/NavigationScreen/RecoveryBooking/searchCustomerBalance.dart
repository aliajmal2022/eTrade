import 'package:eTrade/components/CustomNavigator.dart';
import 'package:eTrade/components/NavigationBar.dart';
import 'package:eTrade/components/constants.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/entities/ViewRecovery.dart';
import 'package:eTrade/helper/onldt_to_local_db.dart';
import 'package:eTrade/screen/NavigationScreen/RecoveryBooking/CustomerBalance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

searchCustomerBalance(String search, BuildContext context) {
  List<Customer> dummyCustomerList = [];
  dummyCustomerList.clear();
  for (var element in DataBaseDataLoad.ListOCustomer) {
    if (element.partyName.toLowerCase().contains(search)) {
      dummyCustomerList.add(element);
    }
  }
  return (dummyCustomerList.isEmpty)
      ? Center(child: Text("Not Found"))
      : ListView.builder(
          // controller: _controller,
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
                                dummyCustomerList[index].partyName,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                "${dummyCustomerList[index].address}",
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
                                "${dummyCustomerList[index].balance.toInt() < 999 ? dummyCustomerList[index].balance.toInt() : formatter.format(dummyCustomerList[index].balance.toInt())}"),
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
                ));
          },
          itemCount: dummyCustomerList.length,
          shrinkWrap: true,
          padding: EdgeInsets.all(5),
          scrollDirection: Axis.vertical,
        );
}
