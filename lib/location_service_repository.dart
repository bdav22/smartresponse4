import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:background_locator/location_dto.dart';

import 'file_manager.dart';

class LocationServiceRepository {
  static LocationServiceRepository _instance = LocationServiceRepository._();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  static const String isolateName = 'LocatorIsolate';

  int _count = -1;
  String _uid = "Unknown ToFix";
  String _sceneid = "Unknown ToFix";
  String _name = "Unknown ToFix";

  Future<void> init(Map<dynamic, dynamic> params) async {
    print("location_service_repository.dart: ***********Init callback handler");
    if(params.containsKey("sceneID")) {
      _sceneid = params['sceneID'];
      print("location_service_repository.dart: Found the following _sceneid=" + _sceneid);
    }

    if(params.containsKey("name")) {
      _name = params['name'];
    }

    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }
    if (params.containsKey('uid')) {
      _uid = params['uid'];
    }
    print("location_service_repository.dart: $_count, $_uid, $_sceneid");
    //await setLogLabel("start");
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> dispose() async {
    print("location_service_repository.dart: ***********Dispose callback handler");
    print("location_service_repository.dart: $_count");
    //await setLogLabel("end");
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    print('location_service_repository.dart: $_count location in dart: ${locationDto.toString()}');
    // await setLogPosition(_count, locationDto); //push into the log file
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);

    GeoPoint geoPoint = GeoPoint(locationDto.latitude, locationDto.longitude);
    print("location_service_repository.dart: pushing to firestore: " + _uid + " with scene id: " + _sceneid + " and name:" + _name);
    await Firestore.instance.collection("profiles").document(_uid).updateData({'location': geoPoint});
    //---- scenes get this info from the profile instead - only one push needed so no need to do this old: push to the scene instead
    //await Firestore.instance.collection("scenes/" + _sceneid + "/responders").document(_uid).setData({'location': geoPoint, 'uid': _uid, 'name': _name},merge: false);

    send?.send(locationDto);
    _count++;
  }

  static Future<void> setLogLabel(String label) async {
    final date = DateTime.now();
    await FileManager.writeToLogFile(
        '------------\n$label: ${formatDateLog(date)}\n------------\n');
  }

  static Future<void> setLogPosition(int count, LocationDto data) async {
    final date = DateTime.now();
    await FileManager.writeToLogFile(
        '$count : ${formatDateLog(date)} --> ${formatLog(data)} --- isMocked: ${data.isMocked}\n');
  }

  static double dp(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  static String formatDateLog(DateTime date) {
    return date.hour.toString() +
        ":" +
        date.minute.toString() +
        ":" +
        date.second.toString();
  }

  static String formatLog(LocationDto locationDto) {
    return dp(locationDto.latitude, 4).toString() +
        " " +
        dp(locationDto.longitude, 4).toString();
  }
}
