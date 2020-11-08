import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartresponse4/profile.dart';

class User {
  final String uid;

  User({ this.uid });

}



class EmailStorage {
  EmailStorage._privateConstructor();
  static final EmailStorage _instance = EmailStorage._privateConstructor();
  static EmailStorage get instance => _instance;

  String email = 'Placeholder';
  String uid = 'Placeholder';
  Profile userData;
  //  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map placemarks = {};

  Future<Placemark> getPlacemark(String sceneIdentifier, GeoPoint location) async {
    if(placemarks.containsKey(sceneIdentifier)) {
     // print("user.dart: --retrieved dynamically the location for scene " + sceneIdentifier);
     // print(" this one's name is : " + placemarks[sceneIdentifier].name);
      return placemarks[sceneIdentifier];
    }
    else {
      try {
       // print("user.dart: ---------- retrieving location from Geolocator for scene " + sceneIdentifier);
        List<Placemark> places = await Geolocator().placemarkFromCoordinates(
            location.latitude, location.longitude);
        placemarks[sceneIdentifier] = places[0];
        // print("user.dart:  -- retrieved");
        return places[0];
      }
      catch (e) {
        print("user.dart: error in getPlacemark: " + e);
      }
    }
    return null;
  }


  void clearData() {
    email = uid = 'PLACEHOLDER';
    userData = Profile(name: 'PLACEHOLDER', rank: 'PLACEHOLDER', department: 'PLACEHOLDER', email: 'PLACEHOLDER@PLACEHOLDER.com');
  }


  void updateData() async {
    print("user.dart: Updating data of EmailStorage using a get from the db");
    final data = await FirebaseFirestore.instance.collection('profiles').doc(uid).get();
    if(data.data != null) {
      userData = fromSnapshot(data);
    }
    else {
      userData = defaultProfile();
      print("user.dart updateData - ERROR - data broken");
    }

  }


  // Fetch email from logged in user on firebase
  /*
  _get() async {
    FirebaseUser user = await _auth.currentUser();
    String userEmail = user?.email ?? "placeholder";
    this.email = userEmail;
  }
  */


}