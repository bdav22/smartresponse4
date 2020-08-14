

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


LatLng asLatLng(GeoPoint g) {
  return LatLng(g.latitude, g.longitude);
}

GeoPoint asGeoPoint(LatLng l) {
  return GeoPoint(l.latitude,l.longitude);
}