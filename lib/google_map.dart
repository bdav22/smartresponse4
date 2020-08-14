import 'dart:async';
import 'dart:typed_data';
import 'dart:isolate';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/google_route.dart';
import 'package:smartresponse4/marker_chooser.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/loading.dart';
import 'package:smartresponse4/marker_data.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_settings.dart';
import 'package:location_permissions/location_permissions.dart' as location_permissions;
import 'package:smartresponse4/utility.dart';


import 'file_manager.dart';
import 'location_callback_handler.dart';
import 'location_service_repository.dart';






class MyMapPage extends StatefulWidget {
  MyMapPage({Key key, this.title, this.scene}) : super(key: key);
  final String title;
  final Scene scene;
  @override
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  LatLng _currentLocation = LatLng(39.2191, -76.07);
  LatLng _lastLocation = LatLng(39.220, -76.0632);
  bool _bgLocationOn = false;
  Marker _pin;
  Marker _marker; //current location
  Circle _circle; //accuracy of current location
  GoogleMapController _controller;
  bool _trackerOn = false;
  bool _cameraTrackerOn = false;
  bool _placeMarkerOn = false;
  MyMarker selectedPlacingMarker;
  List<Marker> individualMarkers = [];

  //Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  Set<Polyline> polyline = {};
  List<LatLng> routeCoords;
  final googleMapsRoutes = GoogleMapsRoutes();
  final LatLng secnd = LatLng(39.2098, -76.0658);


  static CameraPosition initialLocation;
  //Background_locator
  ReceivePort port = ReceivePort(); //isolate import

  @override
  void initState() {
    super.initState();

    if(widget.scene != null) {
      initialLocation = CameraPosition(
        target: LatLng(widget.scene.location.latitude, widget.scene.location.longitude),
        zoom: 18,
      );
    } else {
      initialLocation = CameraPosition(
        target: _currentLocation,
        zoom: 10,
      );
    }
    selectedPlacingMarker = null;

    if (ui.IsolateNameServer.lookupPortByName(
        LocationServiceRepository.isolateName) !=
        null) {
      ui.IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    ui.IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    port.listen(
          (dynamic data) async {
                  // print("got data "); // I'm not precisely sure why we need to listen to this port?
      },
    );
    initPlatformState();
  }


  void _onMapCreated(GoogleMapController controller) {

    setState(() {
      _controller = controller;
    });
  }



  Future<void> initPlatformState() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    final logStr = await FileManager.readLogFile();
    print(logStr);
    print('Initialization done');
    final _isRunning = await BackgroundLocator.isRegisterLocationUpdate();
    print('Running ${_isRunning.toString()}');
  }








  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }


  void updateMarkerAndCircle(LocationData newLocalData) {
    LatLng latLng = LatLng(newLocalData.latitude, newLocalData.longitude);
    var rotation = _cameraTrackerOn  ? 0.0 : newLocalData.heading;
    this.setState(() {
      _marker = Marker(
          markerId: MarkerId("home"),
          position: latLng,
          rotation: rotation, //newLocalData.heading,
          draggable: false,
          zIndex: 2,
          anchor: Offset(0.5, 0.5),
          icon: CustomMarkers.instance.myMarkerData.truck.iconBitmap);
      _circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latLng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void resetCamera() {
    if (_controller != null) {
      _controller.animateCamera(CameraUpdate.newCameraPosition(
          new CameraPosition(
              bearing: 0,
              target:
                  LatLng(_currentLocation.latitude, _currentLocation.longitude),
              tilt: 0,
              zoom: 14.00)));
    }
  }



  void toggleBGLocation() async {
    setState(() {
      _bgLocationOn = !_bgLocationOn;
    });
    if(_bgLocationOn) {
      _onStart();
    }
    else {
      _onStop();
    }
  }

  void _onStop() {
    BackgroundLocator.unRegisterLocationUpdate();
    setState(() {
      // isRunning = false;
//      lastTimeLocation = null;
//      lastLocation = null;
    });
  }

  void _onStart() async {
    if (await _checkLocationPermission()) {
      _startLocator();
      setState(() {
       // isRunning = true;
       // lastTimeLocation = null;
       // lastLocation = null;
      });
    } else {
      // show error
    }
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

  void _startLocator() {
    Map<String, dynamic> data = {'countInit': 1, 'uid': EmailStorage.instance.uid};
    BackgroundLocator.registerLocationUpdate(
      LocationCallbackHandler.callback,
      initCallback: LocationCallbackHandler.initCallback,
      initDataCallback: data,
/*
        Comment initDataCallback, so service not set init variable,
        variable stay with value of last run after unRegisterLocationUpdate
 */
      disposeCallback: LocationCallbackHandler.disposeCallback,
      androidNotificationCallback: LocationCallbackHandler.notificationCallback,
      settings: LocationSettings(
          notificationChannelName: "Location tracking service",
          notificationTitle: "Start Location Tracking example",
          notificationMsg: "Track location in background example",
          wakeLockTime: 20,
          autoStop: false,
          distanceFilter: 10,
          interval: 5),
    );
  }

  void togglePlaceMarker() async { //changes placemarkeron state
    setState(() {
          _placeMarkerOn = !_placeMarkerOn;
    });
  }

  void toggleCameraTracking() async {
    if (_cameraTrackerOn) { // this is about to be turned off
      resetCamera();
    }
    setState(() {
      _cameraTrackerOn = !_cameraTrackerOn;
    });

  }

  void addMarker(LatLng latlng) { //removed async here...no longer needed? - may need to add it back to add to fire base
    DatabaseService().addDBMarker(selectedPlacingMarker.shortName, latlng, desc: selectedPlacingMarker.desc);

    setState(() {
        _pin = Marker(
            markerId: MarkerId("pin"),
            position: latlng,
            rotation: 0, //newLocalData.heading,
            draggable: false,
            zIndex: 2,
            anchor: Offset(0.5, 0.5),
            icon: selectedPlacingMarker.iconBitmap);
        _placeMarkerOn = false;
        //individualMarkers.add(_pin);
    });



  }

  void updateStateWithCurrentLocation(LatLng locationIn) async {

    double dInMeters = await Geolocator().distanceBetween(_currentLocation.latitude,_currentLocation.longitude,_lastLocation.latitude, _lastLocation.longitude);
    setState(() {
      _currentLocation = LatLng(locationIn.latitude, locationIn.longitude);
    });

    print(dInMeters.toString() + " distance since last call to location changed ");

    if(dInMeters > 1) { //slow down route updates ... ? could just turn them off and force them through the
      _lastLocation = _currentLocation;
      print("updating navigation...");
      if(widget.scene.turnOnNavigation == true) {
        Set<Polyline> _poly = await googleMapsRoutes.sendRequest(_currentLocation,   asLatLng(widget.scene.location) );
        setState(() {
          polyline = _poly;
        });
      }
      //let background push to firestore ....
       /*GeoPoint geoPoint = GeoPoint(_currentLocation.latitude, _currentLocation.longitude);
          await Firestore.instance.collection("profiles").document(
          EmailStorage.instance.uid).updateData({'location': geoPoint});
        */
    } //end if dInMeters -- if its less than 30 no need to update the route is it?
  }

  void getCurrentLocation() async {

    setState(() {
      _trackerOn = !_trackerOn; //swap true and false
      _cameraTrackerOn = _trackerOn; //follow suit
    });
    if (!_cameraTrackerOn) {
      resetCamera();
    }

    if (!_trackerOn) {
      //if its false, then we're turning it off here
      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }
      resetCamera();
      return;
    }

    try {
      await CustomMarkers.instance.getCustomMarkers(); //make sure custommarkers is up to date here -asset loading and resizing
      var location = await _locationTracker.getLocation();
      updateMarkerAndCircle(location);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged().listen((newLocalData) async {
        if (_controller != null) {
            _currentLocation =  LatLng(newLocalData.latitude, newLocalData.longitude);
            if(_currentLocation != _lastLocation) {
              print('Location changed: ${_currentLocation.latitude}  ${_currentLocation.longitude} -- ${EmailStorage.instance.uid}');
              LatLng ll = LatLng(newLocalData.latitude, newLocalData.longitude);

              updateStateWithCurrentLocation(ll);
            }
          if (_cameraTrackerOn) {
            _controller.animateCamera(CameraUpdate.newCameraPosition(
                new CameraPosition(
                    bearing: newLocalData.heading,
                    target:
                        LatLng(newLocalData.latitude, newLocalData.longitude),
                    tilt: 0,
                    zoom: 18.00)));
          }
          updateMarkerAndCircle(newLocalData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    debugPrint("Disposing of Location Subscription");
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    if(_marker != null) { //remove this when background service is on
      individualMarkers.add(_marker);
    }
    if(_pin != null) {
      individualMarkers.add(_pin);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Map Tracker"),
        ),
        body: Stack(
          children: <Widget>[
            FutureBuilder<MarkerData>(
              future: CustomMarkers.instance.getCustomMarkers(),
              builder: (BuildContext context, AsyncSnapshot<MarkerData> customMarkersData) {
                if(customMarkersData.hasData) {
                 return StreamProvider<List<Marker>>.value(
                  value: DatabaseService().markers(customMarkersData.data),
                  updateShouldNotify: (_, __) => true,
                  child: StreamProvider<List<Scene>>.value(
                    value: DatabaseService().scenes,
                    updateShouldNotify: (_, __) => true,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance.collection("profiles").snapshots(),
                        builder: (context, snapshot) {
                          final scenes = Provider.of<List<Scene>>(context) ?? [];
                          final markersDB = Provider.of<List<Marker>>(context) ?? [];
                          if (snapshot.hasData) {
                            List<DocumentSnapshot> docs = snapshot.data.documents;
                            docs.removeWhere( (DocumentSnapshot doc) => doc['email'] == EmailStorage.instance.email);
                            List<Marker> markers = docs.map(
                                    (doc) => Marker(
                                  markerId: MarkerId(doc.documentID),
                                  position: LatLng(doc['location']?.latitude ?? 0.0, doc['location']?.longitude ?? 0.0),
                                  icon: customMarkersData.data.truck.iconBitmap, //TODO: map this to whatever is stored in profiles
                                      infoWindow: InfoWindow(title: doc['name'], snippet: doc['department']),
                                )
                            ).toList();

                            List<Marker> sceneMarkers = [];
                            for ( Scene scene in scenes ){
                              sceneMarkers.add(Marker(
                                markerId: MarkerId(scene.desc),
                                position: LatLng(scene.location.latitude, scene.location.longitude),
                                icon: customMarkersData.data.fire.iconBitmap, //TODO: perhaps allow dispatch to decide this icon in some way.
                                infoWindow: InfoWindow(title: "Reported Alert", snippet: scene.desc),
                              )
                              );
                            }

                            //List<Marker> updatedMarkers = updateAllMarkers(markersDB);
                            //                            markers.addAll(updatedMarkers);

                            markers.addAll(markersDB);
                            markers.addAll(sceneMarkers);
                            markers.addAll(individualMarkers);


                            return Container(
                              child: GoogleMap(
                                mapType: MapType.hybrid,
                                initialCameraPosition: initialLocation,
                                markers: markers?.toSet() ?? Set.of([_marker]),
                                circles: Set.of((_circle != null) ? [_circle] : []),
                                onTap: (latlng) {
                                  if (_placeMarkerOn) {
                                    addMarker(latlng);
                                    print('${latlng.latitude}, ${latlng.longitude}');
                                  }
                                },
                                onMapCreated: _onMapCreated,
                                polylines: polyline,
                              ),
                            );
                          } //snapshot has data
                          return Loading();
                        }
                    ),
                  ),
                );
                } else {
                     return Text("Loading...");
                  }
                }
                ),

                ],
                ),
        floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              FloatingActionButton(
              child: Icon(Icons.location_searching),
              heroTag: null,
              backgroundColor: (_trackerOn ? Colors.blue : Colors.grey),
              onPressed: () {
                getCurrentLocation();
              }),
              SizedBox(width: 20),
              FloatingActionButton(
                  child: Icon(Icons.camera_alt),
                  heroTag: null,
                  backgroundColor: (_cameraTrackerOn ? Colors.blue : Colors.grey),
                  onPressed: () {
                    toggleCameraTracking();
                  }),
              SizedBox(width: 20),
              FloatingActionButton(
                  child: Icon(Icons.navigation),
                  heroTag: null,
                  backgroundColor: (_placeMarkerOn ? Colors.blue : Colors.grey),
                  onPressed: () async {

                    if(!_placeMarkerOn) { // it is about to be toggled on
                      selectedPlacingMarker = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            ChooseMarker(markers: CustomMarkers.instance.myMarkerData)),
                      );
                      print("User selected the following marker: " +
                          selectedPlacingMarker.commonName + " -- " + selectedPlacingMarker.desc);
                    }
                    togglePlaceMarker();
                  }),
              SizedBox(width: 20),
              FloatingActionButton(
                  child: Icon(Icons.error),
                  heroTag: null,
                  backgroundColor: (_bgLocationOn ? Colors.blue : Colors.grey),
                  onPressed: () {
                    toggleBGLocation();
                  }),
        ]),
    );
  }
}
