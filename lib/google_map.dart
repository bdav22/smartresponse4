import 'dart:async';
import 'dart:typed_data';
import 'dart:isolate';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/loading.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_settings.dart';
import 'package:location_permissions/location_permissions.dart' as location_permissions;


import 'file_manager.dart';
import 'location_callback_handler.dart';
import 'location_service_repository.dart';

//void main() => runApp(MyApp());

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyMapPage(title: 'Tracked Icon'),
    );
  }
}

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
  LatLng _currentLocation = LatLng(38.9, -76.3);
  LatLng _lastLocation = LatLng(38.9, -76.3);
  bool _bgLocationOn = false;
  Marker _pin;
  Marker marker;
  Circle circle;
  GoogleMapController _controller;
  bool _trackerOn = false;
  bool _cameraTrackerOn = false;
  bool _placeMarkerOn = false;
  BitmapDescriptor starOfLifeIcon, fireTruckIcon, fireIcon;

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

    setCustomMapPin();

    if (IsolateNameServer.lookupPortByName(
        LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    port.listen(
          (dynamic data) async {
        print("got data ");
      },
    );
    initPlatformState();
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

  void setCustomMapPin() async {
    starOfLifeIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/car_icon.png'
    );

    fireTruckIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/firetruck50.png'
    );

    fireIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio:
        2.5),
        'assets/fire50.png'
    );
  }




  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerandCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    var rotation = _cameraTrackerOn  ? 0.0 : newLocalData.heading;
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: rotation, //newLocalData.heading,
          draggable: false,
          zIndex: 2,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
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
      onStop();
    }
  }

  void onStop() {
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



  void togglePlaceMarker() async {
    setState(() {
      _placeMarkerOn = !_placeMarkerOn;
    });
  }

  void toggleCameraTracking() async {
    _cameraTrackerOn = !_cameraTrackerOn;
    if (!_cameraTrackerOn) {
      resetCamera();
    }
  }

  void addMarker(LatLng latlng) async {
    Uint8List imageData = await getMarker();
    setState(() {
        _pin = Marker(
            markerId: MarkerId("pin"),
            position: latlng,
            rotation: 0, //newLocalData.heading,
            draggable: false,
            zIndex: 2,
            anchor: Offset(0.5, 0.5),
            icon: BitmapDescriptor.fromBytes(imageData));
        _placeMarkerOn = false;
    });

  }



  void updateStateWithCurrentLocation(LatLng locationIn) async {

    double dInMeters = await Geolocator().distanceBetween(_currentLocation.latitude,_currentLocation.longitude,_lastLocation.latitude, _lastLocation.longitude);
    print(dInMeters);
    if(dInMeters > 30) {
      print("updating");
      setState(() {
        _currentLocation =
            LatLng(locationIn.latitude, locationIn.longitude);
        _lastLocation = _currentLocation;
      });




      GeoPoint geoPoint = GeoPoint(_currentLocation.latitude, _currentLocation.longitude);
      await Firestore.instance.collection("profiles").document(
          EmailStorage.instance.uid).updateData({'location': geoPoint});
    }
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
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerandCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged().listen((newLocalData) {
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
          updateMarkerandCircle(newLocalData, imageData);
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
    List<Marker> indvidualMarkers = [];

    if(_pin != null) {
      indvidualMarkers.add(_pin);
    }
    if(marker != null) {
      indvidualMarkers.add(marker);
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Map Tracker"),
        ),
        body: Stack(
          children: <Widget>[
        StreamProvider<List<Scene>>.value(
            value: DatabaseService().scenes,
            child: StreamBuilder<QuerySnapshot>(
               stream: Firestore.instance.collection("profiles").snapshots(),
                builder: (context, snapshot) {
                 if (snapshot.hasData) {
                    List<DocumentSnapshot> docs = snapshot.data.documents;
                    List<Marker> markers = docs.map(
                            (doc) => Marker(
                          markerId: MarkerId(doc.documentID),
                          position: LatLng(doc['location']?.latitude ?? 0.0, doc['location']?.longitude ?? 0.0),
                              icon: fireTruckIcon,
                        )
                    ).toList();
                    final scenes = Provider.of<List<Scene>>(context) ?? [];
                    List<Marker> sceneMarkers = [];
                    for ( Scene scene in scenes ){
                     sceneMarkers.add(Marker(
                       markerId: MarkerId(scene.desc),
                       position: LatLng(scene.location.latitude, scene.location.longitude),
                       icon: fireIcon,)
                     );
                    }
                    markers.addAll(sceneMarkers);
                    markers.addAll(indvidualMarkers);

                  return Container(
          child: GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: initialLocation,
            markers: markers?.toSet() ?? Set.of([marker]),
            circles: Set.of((circle != null) ? [circle] : []),
            onTap: (latlng) {
              if (_placeMarkerOn) {
                addMarker(latlng);
                print('${latlng.latitude}, ${latlng.longitude}');
              }
            },
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
          ),
        );
      }
      return Loading();
    }
    ),
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
                  onPressed: () {
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

/*import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartresponse4/loading.dart';


class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  bool mapToggle = false;

  var currentLocation;
  var lastLocation;

  GoogleMapController mapController;

  void initState() {
    super.initState();

    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

      print("init state updates?");
    //StreamSubscription<Position> positionStream =

       Geolocator().getPositionStream(locationOptions).listen(
            (Position position) {
          print(position == null ? 'Unknown' : 'pos: ' + position.latitude.toString() + ', ' + position.longitude.toString());
          setState(() { currentLocation = position; });
        });


    Geolocator().getCurrentPosition().then((currloc) {
      print("when is this called?");
      print(currloc);
      setState(() {
        currentLocation = currloc;
        mapToggle = true;
      });
    });
  }

  void getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print('p2: ' + position.toString());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("profiles").snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  if(lastLocation != currentLocation) {
                    lastLocation = currentLocation;
                    //Firestore.instance.collection("profiles").document(EmailStorage.instance.uid).updateData({'location': lastLocation});
                  }
                  List<DocumentSnapshot> docs = snapshot.data.documents;
                  List<Marker> markers = docs.map(
                      (doc) => Marker(
                        markerId: MarkerId(doc.documentID),
                        position: LatLng(doc['location']?.latitude ?? 0.0, doc['location']?.longitude ?? 0.0),
                      )
                  ).toList();

                  //for(var i = 0; i < markers.length; i++) {
                  //  print(markers[i].position.latitude);
                  //}

                  return Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height - 80.0,
                      width: double.infinity,
                      child: mapToggle ?
                      GoogleMap(
                        initialCameraPosition: CameraPosition(target: LatLng(
                            currentLocation.latitude,
                            currentLocation.longitude), zoom: 10),
                        onMapCreated: onMapCreated,
                        myLocationEnabled: true,
                        markers: markers.toSet(),
                        mapType: MapType.hybrid,
                      ) :
                      Center(child:
                      Text('Loading.. Please wait..',
                        style: TextStyle(
                            fontSize: 20.0
                        ),))
                  );
                }
                else {
                  return Loading();
                  }
                }
                ),
            ]
          )
        ],
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}


 */
