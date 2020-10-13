
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartresponse4/marker_data.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/scene.dart';


class CommandPosition {
  final String name;
  final String position;
  final String uid;
  final String documentID;
  final bool validUID;
  CommandPosition(this.name, this.position, this.validUID,{this.uid, this.documentID});
}


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
  final FirebaseFirestore _firestore;

  Repository(this._firestore) : assert(_firestore != null);

  Stream<List<CommandPosition>> getCommandPositions(String sceneIDIn) {
    return _firestore.collection("scenes/" + sceneIDIn + "/ICS").snapshots().map( (snapshot) {
      return snapshot.docs.map(commandPositionFromSnapshot).toList();
    });
  }


  Stream<List<Responder>> getResponders(String sceneIDIn) {
    return _firestore.collection('profiles').where("responding",isEqualTo: sceneIDIn).snapshots().map(
        (snapshot) {
          return snapshot.docs.map((doc) {
            return Responder(sceneIDIn, fromSnapshot(doc));
          }).toList();
        }
    );
  }

  Stream<List<Profile> > getSquadProfiles(String squadID) {
    return _firestore.collection('profiles').orderBy('rank', descending: false).where("squadID", isEqualTo: squadID).snapshots().map(
        (snapshot) {
          return snapshot.docs.map((doc) {
              return fromSnapshot(doc);
          }).toList();
        }
    );
  }

  void updateICS(String sceneID, CommandPosition cp)  async {
    await _firestore.collection("scenes/" + sceneID +"/ICS").add( {
      "name": cp.name,
      "position": cp.position,
      "validuid": cp.validUID,
      "uid": cp.uid,
    });
  }

  void removeCommandPosition(String sceneID, String docID)  {
    _firestore.doc("scenes/" + sceneID +"/ICS/"+docID).delete();
  }

}

CommandPosition commandPositionFromSnapshot(DocumentSnapshot doc) {
  String name = doc.data()['name'];
  String position = doc.data()['position'];
  bool goodUID = doc.data()['validuid'];
  String uid = doc.data()['uid'];
  String documentID = doc.id;

  return CommandPosition(name, position, goodUID, uid: uid, documentID: documentID);

}


Scene sceneFromSnapshot(DocumentSnapshot doc) {
  if(doc == null) return null;
  return Scene(
    location: doc.data()['location'] ?? '',
    created: doc.data()['created'] ?? '',
    desc: doc.data()['desc'] ?? ' ',
    units: doc.data()['units'] ?? 8,
    priority: doc.data()['priority'] ?? 3,
    ref: doc.reference,
  );
}


class DatabaseService {

  MarkerData myMarkers;
  final String uid;
  DatabaseService({ this.uid });

  // collection reference
  final CollectionReference profileCollection = FirebaseFirestore.instance.collection('profiles');
  final CollectionReference sceneCollection = FirebaseFirestore.instance.collection('scenes');
  final CollectionReference markerCollection = FirebaseFirestore.instance.collection('markers');


  Future createDBProfile(String email) async {
    //FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await profileCollection.doc(uid).set({
      'name': "",
      'rank': "",
      'department': "",
      'email': email,
      'location': GeoPoint(40.6892,-74.0445),
      'responding': "unbusy",
      'squadID': ""
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
    return await profileCollection.doc(uid).update({
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
    return snapshot.docs.map((doc){
      return fromSnapshot(doc);
    }).toList();
  }



  List<Marker> _markersFromSnapshot(QuerySnapshot snapshot) {

    return snapshot.docs.map((doc) {
      LatLng pos = LatLng(doc?.data()['loc']?.latitude ?? 0.0, doc?.data()['loc']?.longitude ?? 0.0);
      BitmapDescriptor myIcon = myMarkers.fire.iconBitmap;
      String documentString = doc?.data()['icon'] ?? "fire";
      if(myMarkers.myMarkerMap.containsKey(documentString)) {
        myIcon = myMarkers.myMarkerMap[documentString].iconBitmap;
      } else {
        switch (doc?.data()['icon'] ?? "fire") {
          case 'truck':
            myIcon = myMarkers.truck.iconBitmap;
            break;
          case 'star':
            myIcon = myMarkers.star.iconBitmap;
            break;
        }
      }
      return Marker (
              markerId: MarkerId(doc.id),
              position: pos,
              rotation: 0, //newLocalData.heading,
              draggable: false,
              zIndex: 2,
              anchor: Offset(0.5, 0.5),
              icon: myIcon,
              infoWindow: InfoWindow(
                title: doc?.data()['desc'] ?? "Description Empty",
                snippet: "placed By: " + (doc?.data()['placedby'] ?? "Unknown"),
              )
      );
    }).toList();
  }



  List<Scene> _sceneListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
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
    return profileCollection.doc(uid).snapshots().map(fromSnapshot);
 }


}