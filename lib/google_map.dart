import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/google_route.dart';
import 'package:smartresponse4/hydrant.dart';
import 'package:smartresponse4/map_location.dart';
import 'package:smartresponse4/marker_chooser.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/loading.dart';
import 'package:smartresponse4/marker_data.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/profile_tile.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/user.dart';


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
  bool _hydrantsOn = false;
  bool _hydrantsFirst = true;
  MyMarker selectedPlacingMarker;
  List<Marker> individualMarkers = [];
  List<Marker> _hydrantMarkers = [];

  //Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  Set<Polyline> polyline = {};
  List<LatLng> routeCoords;
  final googleMapsRoutes = GoogleMapsRoutes();
  final LatLng secnd = LatLng(39.2098, -76.0658);

  static CameraPosition initialLocation;
  //Background_locator


  @override
  void initState() {
    super.initState();
    if(widget.scene != null) {
      initialLocation = CameraPosition(
        target: LatLng(widget.scene.location.latitude, widget.scene.location.longitude),  zoom: 18,  );
    } else {
//      getCurrentLocation();
      initialLocation = CameraPosition(target: _currentLocation,  zoom: 5,    );
    }
    selectedPlacingMarker = null;
  }


  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
    });
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
          icon: CustomMarkers.instance.myMarkerData.truck.iconBitmap,
          infoWindow: InfoWindow(title: "This is Me", snippet: EmailStorage.instance.userData.name),
      );
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

  void toggleHydrants() async {
    await CustomMarkers.instance.getCustomMarkers();
    if(CustomMarkers.instance.loaded == false) {
      print("google_map.dart: ERROR HYDRANTS WONT LOAD");
      return;
    }
    if(_hydrantsFirst == true) {
      _hydrantsFirst = false;
      List<Marker> newHydrants = [];
      for (LatLng location in hydrantLocations) {
        newHydrants.add(Marker(
          markerId: MarkerId(location.toString()),
          position: location,
          icon: CustomMarkers.instance.myMarkerData.hydrant.iconBitmap,
        ));
      }
      setState( () {
        _hydrantMarkers = newHydrants;
      });

      print("google_map.dart: hydrant length:" +_hydrantMarkers.length.toString());
    }

    setState(() {
      _hydrantsOn = !_hydrantsOn;
    });
  }


  void toggleBGLocation() async {

    if(!_bgLocationOn) { //its about to be turned on though
      BackgroundLocationInterface().onStart("default in toggleBG");
    }
    else {
      BackgroundLocationInterface().onStop();
    }
    setState(() {
      _bgLocationOn = !_bgLocationOn;
    });
  }



  void togglePlaceMarker() async { //changes place-marker-on state
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
    DatabaseService().addDBMarker(selectedPlacingMarker.shortName, latlng, desc: selectedPlacingMarker.desc, placedBy: EmailStorage.instance.userData.name);

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
    setState(() {
      _currentLocation = LatLng(locationIn.latitude, locationIn.longitude);
    });
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
              print('google_map.dart: Location changed: ${_currentLocation.latitude}  ${_currentLocation.longitude} -- ${EmailStorage.instance.uid}');
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
          title: Text(""),
          backgroundColor: appColorMid,
        ),
        body: Stack(
          children: <Widget>[
            FutureBuilder<MarkerData>(
              future: CustomMarkers.instance.getCustomMarkers(),
              builder: (BuildContext context, AsyncSnapshot<MarkerData> customMarkersData) {
                if(customMarkersData.hasData) {
                 return StreamProvider<List<Marker>>.value(
                  value: DatabaseService().markers(customMarkersData.data),   //get all the assets loaded up
                  updateShouldNotify: (_, __) => true,
                  child: StreamProvider<List<Scene>>.value(
                    value: DatabaseService().scenes,  //get all the scenes for markers
                    updateShouldNotify: (_, __) => true,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection("profiles").snapshots(), //get all the people with the app for the moment
                        builder: (context, snapshot) {
                          final scenes = Provider.of<List<Scene>>(context) ?? [];
                          final markersDB = Provider.of<List<Marker>>(context) ?? [];
                          if (snapshot.hasData) {
                            List<DocumentSnapshot> docs = snapshot.data.docs;
                            //IF YOU WANT TO REMOVE PERSONS OWN instance you can use this, but I don't recmomend
                            //docs.removeWhere( (DocumentSnapshot doc) => doc['email'] == EmailStorage.instance.email);
                            List<Marker> markers = docs.map(
                                    (doc) => Marker(
                                  markerId: MarkerId(doc.id),
                                  position: LatLng(doc.data()['location']?.latitude ?? 0.0, doc.data()['location']?.longitude ?? 0.0),
                                  icon: customMarkersData.data.truck.iconBitmap, //TODO: map this to whatever is stored in profiles
                                  infoWindow: InfoWindow(title: doc.data()['name'], snippet: doc.data()['department'],
                                  onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileTile(profile: fromSnapshot(doc))));
/*                                      fromProfile(name: doc['name'],
                                      rank: doc['rank'], department:  doc['department'], email: doc['email'], uid: doc.documentID, location: doc['location'],
                                      responding: doc['responding'], squadID: doc['squadID']))));

 */
                                  },
                                  ),
                                )
                            ).toList();

                            List<Marker> sceneMarkers = [];
                            for ( Scene scene in scenes ){
                              sceneMarkers.add(Marker(
                                markerId: MarkerId(scene.desc),
                                position: LatLng(scene.location.latitude, scene.location.longitude),
                                icon: customMarkersData.data.fire.iconBitmap, //TODO: perhaps allow dispatch to decide this icon in some way.
                                infoWindow: InfoWindow(title: "Reported Alert", snippet: scene.desc,
                                onTap: () {
                                      Navigator.pushNamed(context, '/FullSceneTile',
                                        arguments: scene);
                                   },
                                ),
                              )
                              );
                            }

                            if(_hydrantsOn == true ) {
                              markers.addAll(_hydrantMarkers);
                            }

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
                                    print('google_map.dart - marker placed at ${latlng.latitude}, ${latlng.longitude}');
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              FloatingActionButton(
              child: Icon(Icons.navigation),
              heroTag: null,
              backgroundColor: (_trackerOn ? Colors.blue : Colors.brown),
              onPressed: () {
                getCurrentLocation();
              }),
              SizedBox(width: 20),
              /*
              FloatingActionButton(
                  child: Icon(Icons.camera_alt),
                  heroTag: null,
                  backgroundColor: (_cameraTrackerOn ? Colors.blue : Colors.grey),
                  onPressed: () {
                    toggleCameraTracking();
                  }),
              SizedBox(width: 20),
               */
              FloatingActionButton(
                  child: Icon(Icons.pin_drop),
                  heroTag: null,
                  backgroundColor: (_placeMarkerOn ? Colors.blue :  Colors.brown),
                  onPressed: () async {

                    if(!_placeMarkerOn) { // it is about to be toggled on
                      selectedPlacingMarker = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            ChooseMarker(markers: CustomMarkers.instance.myMarkerData)),
                      );
                      print("google_map.dart - User selected the following marker: " +
                          (selectedPlacingMarker?.commonName??"None selected") + " -- " +
                          (selectedPlacingMarker?.desc??"No Description")
                      );
                    }
                    if(selectedPlacingMarker?.desc != null) {
                      togglePlaceMarker();
                    }
                  }),
              SizedBox(width: 20),
              FloatingActionButton(
                  child: Icon(Icons.account_balance),
                  heroTag: null,
                  backgroundColor: (_hydrantsOn ? Colors.blue :  Colors.brown),
                  onPressed: () async {
                    toggleHydrants();
                    //toggleBGLocation();
                  }),
        ]),
    );
  }
}
