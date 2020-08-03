import 'package:flutter/material.dart';
import 'package:smartresponse4/profile.dart';

class ProfileTile extends StatelessWidget {

  final Profile profile;
  ProfileTile({ this.profile });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6, 20, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.green,
           //backgroundImage: AssetImage('assets/StarOfLife.jpg'),
          ),
          title: Row (mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[ Text(profile.name), Text(profile.email) ] ),
          subtitle: Row (mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[ Text(' ${profile.rank} '), Text(profile.department) ] ),
        ),
      ),
    );
  }
}