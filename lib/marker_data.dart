

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

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



class CustomMarkers {
  CustomMarkers._privateConstructor();
  static final CustomMarkers _instance = CustomMarkers._privateConstructor();
  static CustomMarkers get instance => _instance;
  bool loaded = false;
  MarkerData myMarkerData;

  Future<BitmapDescriptor> getBitmapFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    Uint8List bytes = (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
    return BitmapDescriptor.fromBytes(bytes);
  }


  Future<MarkerData> getCustomMarkers() async {
    if(!loaded) {
      BitmapDescriptor starOfLifeIcon =await getBitmapFromAsset('assets/car_icon.png', 150);
      MyMarker star = MyMarker(iconBitmap: starOfLifeIcon, image: Image.asset('assets/car_icon.png'), commonName: "Star of Life", shortName:  "star");
      BitmapDescriptor fireTruckIcon = await getBitmapFromAsset('assets/firetruck50.png', 150);
      MyMarker truck = MyMarker(iconBitmap: fireTruckIcon, image: Image.asset('assets/firetruck50.png'), commonName: "Fire Engine", shortName:  "truck");
      BitmapDescriptor fireIcon = await getBitmapFromAsset('assets/fire50.png', 150);
      MyMarker fire = MyMarker(iconBitmap: fireIcon, image: Image(image: AssetImage('assets/fire50.png')), commonName: "Fire/Flames", shortName: "fire");
      myMarkerData =  MarkerData(star: star, truck: truck, fire: fire);
      loaded = true;
    }
    return myMarkerData;
  }
}