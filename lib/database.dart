import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  // collection reference
  final CollectionReference profileCollection = Firestore.instance.collection('profiles');

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

  //get profiles stream
  Stream<List<Profile>> get profiles {
    return profileCollection.snapshots()
        .map(_profileListFromSnapshot);
  }




//get user doc stream
  Stream<UserData> get userData {
    return profileCollection.document(uid).snapshots()
        .map(_userDataFromSnapshot);
  }

}