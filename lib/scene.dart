





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Scene {
  final GeoPoint location;
  final Timestamp created;
  final String desc;
  final DocumentReference ref;
  String address = "unknown";
  String locality = "unknown"; //TODO harden this for ios
  Scene ({this.location, this.created, this.desc, this.ref});

  Future<String> getAddress() async {
    if(address == "unknown") {
      try {
        List<Placemark> places = await Geolocator().placemarkFromCoordinates(
            this.location.latitude, this.location.longitude);
        address = places[0].name + " " + places[0].thoroughfare + " " + places[0].administrativeArea + " " +
            places[0].postalCode;
      } catch(e) {
        print(e);
      }
    }
    return address;
  }

  Future<String> getLocality({int version=0}) async {
//    return "1234567890abcefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz";
    List<Placemark> places = await Geolocator().placemarkFromCoordinates(
        this.location.latitude, this.location.longitude);
    //print(places[0].toString() + " " + places[0].locality +  " " + places[0].administrativeArea);
    String shortName =
        ", " + places[0].administrativeArea.substring(0, 2) + "...";
    if (stateShortcut.containsKey(places[0].administrativeArea)) {
      shortName = ", " + stateShortcut[places[0].administrativeArea];
    }

    switch(version){
      case 0:
        return places[0].locality + shortName;
        break;
      case 1:
        return "[" +places[0].name +  " " + places[0].thoroughfare + "] " + places[0].locality + ", " + places[0].administrativeArea +" " +  " " + places[0].postalCode;
        break;
      default:
        return places[0].locality + shortName;
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