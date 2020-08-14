





import 'package:cloud_firestore/cloud_firestore.dart';

class Scene {
  final GeoPoint location;
  final Timestamp created;
  final String desc;
  final bool turnOnNavigation;
  Scene ({this.location, this.created, this.desc, this.turnOnNavigation=false});
}

