import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;

  User({ this.uid });

}


class UserData {


  final String name;
  final String rank;
  final String department;
  final String email;

  UserData({ this.name, this.rank, this.department, this.email });

}

UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
  return UserData(
      name: snapshot.data['name'],
      rank: snapshot.data['rank'],
      department: snapshot.data['department'],
      email: snapshot.data['email']
  );
}


class EmailStorage {
  EmailStorage._privateConstructor();
  static final EmailStorage _instance = EmailStorage._privateConstructor();
  static EmailStorage get instance => _instance;

  String email = 'Placeholder';
  String uid = 'Placeholder';
  UserData userData;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  //get user doc stream
  Stream<UserData> getUserData(String newUid) {
    return Firestore.instance.collection('profiles').document(newUid).snapshots()
        .map(_userDataFromSnapshot);
  }



  void updateData() async {
    final data = await Firestore.instance.collection('profiles').document(uid).get();
    if(data.data != null) {
      userData = _userDataFromSnapshot(data);
    }
    else {
      userData = UserData(
          name: "NameUserData",
          rank: "RankData",
          department: "DeptData",
          email:  "EmailData"
      );
      print("user.dart updateData - ERROR - data broken");
    }

  }


  // Fetch email from logged in user on firebase
  _get() async {
    FirebaseUser user = await _auth.currentUser();
    String userEmail = user?.email ?? "placeholder";
    this.email = userEmail;
  }


}