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

  Future<Placemark> getPlacemark(String ID, GeoPoint location) async {
    if(placemarks.containsKey(ID)) {
      print(" --retrieved dynamically the location for scene " + ID);
      return placemarks[ID];
    }
    else {
      try {
        print("---------- retrieving location from Geolocator for scene " + ID);
        List<Placemark> places = await Geolocator().placemarkFromCoordinates(
            location.latitude, location.longitude);
        placemarks[ID] = places[0];
        print(" -- retrieved");
        return places[0];
      }
      catch (e) {
        print("error in getPlacemark: " + e);
      }
    }
  }


  void clearData() {
    email = uid = 'PLACEHOLDER';
    userData = Profile(name: 'PLACEHOLDER', rank: 'PLACEHOLDER', department: 'PLACEHOLDER', email: 'PLACEHOLDER@PLACEHOLDER.com');
  }


  void updateData() async {
    final data = await Firestore.instance.collection('profiles').document(uid).get();
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