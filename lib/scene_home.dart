import 'package:flutter/material.dart';
import 'package:smartresponse4/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smartresponse4/box_decoration.dart';
import 'package:smartresponse4/database.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/map_location.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/scene_list.dart';
import 'package:smartresponse4/user.dart';
import 'package:smartresponse4/wrapper.dart';



class SceneHome extends StatefulWidget {
  const SceneHome({Key key}) : super(key: key);
  @override
  _SceneHomeState createState() => _SceneHomeState();
}


class _SceneHomeState extends State<SceneHome> {

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
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(

                accountName:
                  Row (mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[ Text(p.profile.name), Text(p.profile.email + " ") ] ),
            //Text(EmailStorage.instance.userData.name),
                accountEmail: Column ( crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      Row (mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[ Text(p.profile.rank), Text(p.profile.department + " ") ] ),
                      Text("Depatment ID Code: " + p.profile.squadID),
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
              ListTile(
                leading: Icon(Icons.people), // Icon.map when using this for map
                title: Text('Department'),
                onTap: () {
                  Navigator.of(context).pushNamed('/Department');  //used to be map
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.chat),
                title: Text('Private Messages'),
                onTap: () {
                  Navigator.of(context).pushNamed('/dms', arguments: 'hello');
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.chat),
                title: Text('Chat'),
                onTap: () {
                  Navigator.of(context).pushNamed('/chat', arguments: 'hello');
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.update),
                title: Text('ICS'),
                onTap: () {
                  Navigator.of(context).pushNamed('/ICS', arguments: 'Hello');
                },

              ),

              Divider(),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  Navigator.of(context).pushNamed('/Settings', arguments: 'Hello');
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('Smart Response'),
            backgroundColor: Colors.lightBlue,
            elevation: 0.0,
            actions: <Widget>[
              FlatButton.icon(
                icon: Icon(Icons.person),
                label: Text('logout'),
                onPressed: () async {
                  await _auth.signOut();
                  EmailStorage.instance.clearData();
                },
              ),
            ]

        ),
        body: Container(
            decoration: customBoxDecoration(),
            child: SceneList()),
      ),
    );
  }
}