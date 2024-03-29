

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

BoxDecoration customBoxDecoration() {
  return BoxDecoration (
    color: Colors.blue,
    gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey[700], Colors.blueAccent[400]]),
  );
}


BoxDecoration myBoxDecoration() {
  return BoxDecoration(
    border: Border.all(
        width: 2.0
    ),
    borderRadius: BorderRadius.all(
        Radius.circular(10.0) //         <--- border radius here
    ),
  );
}

RoundedRectangleBorder cardShape() {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(11.0),
    side: BorderSide(
      color: Colors.grey[700],
      width: 2.0,
    ),
  );
}