import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/profile_tile.dart';

class ProfileListTile extends StatelessWidget {
  final Profile profile;
  ProfileListTile(this.profile);

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: cardShape(),
        elevation: 15,
        shadowColor: Colors.black,
        child: ListTile(
            title: Column(children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Text(profile.name + " "),
            Container(
                child: Flexible(
              child: Text(
                "[" + profile.rank + "]",
                style: TextStyle(fontSize: 14.0),
                overflow: TextOverflow.ellipsis,
              ),
            )),
            profile.responding == "unbusy"
                ? Text("Ready", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))
                : Text(
                    "Responding",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[500]),
                  )
          ])
        ]),
        onTap: () async {
          print("profile_listtile.dart: Responder to string is " + profile.uid.toString());
          Profile p = await getProfile(profile.uid);
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileTile(profile: p)));
        }
        )
    );
  }
}
