import 'package:flutter/material.dart';
import 'package:smartresponse4/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smartresponse4/database.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/profile_list.dart';


class Home extends StatelessWidget {

  final AuthService _auth = AuthService();


  @override
  Widget build(BuildContext context) {


    return StreamProvider<List<Profile>>.value(
      value: DatabaseService().profiles,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text('Ben Davenport'),
                accountEmail: Text('bendavenport333@gmail.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Theme.of(context).platform == TargetPlatform.iOS ?Colors.white: null,
                  child: Text('B'),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.map),
                title: Text('Map'),
                onTap: () {
                  Navigator.of(context).pushNamed('/FirstPage', arguments: 'Hello');
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.chat),
                title: Text('Chat'),
                onTap: () {
                  Navigator.of(context).pushNamed('/chat', arguments: 'Hello');
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
                },
              ),
            ]

        ),
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/StarOfLife.jpg'),
                    fit: BoxFit.scaleDown
                )
            ),
            child: ProfileList()),
      ),
    );
  }
}