



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/equipment.dart';
import 'package:smartresponse4/profile.dart';

class EquipmentRiders extends StatelessWidget {

  final List<Profile> riders;
  Equipment eq;
  EquipmentRiders(this.riders, this.eq);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text("Equipment Personnel"),
        backgroundColor: appColorMid,
    ),
        body: Column(
          children: <Widget>[
            Text("'Riders' on Equipment: " + eq.equipmentName),
            Text("To Be Implemented"),
          ],
        ),
    );
  }
}