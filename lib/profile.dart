import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {

  final String name;
  final String rank;
  final String department;
  final String email;
  final String uid;
  final GeoPoint location;
  final String responding;
  final String squadID;
  final String icon;
  final String equipment;
  final String token;

  Profile({ this.name, this.rank, this.department, this.email, this.uid, this.location, this.responding, this.squadID, this.icon, this.equipment, this.token});
}

Profile defaultProfile() {
  return Profile(
    name: "NoName",
    rank: "NoRank",
    department: "NoDept",
    email: "NoEmail",
    uid:"ERROR",
    location: GeoPoint(39.2191, -76.07),
    responding: "No",
    squadID: "No",
    icon: "truck",
    equipment: "unset",
    token: "unset"
  );
}

Profile fromSnapshot(DocumentSnapshot doc) {
  if(doc?.data != null) {
    return Profile(uid: doc.id,
        name:  doc.data()['name'] ?? '',
        rank: doc.data()['rank'] ?? '',
        department: doc.data()['department'] ?? '',
        email: doc.data()['email'] ?? '',
        location: doc.data()['location'] ?? GeoPoint(39.2191, -76.07),
        responding:  doc.data()['responding'] ?? "",
        squadID: doc.data()['squadID'] ?? "",
        icon: doc.data()['icon'] ?? "helmet",
        equipment: doc.data()['equipment'] ?? "unset",
        token: doc.data()['token'] ?? "unset"
        );
  }
  else {
    return null;
  }
}


Future<Profile> getProfile(String inUid) async  {
  final doc = await FirebaseFirestore.instance.collection('profiles').doc(inUid).get();
  Profile p = fromSnapshot(doc);
  return p;
}
