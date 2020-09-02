





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartresponse4/user.dart';

class Scene {
  final GeoPoint location;
  final Timestamp created;
  final String desc;
  final DocumentReference ref;
  Placemark placemark;
  Scene ({this.location, this.created, this.desc, this.ref});

  Future<String> getAddress() async {
    String address = "-loading address-";
    if(placemark == null) {
      placemark = await EmailStorage.instance.getPlacemark(this.ref.documentID, this.location);
    }

    if(placemark != null) {
      address = placemark.name + " " + placemark.thoroughfare + " " + placemark.administrativeArea + " " +
          placemark.postalCode;
    }
    print("returning this address " + address + " for scene " + ref.documentID);
    return address;
  }

  Future<String> getLocality({int version=0}) async {
//    return "1234567890abcefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz";
    if(placemark == null) {
      placemark = await EmailStorage.instance.getPlacemark(this.ref.documentID, this.location);
    }
    if(placemark == null) return "-loading place-";

    //print(places[0].toString() + " " + places[0].locality +  " " + places[0].administrativeArea);
    String shortName =
        ", " + placemark.administrativeArea.substring(0, 2) + "...";
    if (stateShortcut.containsKey(placemark.administrativeArea)) {
      shortName = ", " + stateShortcut[placemark.administrativeArea];
    }

    switch(version){
      case 0:
        return placemark.locality + shortName;
        break;
      case 1:
        return "[" +placemark.name +  " " + placemark.thoroughfare + "] " + placemark.locality + ", " + placemark.administrativeArea +" " +  " " + placemark.postalCode;
        break;
      default:
        return placemark.locality + shortName;
    }
  }
}


//TODO: could update this for more regions, but there is a shortcut to protect the card from overload
// if/when a new client comes aboard, we'll want to make sure their region is covered here.

final Map<String, String> stateShortcut = {
  "Maryland": "MD",
  "Delaware": "DE",
  "Pennsylvania": "PA",
  "Ohio": "OH",
  "Utah": "UT",
  "Tennessee": "TN",
  "North Carolina": "NC",
  "South Carolina": "SC",
  "Virginia": "VA",
  "West Virginia": "WV",
  "New Jersey": "NJ",
  "New York": "NY",
  "Vermont": "VT",
  "New Hampshire": "NH",
  "Maine": "ME",
  "Mississippi": "MS",
  "Colorado": "CO",
  "Florida": "FL",
  "Georgia": "GA",
  "Massachusetts": "MA",
  "Michigan": "MI",
  "Minnesota": "MN"
};