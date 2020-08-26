

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartresponse4/marker_data.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/scene.dart';


class Responder {
  final String sceneID;
  final Profile profile;
  Responder(this.sceneID, this.profile);
  String toString() {
    return "uid: " + (this?.profile?.uid??"null")
        + " scene:" + (this?.sceneID ?? "null")
        + " name:" + (this?.profile?.name ?? "null")
        + " loc:" + (profile?.location?.latitude?.toString() ?? "null") + "," + (profile?.location?.latitude?.toString() ?? "null");
  }
}

class Repository {
  final Firestore _firestore;

  Repository(this._firestore) : assert(_firestore != null);


  Stream<List<Responder>> getResponders(String sceneIDIn) {
    return _firestore.collection('profiles').where("responding",isEqualTo: sceneIDIn).snapshots().map(
        (snapshot) {
          return snapshot.documents.map((doc) {

            return Responder(sceneIDIn, fromSnapshot(doc));
          }).toList();
        }
    );
  }

  Stream<List<Profile> > getSquadProfiles(String squadID) {
    return _firestore.collection('profiles').where("squadID", isEqualTo: squadID).snapshots().map(
        (snapshot) {
          return snapshot.documents.map((doc) {
              return fromSnapshot(doc);
          }).toList();
        }
    );
  }

}



Scene sceneFromSnapshot(DocumentSnapshot doc) {
  return Scene(
    location: doc.data['location'] ?? '',
    created: doc.data['created'] ?? '',
    desc: doc.data['desc'],
    ref: doc.reference,
  );
}


class DatabaseService {

  MarkerData myMarkers;
  final String uid;
  DatabaseService({ this.uid });

  // collection reference
  final CollectionReference profileCollection = Firestore.instance.collection('profiles');
  final CollectionReference sceneCollection = Firestore.instance.collection('scenes');
  final CollectionReference markerCollection = Firestore.instance.collection('markers');


  Future createDBProfile(String email) async {
    //FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await profileCollection.document(uid).setData({
      'name': "New Name",
      'rank': "New Rank",
      'department': "New Department",
      'email': email,
      'location': GeoPoint(0,0),
      'responding': "unbusy",
      'squadID': "-"
    });
  }

  Future addDBMarker(String name, LatLng loc, {String desc, String placedBy}) async {
    markerCollection.add(
        {
          'desc': desc ?? "uidnow",
          'loc': GeoPoint(loc.latitude, loc.longitude),
          'icon':  name,
          'placedby': placedBy,
      }
    );

  }

  Future updateProfile(Profile p) async {
    return await profileCollection.document(uid).updateData({
      'name': p.name,
      'rank': p.rank,
      'department': p.department,
      'responding': p.responding,
      'squadID': p.squadID,
      'location': p.location,
    });
  }




  // profile list from snapshot
  List<Profile> _profileListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return fromSnapshot(doc);
    }).toList();
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
              infoWindow: InfoWindow(
                title: doc?.data['desc'] ?? "Description Empty",
                snippet: "placed By: " + (doc?.data['placedby'] ?? "Unknown"),
              )
      );
    }).toList();
  }



  List<Scene> _sceneListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
        return sceneFromSnapshot(doc);
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
    return sceneCollection.orderBy('created', descending: true).snapshots().map(_sceneListFromSnapshot);
  }

 Stream<Profile> get profile {
    return profileCollection.document(uid).snapshots().map(fromSnapshot);
 }


}