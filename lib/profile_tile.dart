import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/box_decoration.dart';
import 'package:smartresponse4/message_list_private.dart';
import 'package:smartresponse4/message_pms_creation.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/user.dart';

class ProfileTile extends StatelessWidget {

  final Profile profile;
  ProfileTile({ this.profile });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Chat'),
    ),body: Container(
    decoration: customBoxDecoration(),
    child: Padding(
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
          title:  Row (mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible ( child: Text(profile.name, overflow: TextOverflow.ellipsis,) ),
                Text(profile.email, overflow: TextOverflow.ellipsis) ]
          ),
          subtitle: Row (mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[ Text(' ${profile.rank} '), Text(profile.department) ] ),
        ),
          ButtonBar(
              children: <Widget> [
                  FlatButton(
                  child: const Text('Send a Private Message'),
                  onPressed: () async {
                    DocumentReference ref = await does_pms_exist_in_profile_uid(EmailStorage.instance.uid, profile.uid, profile.name);
                        Navigator.push(context,  MaterialPageRoute(builder: (context) =>
                             Scaffold(
                               appBar: AppBar(
                                title: Text('DMs with: ' + profile.name),
                              ),
                              body: PrivateMessageList(ref)),
                           //Text("List to be updated here with " + (doc['otheruser'] ?? "unknown"))),
                        ));
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
    ),
    ),
    );
  }
}