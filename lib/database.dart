import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/user.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  // collection reference
  final CollectionReference profileCollection = Firestore.instance.collection('profiles');

  Future updateUserData(String name, String rank, String department) async {
    return await profileCollection.document(uid).setData({
      'name': name,
      'rank': rank,
      'department': department,
    });
  }

  // userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      name: snapshot.data['name'],
      rank: snapshot.data['rank'],
      department: snapshot.data['department'],
    );
  }

  // profile list from snapshot
  List<Profile> _ProfileListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      return Profile(
        name: doc.data['name'] ?? '',
        rank: doc.data['rank'] ?? '',
        department: doc.data['department'] ?? '',
      );
    }).toList();
  }

  //get profiles stream
  Stream<List<Profile>> get profiles {
    return profileCollection.snapshots()
        .map(_ProfileListFromSnapshot);
  }


//get user doc stream
  Stream<UserData> get userData {
    return profileCollection.document(uid).snapshots()
        .map(_userDataFromSnapshot);
  }

}