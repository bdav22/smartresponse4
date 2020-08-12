

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMarker {
  MyMarker({this.iconBitmap, this.image, this.commonName, this.shortName});
  BitmapDescriptor iconBitmap;
  Image image;
  String commonName;
  String shortName;
  String desc;
}


class MarkerData {
  MyMarker star, truck, fire;
  List<MyMarker> markerList = List<MyMarker>();
  MarkerData({this.star, this.truck, this.fire}) {
    markerList.add(star);
    markerList.add(truck);
    markerList.add(fire);
  }


}
