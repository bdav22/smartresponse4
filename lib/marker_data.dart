

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
  MyMarker star, truck, fire, hydrant;
  List<MyMarker> markerList = List<MyMarker>();
  List<MyMarker> inlist;
  Map<String, MyMarker> myMarkerMap = {};
  MarkerData({this.star, this.truck, this.fire, this.hydrant, this.inlist}) {
    markerList.add(star);
    markerList.add(truck);
    markerList.add(fire);
    markerList.add(hydrant);
    print("MarkerData: inlist.length = " + inlist.length.toString());
    for(var i = 0; i < inlist.length; i++) {
      print("MarkerData: i = " + i.toString());
      markerList.add(inlist[i]);
      print("MarkerData:  added to list");
      myMarkerMap[inlist[i].shortName] = inlist[i];
      print("MarkerData:  added to dictionary");
    }
    print("MarkerData: Marker Data constructor ending.");
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
    int size = 150;
    print("marker_data.dart: getCustomMarkers()");
    if(!loaded) {
      print("marker_data.dart: custom markers not loaded");
      List <String>  icons = [];
      List<String> preloadString =  [
        "emstruck279.png", "EMS Vehicle", "ems",
        //"hydrant279.png", "Hydrant", "hydrant",
        "firehat279.png", "Helmet", "helmet",
        "markerblue279.png", "Blue Marker", "mb",
        "markerred279.png", "Red Marker", "mr",
        "markergreen279.png", "Green Marker", "mg",
        "markermaroon279.png", "Maroon Marker", "mm",
                                  ];
      icons.addAll(preloadString);

      List <MyMarker> inlist = [];
      print("marker_data.dart: length of icons " + (icons.length/3).toString());
      for(var i = 0; i < icons.length; i = i + 3) {
        print("marker_data.dart: " + icons[i]);
        BitmapDescriptor nextIcon = await getBitmapFromAsset('assets/' + icons[i], size);
        MyMarker nextMarker = MyMarker(iconBitmap: nextIcon, image: Image.asset('assets/' + icons[i]), commonName: icons[i+1], shortName: icons[i+2]);
        inlist.add(nextMarker);
        print("marker_data.dart: added " + icons[i+2]);
      }


      BitmapDescriptor starOfLifeIcon =await getBitmapFromAsset('assets/car_icon.png', size);
      MyMarker star = MyMarker(iconBitmap: starOfLifeIcon, image: Image.asset('assets/car_icon.png'), commonName: "Star of Life", shortName:  "star");
      BitmapDescriptor hydrantIcon =await getBitmapFromAsset('assets/hydrant279.png', size);
      MyMarker hydrant = MyMarker(iconBitmap: hydrantIcon, image: Image.asset('assets/hydrant279.png'), commonName: "Hydrant", shortName:  "hydrant");
      BitmapDescriptor fireTruckIcon = await getBitmapFromAsset('assets/firetruck279.png', size);
      MyMarker truck = MyMarker(iconBitmap: fireTruckIcon, image: Image.asset('assets/firetruck279.png'), commonName: "Fire Engine", shortName:  "truck");
      BitmapDescriptor fireIcon = await getBitmapFromAsset('assets/fire50.png', size);
      MyMarker fire = MyMarker(iconBitmap: fireIcon, image: Image(image: AssetImage('assets/fire50.png')), commonName: "Fire/Flames", shortName: "fire");

      print("default icons loaded");
      myMarkerData =  MarkerData(star: star, truck: truck, fire: fire, hydrant: hydrant, inlist: inlist);
      print("MarkerData object triggered");
      loaded = true;
      print("marker_data.dart: loaded is true");
    }
    return myMarkerData;
  }
}