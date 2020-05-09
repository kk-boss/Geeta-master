import 'package:flutter/material.dart';

MediaQueryData mediaQuery;
var ptr;
Widget my() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Stack(
      children: <Widget>[
        SizedBox(
            height: 10,
            width: mediaQuery.size.width,
            child: Container(
              color: Colors.white,
            )),
        SizedBox(
            height: 10,
            width: mediaQuery.size.width * ptr / 100,
            child: Container(
              color: Colors.blue,
            )),
      ],
    ),
  );
}
