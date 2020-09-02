
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
//import 'package:background_locator/location_settings.dart';
import 'package:location_permissions/location_permissions.dart' as location_permissions;
import 'package:smartresponse4/location_callback_handler.dart';
import 'package:smartresponse4/user.dart';


class BackgroundLocationInterface{

  BackgroundLocationInterface();

  Future<void> initPlatformState() async {
    print('Initializing background locator ...');
    await BackgroundLocator.initialize();
    // final logStr = await FileManager.readLogFile();   print(logStr);
    print('Initialization done');
    final _isRunning = await BackgroundLocator.isRegisterLocationUpdate();
    print('Running ${_isRunning.toString()}');
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
  BackgroundLocator.unRegisterLocationUpdate();
}

void onStart(String sceneID) async {
  if (await _checkLocationPermission()) {
    onStop();
    _startLocator(sceneID);
  } else {
    // show error
  }
}



  void _startLocator(String sceneID) {
    Map<String, dynamic> data = {'countInit': 1, 'uid': EmailStorage.instance.uid, 'sceneID': sceneID, 'name': EmailStorage.instance.userData.name};
    BackgroundLocator.registerLocationUpdate(
      LocationCallbackHandler.callback,
      initCallback: LocationCallbackHandler.initCallback,
      initDataCallback: data,
/*
        Comment initDataCallback, so service not set init variable,
        variable stay with value of last run after unRegisterLocationUpdate
 */
      disposeCallback: LocationCallbackHandler.disposeCallback,
      //androidNotificationCallback: LocationCallbackHandler.notificationCallback,
      iosSettings: IOSSettings(accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 10),
      /*
      settings: LocationSettings(
          notificationChannelName: "Smart Response Locator - Responding",
          notificationTitle: "SmartResponse - Responding",
          notificationMsg: "Background location for SmartResponse",
          wakeLockTime: 20,
          autoStop: false,
          distanceFilter: 10,
          interval: 5),

       */
    );
  }

}