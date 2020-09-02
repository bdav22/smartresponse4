import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/authenticate.dart';
import 'package:smartresponse4/scene_home.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/user.dart';
import 'package:smartresponse4/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ProfileInfo extends InheritedWidget {
  final Profile profile;
  ProfileInfo({this.profile, Widget child}) : super(child: child) ;
  
  static ProfileInfo of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProfileInfo>();

  bool updateShouldNotify(ProfileInfo old) =>
      old.profile.uid != profile.uid;
}

Future<ProfileInfo> getProfileInfo(String inUid, Widget child) async  {
  Profile p = await getProfile(inUid);
  return ProfileInfo(profile: p, child: child);
}


class Wrapper extends StatefulWidget {

  const Wrapper({Key key}) : super(key: key);
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {


    @override
    void initState() {
      super.initState();
    }

  @override
  Widget build(BuildContext context) {

      return StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ) {
            FirebaseUser user = snapshot.data;
            if (user == null) {
              return Authenticate();
            }
            EmailStorage.instance.email = user.email;
            EmailStorage.instance.uid = user.uid;
            EmailStorage.instance.updateData(); // updates the user data...//POSSIBLE: move these three lines into one call inside user/EmailStorage

            Profile p = Profile(email: user.email, uid: user.uid, name: "def", rank: "def2", department: "def3", responding: "-", squadID: "-");
            return
              StreamBuilder<DocumentSnapshot> (
                stream: Firestore.instance.collection("profiles").document(user.uid).snapshots(),
                builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot?.data?.data == null) { //no profile yet?
                            return Text("Loading...");
                          }
                          else {
                            p = fromSnapshot(snapshot.data);
                          }
                          return ProfileInfo(profile: p,
                              child: SceneHome()); //snapshot.data tihs snapshot data is actually a profileinfo fully filled in
                        }
                        else {
                          return Loading();
                        }
                      }
              );

          } else {
            return Scaffold(
              body: Center (
                child: CircularProgressIndicator(),
              )
            );
          }
        }
      );

        /*
    final user = Provider.of<User>(context);

    //return either Home or Authenticate widget
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
         */
  }
}