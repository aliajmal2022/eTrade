import 'package:etrade/entities/Order.dart';
import 'package:etrade/entities/OrderDetail.dart';
import 'package:etrade/entities/Recovery.dart';
import 'package:etrade/entities/Sale.dart';
import 'package:etrade/entities/SaleDetail.dart';
import 'package:etrade/helper/sqlhelper.dart';
import 'package:intl/intl.dart';

class AdminData {
  static deleteExecution(String start, String end) {
    start =
        DateFormat('yyyy-MM-dd').format(DateFormat('yyyy/MM/dd').parse(start));
    end = DateFormat('yyyy-MM-dd').format(DateFormat('yyyy/MM/dd').parse(end));
    SQLHelper.deleteRangeDataFromTable("Order", start, end);
    SQLHelper.deleteRangeDataFromTable("OrderDetail", start, end);
    SQLHelper.deleteRangeDataFromTable("Sale", start, end);
    SQLHelper.deleteRangeDataFromTable("SaleDetail", start, end);
    SQLHelper.deleteRangeDataFromTable("Recovery", start, end);
  }

  static deleteBooking(String start, String end) {
    start =
        DateFormat('yyyy-MM-dd').format(DateFormat('yyyy/MM/dd').parse(start));
    end = DateFormat('yyyy-MM-dd').format(DateFormat('yyyy/MM/dd').parse(end));
    SQLHelper.deleteRangeDataFromTable("OrderExecution", start, end);
    SQLHelper.deleteRangeDataFromTable("OrderDetailExecution", start, end);
    SQLHelper.deleteRangeDataFromTable("SaleExecution", start, end);
    SQLHelper.deleteRangeDataFromTable("SaleDetailExecution", start, end);
    SQLHelper.deleteRangeDataFromTable("RecoveryExecution", start, end);
  }

  static getBookingData(String start, String end) async {
    List<Order> LOOrder = [];
    List<OrderDetail> LOOrderDetail = [];
    List<Sale> LOSale = [];
    List<SaleDetail> LOSaleDetail = [];
    List<Recovery> LORecovey = [];
    LOOrder = await Order.OrderForAdmin(start, end);
    LOOrderDetail = await OrderDetail.OrderDetailForAdmin(start, end);
    LOSale = await Sale.SaleForAdmin(start, end);
    LOSaleDetail = await SaleDetail.SaleDetailForAdmin(start, end);
    LORecovey = await Recovery.RecoveryForAdmin(start, end);

    LOOrder.forEach((element) async {
      await SQLHelper.instance.createOrderForAdmin(element);
    });
    LOOrderDetail.forEach((element) async {
      await SQLHelper.instance.createOrderDetailForAdmin(element);
    });
    LOSale.forEach((element) async {
      await SQLHelper.instance.createSaleForAdmin(element);
    });
    LOSaleDetail.forEach((element) async {
      await SQLHelper.instance.createSaleDetailForAdmin(element);
    });
    LORecovey.forEach((element) async {
      await SQLHelper.instance.createRecoveryitemForAdmin(element);
    });
  }

  static getExecutionData(String start, String end) async {
    List<Order> LOOrder = [];
    List<OrderDetail> LOOrderDetail = [];
    List<Recovery> LORecovey = [];
    List<Sale> LOSale = [];
    List<SaleDetail> LOSaleDetail = [];
    LOOrder = await Order.ExecutionForAdmin(start, end);
    LOOrderDetail = await OrderDetail.ExecutionForAdmin(start, end);
    LORecovey = await Recovery.ExecutionForAdmin(start, end);
    LOSale = await Sale.ExecutionForAdmin(start, end);
    LOSaleDetail = await SaleDetail.ExecutionForAdmin(start, end);
    LOOrder.forEach((element) async {
      await SQLHelper.instance.createOrderExecutionForAdmin(element);
    });
    LOOrderDetail.forEach((element) async {
      await SQLHelper.instance.createOrderDetailExecutionForAdmin(element);
    });
    LOSale.forEach((element) async {
      await SQLHelper.instance.createSaleForAdmin(element);
    });
    LOSaleDetail.forEach((element) async {
      await SQLHelper.instance.createSaleDetailForAdmin(element);
    });
    LORecovey.forEach((element) async {
      await SQLHelper.instance.createRecoveryExecutionitemForAdmin(element);
    });
  }
}
