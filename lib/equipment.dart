


import 'package:cloud_firestore/cloud_firestore.dart';

class Equipment {

  final String iconName;
  final String equipmentName;
  final DocumentReference docID;
  Equipment({this.iconName, this.equipmentName, this.docID});

}