import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartresponse4/marker_data.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/user.dart';
import 'package:smartresponse4/scene.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {

  MarkerData myMarkers;
  final String uid;
  DatabaseService({ this.uid });

  // collection reference
  final CollectionReference profileCollection = Firestore.instance.collection('profiles');
  final CollectionReference sceneCollection = Firestore.instance.collection('scenes');
  final CollectionReference markerCollection = Firestore.instance.collection('markers');


  Future createDBProfile() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await profileCollection.document(uid).setData({
      'name': "New Name",
      'rank': "New Rank",
      'department': "New Department",
      'email': user.email,
      'location': GeoPoint(0,0),
    });
  }

  Future addDBMarker(String name, LatLng loc, {String desc}) async {
    markerCollection.add(
        {
          'desc': desc ?? "uidnow",
          'loc': GeoPoint(loc.latitude, loc.longitude),
          'icon':  name,
      }
    );

  }

  Future updateUserData(String name, String rank, String department, String email) async {

    return await profileCollection.document(uid).updateData({
      'name': name,
      'rank': rank,
      'department': department,
      'email': email,
    });
  }

  // userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      name: snapshot.data['name'],
      rank: snapshot.data['rank'],
      department: snapshot.data['department'],
      email: snapshot.data['email']
    );
  }

  // profile list from snapshot
  List<Profile> _profileListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return Profile(
        name: doc.data['name'] ?? '',
        rank: doc.data['rank'] ?? '',
        department: doc.data['department'] ?? '',
        uid: doc.documentID,
        email: doc.data['email']
      );
    }).toList();
  }


  Future<MarkerData> getCustomMarkers() async {
    BitmapDescriptor starOfLifeIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/car_icon.png'
    );
    MyMarker star = MyMarker(iconBitmap: starOfLifeIcon, image: Image.asset('assets/car_icon.png'), commonName: "Star of Life");


    BitmapDescriptor fireTruckIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/firetruck50.png'
    );
    MyMarker truck = MyMarker(iconBitmap: fireTruckIcon, image: Image.asset('assets/firetruck50.png'), commonName: "Fire Engine");

    BitmapDescriptor fireIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(100,100)), //TODO: this doesn't seem to work?
        'assets/fire50.png'
    );
    MyMarker fire = MyMarker(iconBitmap: fireIcon, image: Image(image: AssetImage('assets/fire50.png')), commonName: "Fire/Flames");
    return MarkerData(star: star, truck: truck, fire: fire);
  }

  List<Marker> _markersFromSnapshot(QuerySnapshot snapshot) {

    return snapshot.documents.map((doc) {
      LatLng pos = LatLng(doc?.data['loc']?.latitude ?? 0.0, doc?.data['loc']?.longitude ?? 0.0);
      BitmapDescriptor myIcon = myMarkers.fire.iconBitmap;
      switch(doc?.data['icon'] ?? "fire") {
        case 'truck':
          myIcon = myMarkers.truck.iconBitmap;
          break;
        case 'star':
          myIcon = myMarkers.star.iconBitmap;
          break;
      }
      return Marker (
              markerId: MarkerId(doc.documentID),
              position: pos,
              rotation: 0, //newLocalData.heading,
              draggable: false,
              zIndex: 2,
              anchor: Offset(0.5, 0.5),
              icon: myIcon,
      );
    }).toList();
  }

  List<Scene> _sceneListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return Scene(
          location: doc.data['location'] ?? '',
          created: doc.data['created'] ?? '',
          desc: doc.data['desc'],
      );
    }).toList();
  }

  Stream<List<Marker>> markers(MarkerData myMarkers) {
    this.myMarkers = myMarkers;
    return markerCollection.snapshots().map(_markersFromSnapshot);
  }

  //get profiles stream
  Stream<List<Profile>> get profiles {
    return profileCollection.snapshots()
        .map(_profileListFromSnapshot);
  }

  Stream<List<Scene>> get scenes {
    return sceneCollection.snapshots().map(_sceneListFromSnapshot);
  }


//get user doc stream
  Stream<UserData> get userData {
    return profileCollection.document(uid).snapshots()
        .map(_userDataFromSnapshot);
  }

}