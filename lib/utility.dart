

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


LatLng asLatLng(GeoPoint g) {
  return LatLng(g.latitude, g.longitude);
}

GeoPoint asGeoPoint(LatLng l) {
  return GeoPoint(l.latitude,l.longitude);
}

Future<double> distanceBetweenInMinutes (dynamic a, dynamic b) async {
   double meters =  await Geolocator().distanceBetween(a.latitude, a.longitude, b.latitude, b.longitude);
   print("utility.dart: distance away = " + meters.toString());
   if(meters < 40) return 1;
   if(meters < 16000) return meters/800+2;
   return meters/1100 + 2;
}

Future<double> distanceBetween (dynamic a, dynamic b) {
    return Geolocator().distanceBetween(a.latitude, a.longitude, b.latitude, b.longitude);
}

