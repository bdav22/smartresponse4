import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/equipment.dart';
import 'package:smartresponse4/loading.dart';
import 'package:smartresponse4/marker_data.dart';
import 'package:smartresponse4/profile.dart';


class ChooseEquipment extends StatelessWidget {
  final Profile profile;
  ChooseEquipment({this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Equipment Chooser"),
          backgroundColor: appColorMid,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("departments/"+profile.squadID+"/equipment").snapshots(),
          builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> docs = snapshot.data.docs;
            List<Equipment> eqs = docs.map( (doc) {
              return Equipment(iconName: doc?.data()['icon'], equipmentName: doc?.data()['name'], docID: doc.reference);
            }).toList();
            return Container(
              decoration: customBoxDecoration(),
              child: ListView.builder(
                  itemCount: eqs?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Card(child:
                    ListTile(
                      leading: Image( image: AssetImage("assets/" + assetFromString(eqs[index].iconName)), height: 40 ),
                      title: Text(eqs[index]?.equipmentName ?? "-"),
                      onTap: () async {
                        print("equipment_chooser.dart: Choose name=  " + (eqs[index]?.equipmentName ?? "-"));
                        Navigator.pop(context, eqs[index]);
                      },
                    )
                    );
                  }
              ),
            );
          } else { return Loading(); }
          }
        )
      );
  }
}