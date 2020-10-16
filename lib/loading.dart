import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:smartresponse4/decoration.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: myBoxDecoration(),
      //color: Colors.cyan[100],
      child: Center(
        child: SpinKitFadingCube(
          color: Colors.brown,
          size: 50.0,
        ),
      ),

    );
  }
}