



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/equipment.dart';
import 'package:smartresponse4/profile.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/profile_listtile.dart';


class EquipmentRiders extends StatefulWidget {

  final Equipment eq;
  final String squadID;

  EquipmentRiders(this.squadID, this.eq);
  @override
  _EquipmentRidersState createState() => _EquipmentRidersState();
}

class _EquipmentRidersState extends State<EquipmentRiders> {
  Stream<List<Profile>> _equipmentRidersStream;

  @override
  void initState() {
    super.initState();
    _equipmentRidersStream = context.read<Repository>().getEquipmentProfiles(widget.squadID, widget.eq.equipmentName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text("Equipment Personnel"),
        backgroundColor: appColorMid,
    ),
        body: Container(
          width: double.infinity,
          decoration: customBoxDecoration(),
          child: Column(
            children: <Widget>[
              Container (
                  width: double.infinity,
                  color: Colors.blue[200],
                  alignment: Alignment.center,
                  child:  Text("'Riders' on Equipment: " + widget.eq.equipmentName),
              ),

              StreamBuilder<List<Profile>>(
                stream: _equipmentRidersStream,
                builder: (BuildContext context, AsyncSnapshot<List<Profile>> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text('Loading...');
                  default:
                    return Expanded (
                      child: ListView(
                          children: snapshot.data.map((Profile rider) {
                            print("equipment_riders.dart: rider - eq: " + rider.name + " " + widget.eq.equipmentName);
                            return ProfileListTile(rider);
                          }).toList(),
                      ),
                    );
                  }
                }
              ),
            ],
          ),
        ),
    );
  }
}