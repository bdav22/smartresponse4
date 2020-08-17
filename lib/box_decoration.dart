

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