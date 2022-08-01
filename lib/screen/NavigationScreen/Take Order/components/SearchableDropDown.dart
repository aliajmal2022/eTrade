import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:eTrade/entities/Customer.dart';
import 'package:eTrade/helper/Sql_Connection.dart';
import 'package:eTrade/helper/onldt_to_local_db.dart';
import 'package:flutter/material.dart';

//  SearchField(
//             suggestions: _statesOfIndia.map((e) =>
//                SearchFieldListItem(e)).toList(),
//             suggestionState: Suggestion.expand,
//             textInputAction: TextInputAction.next,
//             hint: 'SearchField Example 2',
//             hasOverlay: false,
//             searchStyle: TextStyle(
//               fontSize: 18,
//               color: Colors.black.withOpacity(0.8),
//             ),
//             validator: (x) {
//               if (!_statesOfIndia.contains(x) || x!.isEmpty) {
//                return 'Please Enter a valid State';
//               }
//             return null;
//             },
//             searchInputDecoration: InputDecoration(
//               focusedBorder: OutlineInputBorder(
//                borderSide: BorderSide(
//                color: Colors.black.withOpacity(0.8),
//                ),
//               ),
//               border: OutlineInputBorder(
//                borderSide: BorderSide(color: Colors.red),
//               ),
//             ),
//             maxSuggestionsInViewPort: 6,
//             itemHeight: 50,
//             onTap: (x) {},
//          );
class AwesomeDropdown extends StatefulWidget {
  @override
  _AwesomeDropdownState createState() => _AwesomeDropdownState();
}

class _AwesomeDropdownState extends State<AwesomeDropdown> {
  Customer _selectedItem =
      Customer(partyId: 0, discount: 0, partyName: "", userId: 0, address: "");

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownFormField<Map<String, dynamic>>(
            onEmptyActionPressed: () async {},
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.arrow_drop_down),
                labelText: "Search Customer"),
            onSaved: (dynamic str) {},
            onChanged: (dynamic str) {},
            validator: (dynamic str) {},
            displayItemFn: (dynamic item) => Text(
              (item ?? {})['PartyName'] ?? '',
              style: TextStyle(fontSize: 16),
            ),
            findFn: (var str) async => await Sql_Connection().read(
                'SELECT p.PartyID,p.PartyName,p.Discount,p.Address FROM Party AS p WHERE p.AccTypeID=6'),
            // findFn: (dynamic str) async => _roles,
            selectedFn: (dynamic item1, dynamic item2) {
              if (item1 != null && item2 != null) {
                return item1['PartyName'] == item2['PartyName'];
              }
              return false;
            },
            filterFn: (dynamic item, str) =>
                item['PartyName'].toLowerCase().indexOf(str.toLowerCase()) >= 0,
            dropdownItemFn: (dynamic item, int position, bool focused,
                    bool selected, Function() onTap) =>
                ListTile(
              title: Text(item['PartyName']),
              subtitle: Text(
                item['Address'] ?? '',
              ),
              tileColor:
                  focused ? Color.fromARGB(20, 0, 0, 0) : Colors.transparent,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return

  // DropdownFormField(
  //   onEmptyActionPressed: () async {},
  //   decoration: InputDecoration(
  //       border: OutlineInputBorder(),
  //       suffixIcon: Icon(Icons.arrow_drop_down),
  //       labelText: "Search Customer"),
  //   onSaved: (dynamic str) {},
  //   onChanged: (dynamic str) {},
  //   validator: (dynamic str) {},
  //   displayItemFn: (dynamic item) => Text(
  //     item!.partyName,
  //     style: TextStyle(fontSize: 16),
  //   ),
  //   findFn: (dynamic str) async => DataBaseDataLoad.ListOCustomer,

  //   filterFn: (dynamic item, str) =>
  //       item.partyName.toLowerCase().indexOf(str.toLowerCase()) >= 0,
  //   dropdownItemFn:
  //       (dynamic item, position, focused, dynamic lastSelectedItem, onTap) =>
  //           ListTile(
  //     title: Text(item.partyName),
  //     subtitle: Text(
  //       item.address,
  //     ),
  //     tileColor: focused ? Color.fromARGB(20, 0, 0, 0) : Colors.transparent,
  //     onTap: onTap,
  //   ),
  // );
  // }
}
