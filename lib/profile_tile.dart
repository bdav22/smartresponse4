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
            backgroundColor: Colors.blue,
            backgroundImage: AssetImage('assets/StarOfLife.jpg'),
          ),
          title: Text(profile.name),
          subtitle: Text(' ${profile.rank} '),
        ),
      ),
    );
  }
}