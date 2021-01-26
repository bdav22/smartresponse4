import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:smartresponse4/authenticate.dart';
import 'package:smartresponse4/route_generator.dart';
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
      old.profile.uid != profile.uid || old.profile.squadID != profile.squadID;
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

      return StreamBuilder<auth.User>(
        stream: auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ) {
            auth.User user = snapshot.data;
            if (user == null) {
              return Authenticate();
            }
            EmailStorage.instance.email = user.email;
            EmailStorage.instance.uid = user.uid;
            EmailStorage.instance.updateData(); // updates the user data...//POSSIBLE: move these three lines into one call inside user/EmailStorage

            Profile p = Profile(email: user.email, uid: user.uid, name: "def", rank: "def2", department: "def3", responding: "-", squadID: "-");
            return
              StreamBuilder<DocumentSnapshot> (
                stream: FirebaseFirestore.instance.collection("profiles").doc(user.uid).snapshots(),
                builder: (context, snapshot) {
                        if (snapshot.hasData) {

                          if (snapshot?.data?.data == null) { //no profile yet?
                            return Authenticate();
                          }
                          else {
                            p = fromSnapshot(snapshot.data);
                          }
                          return ProfileInfo(profile: p,
                              child: MaterialApp (
                                initialRoute: '/',
                                onGenerateRoute: RouteGenerator.generateRoute,
                                home: SceneHome()
                              )
                          ); //snapshot.data tihs snapshot data is actually a profileinfo fully filled in
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
  }
}