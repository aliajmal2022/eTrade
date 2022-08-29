import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// const Color etradeMainColor = Color(0xff00620b);
// const Color etradeMainColor = Color(0xff00BBFF);
const Color etradeMainColor = Colors.blue;
const Color etradeRed = Color(0xffde0000);
const Color etradeBlue = Color(0xff00174b);

final formatter = NumberFormat('#,###,000');

showAlertDialog(BuildContext context, String title, String content,
    Function()? cancelOnPress, Function()? okOnPress) {
  // set up the button
  Widget progressButton =
      TextButton(child: const Text("OK"), onPressed: okOnPress);
  Widget cancelButton =
      TextButton(child: const Text("Cancel"), onPressed: cancelOnPress);
  // set up the AlertDialog
  List<Widget> LOWidget = [cancelButton, progressButton];
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: LOWidget,
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
