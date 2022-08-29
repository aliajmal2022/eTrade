
import 'package:etrade/components/CustomNavigator.dart';
import 'package:etrade/components/NavigationBar.dart';
import 'package:etrade/components/constants.dart';
import 'package:etrade/components/drawer.dart';
import 'package:etrade/entities/Customer.dart';
import 'package:etrade/entities/ViewRecovery.dart';
import 'package:etrade/helper/Sql_Connection.dart';
import 'package:etrade/helper/sqlhelper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sql_conn/sql_conn.dart';

class PostingData extends StatefulWidget {
  PostingData({required this.ping});
  String ping;

  static int cCount = 0;
  static int oCount = 0;
  static int odCount = 0;
  static int sCount = 0;
  static int sdCount = 0;
  static int rCount = 0;
  static bool isPosteddone = false;
  @override
  State<PostingData> createState() => _PostingDataState();
}

class _PostingDataState extends State<PostingData>
    with TickerProviderStateMixin {
  var snackBar;
  List _recovery = [];
  List _sale = [];
  List _saleDetail = [];
  List _order = [];
  List _orderDetail = [];
  List _setTarget = [];
  int count = 0;
  List _party = [];
  bool notData = false;
  Future<void> checkDataAvialable() async {
    await SQLHelper.backupDB();
    _recovery = await SQLHelper.getNotPostedRecovery();
    _sale = await SQLHelper.getNotPostedSale();
    _saleDetail = await SQLHelper.getNotPostedSaleDetail();
    _party = await SQLHelper.getNotPostedParty();
    _order = await SQLHelper.getNotPostedOrder();
    _orderDetail = await SQLHelper.getNotPostedOrderDetail();
    // _setTarget = await SQLHelper.getNotPostedUserTarget();
    var strToList = widget.ping.split(",");
    var ip = strToList[0];
    var port = strToList[1];
    bool isconnected = await Sql_Connection.connect(context, ip, port);
    if (isconnected) {
      snackBar = SnackBar(
        content: Text("Posting is Completed."),
      );

      if (_order.isNotEmpty ||
          _orderDetail.isNotEmpty ||
          _party.isNotEmpty ||
          _sale.isNotEmpty ||
          _setTarget.isNotEmpty ||
          _saleDetail.isNotEmpty ||
          _recovery.isNotEmpty) {
        try {
//           if (_setTarget.isNotEmpty) {
//             await Sql_Connection().write("""
// DELETE FROM dbo_m.SaleRapTarget WHERE SRID=${MyNavigationBar.userID}
// """);
//             await Sql_Connection().write("""
// INSERT INTO dbo_m.SaleRapTarget
// (
// 	SRID,
// 	January,
// 	February,
// 	March,
// 	April,
// 	May,
// 	June,
// 	July,
// 	August,
// 	September,
// 	October,
// 	November,
// 	December
// )
// VALUES
// (
// 	${MyNavigationBar.userID},
// 	${_setTarget[0]['January']},
// 	${_setTarget[0]['February']},
// 	${_setTarget[0]['March']},
// 	${_setTarget[0]['April']},
// 	${_setTarget[0]['May']},
// 	${_setTarget[0]['June']},
// 	${_setTarget[0]['July']},
// 	${_setTarget[0]['August']},
// 	${_setTarget[0]['September']},
// 	${_setTarget[0]['October']},
// 	${_setTarget[0]['November']},
// 	${_setTarget[0]['December']}
// )
// """);
//           }

          if (_order.isNotEmpty) {
            for (var element in _order) {
              String date = element['Dated'];

              if (count < _order.length)
                await Sql_Connection().write(
                    "INSERT INTO dbo_m.[Order](OrderID,UserId,PartyID,TotalQuantity,TotalValue,Dated,[Description])VALUES( ${element['OrderID']} , ${element['UserID']} , ${element['PartyID']},${element['TotalQuantity']} ,${element['TotalValue']} , '${date}',	'${element['Description']}')");
              count++;
              setState(() {
                PostingData.oCount = count;
              });
            }
            count = 0;
          }
          if (_orderDetail.isNotEmpty) {
            for (var element in _orderDetail) {
              String date = element['Dated'];
              if (count < _orderDetail.length)
                await Sql_Connection().write(
                    "INSERT INTO dbo_m.[OrderDetail]( UserId ,OrderID, ItemID, Quantity, RATE, Amount, Dated) VALUES ( ${element['UserID']}, ${element['OrderID']} , '${element['ItemID']}', ${element['Quantity']},${element['RATE']} ,${element['Amount']} , '${date}') ");
              count++;
              setState(() {
                PostingData.odCount = count;
              });
            }
            count = 0;
          }

          if (_recovery.isNotEmpty) {
            for (var element in _recovery) {
              String date = element['Dated'];
              if (count < _recovery.length)
                await Sql_Connection().write(
                    """ INSERT INTO dbo_m.[Recovery]( RecoveryID, UserId, PartyID, Amount, Dated,isCash ,[Description]) VALUES 
                   ( ${element['RecoveryID']},${element['UserID']},${element['PartyID']},${element['Amount']},'${date}',${element['isCash']},'${element['Description']}') """);
              count++;
              setState(() {
                PostingData.rCount = count;
              });
            }
            count = 0;
          }
          if (_sale.isNotEmpty) {
            for (var element in _sale) {
              String date = element['Dated'];

              if (count < _sale.length)
                await Sql_Connection().write(
                    "INSERT INTO dbo_m.[Sale](InvoiceID,UserId,PartyID,isCashInvoice,TotalQuantity,TotalValue,Dated,[Description])VALUES( ${element['InvoiceID']} , ${element['UserID']} , ${element['PartyID']},${element['isCashInvoice']},${element['TotalQuantity']} ,${element['TotalValue']} , '${date}',	'${element['Description']}')");
              count++;
              setState(() {
                PostingData.sCount = count;
              });
            }
            count = 0;
          }
          if (_saleDetail.isNotEmpty) {
            for (var element in _saleDetail) {
              String date = element['Dated'];
              if (count < _saleDetail.length)
                await Sql_Connection().write(
                    "INSERT INTO dbo_m.[SaleDetail]( InvoiceID,UserId , ItemID, Quantity, RATE, Amount, Dated) VALUES ( ${element['InvoiceID']}, ${element['UserID']} , '${element['ItemID']}', ${element['Quantity']},${element['RATE']} ,${element['Amount']} , '${date}') ");
              count++;
              setState(() {
                PostingData.sdCount = count;
              });
            }
            count = 0;
          }
          if (_party.isNotEmpty) {
            for (var element in _party) {
              if (count < _party.length)
                await Sql_Connection().write(
                    "INSERT INTO dbo_m.[Party](PartyID,UserId,PartyName,Discount,Address)VALUES( ${element['PartyID']} , ${element['UserID']} , '${element['PartyName']}',${element['Discount']} ,'${element['Address']}')");
              count++;
              setState(() {
                PostingData.cCount = count;
              });
            }
            count = 0;
          }
          await SQLHelper.tablePosted();
          setState(() {
            notData = true;
            PostingData.isPosteddone = true;
          });
          print("here we go");
        } catch (e) {
          setState(() {
            notData = true;
            PostingData.isPosteddone = true;
          });
          debugPrint("Ops");
        }
      } else {
        setState(() {
          notData = true;
          PostingData.isPosteddone = true;
        });
      }
    } else {
      // await SQLHelper.tableNotPosted();
      snackBar = SnackBar(
        content: Text("Host unaccessible. Keep your device near to router."),
      );
      Navigator.pushAndRemoveUntil(
          context,
          MyCustomRoute(
              slide: "Left",
              builder: (context) => MyNavigationBar.initializer(0)),
          (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  var _animationController;
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    setState(() {
      checkDataAvialable();
    });
    super.initState();
  }

  bool isCompleted = false;
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: isLandscape
              ? Row(children: [
                  PostingData.isPosteddone
                      ? Container()
                      : Expanded(
                          flex: 1,
                          child: Image.asset(
                            "images/posting.gif",
                            gaplessPlayback: true,
                            fit: BoxFit.fill,
                          ),
                        ),
                  ScaleTransition(
                    scale: _animationController,
                    child: Expanded(
                      flex: 1,
                      child: Card(
                        child: Container(
                          // constraints: BoxConstraints(maxHeight: 29),
                          decoration: BoxDecoration(
                            // color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    5.0), // Set rounded corner radius
                                topRight: Radius.circular(
                                    5.0)), // Set rounded corner radius
                          ),

                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  isCompleted
                                      ? "Posted Successfully"
                                      : "Posting Data",
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Total Customers Posted: "),
                                          (PostingData.cCount == 0 ||
                                                      _party.length == 0) &&
                                                  !notData
                                              ? CircularProgressIndicator(
                                                  color: etradeMainColor,
                                                  strokeWidth: 2,
                                                )
                                              : Text("${PostingData.cCount}"),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Total Order Posted: "),
                                          (PostingData.oCount == 0 ||
                                                      _order.length == 0) &&
                                                  !notData
                                              ? CircularProgressIndicator(
                                                  color: etradeMainColor)
                                              : Text("${PostingData.oCount}"),
                                        ],
                                      ),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.all(4.0),
                                    //   child: Row(
                                    //     mainAxisAlignment:
                                    //         MainAxisAlignment.spaceBetween,
                                    //     children: [
                                    //       Text("Total OrderDetail Posted: "),
                                    //       (PostingData.odCount == 0 ||
                                    //                   _orderDetail.length ==
                                    //                       0) &&
                                    //               !notData
                                    //           ? CircularProgressIndicator(
                                    //               color: etradeMainColor)
                                    //           : Text("${PostingData.odCount}"),
                                    //     ],
                                    //   ),
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Total Sale Posted: "),
                                          (PostingData.sCount == 0 ||
                                                      _sale.length == 0) &&
                                                  !notData
                                              ? SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color:
                                                              etradeMainColor))
                                              : Text("${PostingData.sCount}"),
                                        ],
                                      ),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.all(4.0),
                                    //   child: Row(
                                    //     mainAxisAlignment:
                                    //         MainAxisAlignment.spaceBetween,
                                    //     children: [
                                    //       Text("Total SaleDetail Posted: "),
                                    //       (PostingData.sdCount == 0 ||
                                    //                   _saleDetail.length ==
                                    //                       0) &&
                                    //               !notData
                                    //           ? SizedBox(
                                    //               width: 12,
                                    //               height: 12,
                                    //               child:
                                    //                   CircularProgressIndicator(
                                    //                       color:
                                    //                           etradeMainColor))
                                    //           : Text("${PostingData.sdCount}"),
                                    //     ],
                                    //   ),
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Total Recovery Posted: "),
                                          (PostingData.rCount == 0 &&
                                                      _recovery.length == 0) &&
                                                  !notData
                                              ? SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color:
                                                              etradeMainColor))
                                              : Text("${PostingData.rCount}"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PostingData.isPosteddone
                                  ? MaterialButton(
                                      onPressed: () {
                                        PostingData.oCount = 0;
                                        PostingData.odCount = 0;
                                        PostingData.cCount = 0;
                                        PostingData.sCount = 0;
                                        PostingData.rCount = 0;
                                        PostingData.sdCount = 0;
                                        PostingData.isPosteddone = false;
                                        Get.off(MyNavigationBar.initializer(0));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      },
                                      elevation: 2.0,
                                      padding: EdgeInsets.all(15.0),
                                      shape: CircleBorder(),
                                      color: etradeMainColor,
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                    )
                                  : CircularProgressIndicator(
                                      color: etradeMainColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ])
              : Column(
                  children: [
                    PostingData.isPosteddone
                        ? Container()
                        : Expanded(
                            flex: 1,
                            child: Image.asset("images/posting.gif",
                                gaplessPlayback: true, fit: BoxFit.fill),
                          ),
                    Expanded(
                      flex: 1,
                      child: Card(
                        child: Container(
                          // constraints: BoxConstraints(maxHeight: 29),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    5.0), // Set rounded corner radius
                                topRight: Radius.circular(
                                    5.0)), // Set rounded corner radius
                          ),

                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  PostingData.isPosteddone
                                      ? "Posted Successfully"
                                      : "Posting Data",
                                  style: TextStyle(
                                      fontSize: 25, color: etradeMainColor),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Total Customers Posted: "),
                                          (PostingData.cCount == 0 ||
                                                      _party.length == 0) &&
                                                  !notData
                                              ? SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color:
                                                              etradeMainColor))
                                              : Text("${PostingData.cCount}"),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Total Order Posted: "),
                                          (PostingData.oCount == 0 ||
                                                      _order.length == 0) &&
                                                  !notData
                                              ? SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color:
                                                              etradeMainColor))
                                              : Text("${PostingData.oCount}"),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Total OrderDetail Posted: "),
                                          (PostingData.odCount == 0 ||
                                                      _orderDetail.length ==
                                                          0) &&
                                                  !notData
                                              ? SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color:
                                                              etradeMainColor))
                                              : Text("${PostingData.odCount}"),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Total Sale Posted: "),
                                          (PostingData.sCount == 0 ||
                                                      _sale.length == 0) &&
                                                  !notData
                                              ? SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color:
                                                              etradeMainColor))
                                              : Text("${PostingData.sCount}"),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Total SaleDetail Posted: "),
                                          (PostingData.sdCount == 0 ||
                                                      _saleDetail.length ==
                                                          0) &&
                                                  !notData
                                              ? SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color:
                                                              etradeMainColor))
                                              : Text("${PostingData.sdCount}"),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Total Recovery Posted: "),
                                          (PostingData.rCount == 0 &&
                                                      _recovery.length == 0) &&
                                                  !notData
                                              ? SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color:
                                                              etradeMainColor))
                                              : Text("${PostingData.rCount}"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PostingData.isPosteddone
                                  ? MaterialButton(
                                      onPressed: () {
                                        PostingData.oCount = 0;
                                        PostingData.odCount = 0;
                                        PostingData.cCount = 0;
                                        PostingData.sCount = 0;
                                        PostingData.rCount = 0;
                                        PostingData.sdCount = 0;
                                        PostingData.isPosteddone = false;
                                        Get.off(MyNavigationBar.initializer(0));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      },
                                      elevation: 2.0,
                                      padding: EdgeInsets.all(15.0),
                                      shape: CircleBorder(),
                                      color: etradeMainColor,
                                      child:
                                          // Image.asset(
                                          //   'done.gif',
                                          //   fit: BoxFit.fill,
                                          // ),
                                          Icon(
                                        Icons.done,
                                        color: Colors.white,
                                      ))
                                  : CircularProgressIndicator(
                                      color: etradeMainColor),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
