import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/database.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/map_location.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/scene_list.dart';
import 'package:smartresponse4/scene_tile_active.dart';
import 'package:smartresponse4/user.dart';
import 'package:smartresponse4/wrapper.dart';



class SceneHome extends StatefulWidget {
  const SceneHome({Key key}) : super(key: key);
  @override
  _SceneHomeState createState() => _SceneHomeState();
}


class _SceneHomeState extends State<SceneHome> {
  final Color evens = Colors.white;//[100];
  final Color odds = Colors.white; //e[100]; //Colors.blue[300];
  final AuthService _auth = AuthService();
  Profile userData;
  EmailStorage _es;


  @override
  void initState() {
    super.initState();
    _es = EmailStorage.instance;
    userData = _es.userData;
    BackgroundLocationInterface().initPlatformState(); //set up background locator stuffs stuffs
  }



  @override
  Widget build(BuildContext context) {
    final p = ProfileInfo.of(context);

    return StreamProvider<List<Scene>>.value(
      value: DatabaseService().scenes,
      child: Scaffold(
        drawer: Drawer(
          child: Container(
            decoration: customBoxDecoration(),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  //decoration: customBoxDecoration(),
                  decoration: BoxDecoration(color: appColorMid),
                  accountName:
                    Row (mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[ Text(p.profile.name), Text(p.profile.email + " ") ] ),
              //Text(EmailStorage.instance.userData.name),
                  accountEmail: Column ( crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        Row (mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                          Flexible(child: Text(p.profile.rank,  overflow: TextOverflow.ellipsis)),
                          Flexible(child: Text(p.profile.department + " ", overflow: TextOverflow.ellipsis))
                        ] ),
                        Text("Department ID Code: " + p.profile.squadID),
                    ]
                  ),
                  key: UniqueKey(),
                  //Text(EmailStorage.instance.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Theme.of(context).platform == TargetPlatform.iOS ?Colors.white: null,
                    child: Text(p.profile.name.length > 0 ? p.profile.name[0] : "D"),
                  ),
                ),
                Divider(),
                Container(
                  color: odds,
                  child: ListTile(
                    leading: Icon(Icons.people), // Icon.map when using this for map
                    title: Text('Department'),
                    onTap: () {
                      Navigator.of(context).pushNamed('/Department');  //used to be map
                    },
                  ),
                ),
                Divider(),
                Container(
                  color: evens,
                  child: ListTile(
                    leading: Icon(Icons.search),
                    title: Text('New Private Message'),
                    onTap: () {
                      Navigator.of(context).pushNamed('/Compose', arguments: 'hello');
                    },
                  ),
                ),
                Divider(),
          Container(
            color: odds,
            child:ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('Private Messages'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/dms', arguments: 'hello');
                  },
                ),
          ),
                Divider(),
                /*
                ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('Global Chat'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/chat', arguments: 'hello');
                  },
                ),
                Divider(),
                 */
          Container(
            color: evens,
            child:
                ListTile(
                  leading: Icon(Icons.map),
                  title: Text('Map'),
                  onTap: () {

                    Navigator.of(context).pushNamed('/MyMapPage', arguments: Scene(location: p.profile.location));
                  },

                ),
              ),

                Divider(),
          Container(
            color: odds,
            child:
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/Settings', arguments: 'Hello');
                  },
                ),
          ),
                Divider(),
          Container(
            color: evens,
            child: ListTile(
                  leading: Icon(Icons.cancel),
                  title: Text('Cancel'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
          ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('Smart Response'),
            backgroundColor: appColorMid,
            elevation: 0.0,
            actions: <Widget>[
              FlatButton.icon(
                icon: Icon(Icons.person, color: Colors.white),
                label: Text('logout', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  await _auth.signOut();
                  EmailStorage.instance.clearData();
                },
              ),
            ]

        ),
        body: Container(
            decoration: customBoxDecoration(),
            child: Column(
              children: <Widget>[
                Card( child: Container( width: double.infinity, padding: EdgeInsets.all(5), color: appColorMidBright3,
                    child: Center(child:Text("Active Scene", textScaleFactor: 2.0,)))),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection("profiles").doc(EmailStorage.instance.uid).snapshots(),
                  builder: (context, snapshot) {
                    //String respondingBit = (snapshot?.data?.data()['responding'] ?? "");
                    if(snapshot.hasData && snapshot?.data != null &&
                        snapshot?.data?.data()["responding"] != null && snapshot?.data?.data()["responding"] != "unbusy" &&
                        snapshot?.data?.data()["responding"] != ""  ) {
                      return StreamBuilder(
                        stream: FirebaseFirestore.instance.collection("scenes").doc((snapshot?.data?.data()['responding'] ?? "")).snapshots(),
                        builder: (context, ss) {
                          if(ss.hasData && ss?.data != null && snapshot.data?.data()['responding'] != "unbusy") {
                            print("scene_home.dart: to what am I responding scene responding data:" + snapshot.data?.data()['responding']);
                            return SceneTileActive(scene: sceneFromSnapshot(ss?.data));
                          }
                          else {
                            return SizedBox(height: 20); // Text("No Active Scene Loaded Just Yet");
                          }
                        }
                      );
                    }
                    else {
                      return Text("You are not responding at this time", style: TextStyle(color: Colors.white));
                    }
                  }
                ),
                Card( child: Container( width: double.infinity, padding: EdgeInsets.all(5), color: appColorMidBright3,
                    child: Center(child:Text("All Scenes", textScaleFactor: 2.0,)))),
                Expanded(child: SceneList()),
              ],
            )),
      ),
    );
  }
}