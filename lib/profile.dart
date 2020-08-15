import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {

  final String name;
  final String rank;
  final String department;
  final String email;
  final String uid;
  final GeoPoint location;

  Profile({ this.name, this.rank, this.department, this.email, this.uid,this.location });
}

Future<Profile> getProfile(String inUid) async  {
  final nUid = inUid;
  final doc = await Firestore.instance.collection('profiles').document(inUid).get();
  final nName = doc.data['name'] ?? '';
  final nRank = doc.data['rank'] ?? '';
  final nDepartment = doc.data['department'] ?? '';
  final nEmail= doc.data['email'] ?? '';
  final nLoc = doc.data['location'] ?? GeoPoint(0.0,0.0);
  return Profile(uid: nUid, name: nName, rank: nRank, department: nDepartment, email: nEmail, location: nLoc);
}
