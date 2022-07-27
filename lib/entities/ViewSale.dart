class ViewSaleBooking {
  ViewSaleBooking(
      {required this.saleID,
      required this.saleDate,
      required this.partyName,
      required this.totalQuantity});

  int saleID;
  String saleDate;
  int totalQuantity;
  String partyName;

  static List<ViewSaleBooking> ViewSaleFromDb(List _sale) {
    List<ViewSaleBooking> _listSaleView = [];
    if (_sale.isNotEmpty) {
      _sale.forEach((element) {
        ViewSaleBooking viewSale = ViewSaleBooking(
            saleID: 0, saleDate: "", partyName: "", totalQuantity: 0);
        viewSale.saleDate = element['Dated'];
        viewSale.totalQuantity = element['TotalQuantity'];
        viewSale.partyName = element['PartyName'];
        viewSale.saleID = element['InvoiceID'];
        _listSaleView.add(viewSale);
      });
    }
    return _listSaleView;
  }
}
