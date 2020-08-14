

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//const apiKey = "AIzaSyB5A4tFZas3BSzgNiRmQ0Hk84U_khFuUAI";
const apiKey = "AIzaSyAVr8ZnuAgE-DHim24vpsyHEnIevcFladc";

class GoogleMapsRoutes {
  final Set<Polyline> _polyLines = {};
  Set<Polyline> get polyLines => _polyLines;

  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async{
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$apiKey";
    // print("url is: " + url);
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    if(values["status"] == "ZERO_RESULTS") {
      return null;
    }
    return values["routes"][0]["overview_polyline"]["points"];
  }


  Future<Set<Polyline>> sendRequest(LatLng source, LatLng dest) async {
    String route = await getRouteCoordinates( source, dest);
    return route == null ? null : createRoute(route, source);
    //_addMarker(destination,"KTHM Collage");
  }

  Set<Polyline> createRoute(String encodedPoly, LatLng latLng) {
    _polyLines.clear();
    _polyLines.add(Polyline(
        polylineId: PolylineId(latLng.toString()),
        width: 4,
        points: _convertToLatLng(_decodePoly(encodedPoly)),  color: Colors.red)
    );
    return _polyLines;
  }
}


List<LatLng> _convertToLatLng(List points) {
  List<LatLng> result = <LatLng>[];
  for (int i = 0; i < points.length; i++) {
    if (i % 2 != 0) {
      result.add(LatLng(points[i - 1], points[i]));
    }
  }
  return result;
}

List _decodePoly(String poly) {
  var list = poly.codeUnits;
  var lList = new List();
  int index = 0;
  int len = poly.length;
  int c = 0;
  do {
    var shift = 0;
    int result = 0;
    do {
      c = list[index] - 63;
      result |= (c & 0x1F) << (shift * 5);
      index++;
      shift++;
    }
    while (c >= 32);
    if (result & 1 == 1) {
      result = ~result;
    }
    var result1 = (result >> 1) * 0.00001;
    lList.add(result1);
  } while (index < len);
  for (var i = 2; i < lList.length; i++)
    lList[i] += lList[i - 2];
  //print(lList.toString());
  return lList;
}
