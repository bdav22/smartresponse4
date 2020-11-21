
import 'dart:io';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:flutter/material.dart';
//import 'package:background_locator/location_settings.dart';
import 'package:location_permissions/location_permissions.dart' as location_permissions;
import 'package:smartresponse4/location_callback_handler.dart';
import 'package:smartresponse4/user.dart';


class BackgroundLocationInterface{

  BackgroundLocationInterface();


  Future<void> initPlatformState() async {
    print("MAP_LOCATION.DART: initPlatformState");

    //return; // TODO FIX ON IOS

    print('map_location.dart: Initializing background locator ...');
    if(Platform.isAndroid) {
      await BackgroundLocator.initialize();
    }
    print('map_location.dart: Initialization done');
  }

Future<bool> _checkLocationPermission() async {
  final access = await location_permissions.LocationPermissions().checkPermissionStatus();
  switch (access) {
    case location_permissions.PermissionStatus.unknown:
    case location_permissions.PermissionStatus.denied:
    case location_permissions.PermissionStatus.restricted:
      final permission = await location_permissions.LocationPermissions().requestPermissions(
        permissionLevel: location_permissions.LocationPermissionLevel.locationAlways,
      );
      if (permission == location_permissions.PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
      break;
    case location_permissions.PermissionStatus.granted:
      return true;
      break;
    default:
      return false;
      break;
  }
}

void onStop() {
    print("map_location.dart: onStop()");
    BackgroundLocator.unRegisterLocationUpdate();
}

void onStart(String sceneID) async {
  print("map_location.dart: onStart()");
  if (await _checkLocationPermission()) {
    //onStop(); Leave first? - remove active on app boot-up
    _startLocator(sceneID);
  } else {
    // show error
  }
}



  void _startLocator(String sceneID) {
    Map<String, dynamic> data = {'countInit': 1, 'uid': EmailStorage.instance.uid, 'sceneID': sceneID, 'name': EmailStorage.instance.userData.name};
    print("map_location.dart: _startLocator");
    BackgroundLocator.registerLocationUpdate(
      LocationCallbackHandler.callback,
      initCallback: LocationCallbackHandler.initCallback,
      initDataCallback: data,
      autoStop: false,
/*
        Comment initDataCallback, so service not set init variable,
        variable stay with value of last run after unRegisterLocationUpdate
 */
      disposeCallback: LocationCallbackHandler.disposeCallback,
      //androidNotificationCallback: LocationCallbackHandler.notificationCallback,
      iosSettings: IOSSettings(accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 10),
      androidSettings: AndroidSettings(
          androidNotificationSettings: AndroidNotificationSettings(
            notificationChannelName: "Smart Response Locator - Responding",
            notificationTitle: "SmartResponse - Responding",
            notificationMsg: "Background location for SmartResponse",
            notificationBigMsg: "Background location is on to keep Smart Response up to date with your location as you are responding to an alert.",
            notificationIcon: '',
            notificationIconColor: Colors.green,
            notificationTapCallback: LocationCallbackHandler.notificationCallback,
          ),
          wakeLockTime: 20,
          distanceFilter: 10,
          interval: 5),
    );
  }

}