import 'package:flutter/material.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/scene.dart';

class ProfileTile extends StatelessWidget {

  final Profile profile;
  ProfileTile({ this.profile });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 50.0, bottom: 50),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6, 20, 0.0),
        child: Column(
          children: <Widget>[ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.green,
           //backgroundImage: AssetImage('assets/StarOfLife.jpg'),
          ),
          title: Row (mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[ Text(profile.name), Text(profile.email) ] ),
          subtitle: Row (mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[ Text(' ${profile.rank} '), Text(profile.department) ] ),
        ),
          ButtonBar(
              children: <Widget> [
                  FlatButton(
                  child: const Text('Send a Private Message'),
                  onPressed: () {
                    },
                  ),
                  FlatButton(
                    child: const Text('Show on Map'),
                    onPressed: () {
                      print(profile.name);
                      print(profile.location.latitude);
                      Navigator.of(context).pushNamed('/MyMapPage', arguments: Scene(location: profile.location));
                    },
                  ),
                FlatButton(
                  child: const Text('Back'),
                  onPressed: () { Navigator.pop(context); },
                ),
              ],
           ),
          ],
        ),
      ),
    );
  }
}