import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:smartresponse4/map_location.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/user.dart';


class SceneTile extends StatelessWidget {

  final Scene scene;
  SceneTile({ this.scene });

  String getShortDescription(String desc) {
    final length = 85;
    if(desc.length > length) {
      return desc.substring(0,length-4) + " ...";
    }
    else {
      return desc;
    }
  }



  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
        child: Container(
          margin: EdgeInsets.fromLTRB(20.0, 6, 20, 0.0),

      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11.0),
          side: BorderSide(
            color: Colors.grey[700],
            width: 2.0,
          ),
        ),
        elevation: 15,
        shadowColor: Colors.black,
        //margin: EdgeInsets.fromLTRB(20.0, 6, 20, 0.0),
        child: Column (
    children: <Widget>[
      ListTile(

          title: Row (mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Padding (
              padding: EdgeInsets.fromLTRB(0,0,10,0),
              child: Text(scene?.created?.toDate()?.toLocal()?.toString()?.substring(5, 16) ?? "---",
                  style: TextStyle(color: Colors.blue)
              ),
            ),
            FutureBuilder<String>(
              future: scene.getLocality(),
              builder: (context, snapshot) {
                if(snapshot.hasError) { return Text('Error: ${snapshot.error}');    }
                if(snapshot.connectionState == ConnectionState.waiting) { return Text('Loading...Connection Wait: Tile'); }
                if(snapshot.hasData) {
                  return Text(snapshot?.data ?? "location*", overflow: TextOverflow.ellipsis);
                } else {
                  return Text("location**");
                }
              }
            )
          ]),
          subtitle: Row (mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
               // Text(' ${scene.location.latitude.toString()}, ${scene.location.longitude.toString()} '),
                Flexible(child: Text( getShortDescription(scene?.desc ?? "--")) ),
              ] ),
        ),
      ButtonBar(
        children: <Widget> [

          OutlineButton(
            child: const Text('More'),
            onPressed: () {
              Navigator.pushNamed(context, '/FullSceneTile', arguments: scene);
            },
          ),
          OutlineButton(
            child: const Text('Map'),
            onPressed: () { Navigator.of(context).pushNamed('/MyMapPage', arguments: scene);},
          ),
          OutlineButton(
            child:  EmailStorage.instance?.userData?.responding != scene.ref.documentID ? const Text('Respond') : const Text('Leave'),
            onPressed: () async {
              if(EmailStorage.instance.userData.responding != scene.ref.documentID) {
                String address = await scene.getAddress();
                await Firestore.instance.collection("profiles").document(EmailStorage.instance.uid).updateData({
                  "responding": scene.ref.documentID
                });
                print("Responding to this scene at: " + address);
                BackgroundLocationInterface().onStart(scene.ref.documentID);
                EmailStorage.instance.updateData();
              } else {
                BackgroundLocationInterface().onStop();
                await Firestore.instance.collection("profiles").document(EmailStorage.instance.uid).updateData({
                  "responding": "unbusy"
                });
                EmailStorage.instance.updateData();
              }
            },
          ),
          OutlineButton(
              child: const Text('Drive'),
               onPressed: () async {
                //Scene navigationScene = Scene(location: scene.location, desc: scene.desc, turnOnNavigation: true, created: scene.created);
                //Navigator.of(context).pushNamed('/MyMapPage', arguments: navigationScene);
                 String address = await scene.getAddress();
                 MapsLauncher.launchQuery(address);
              }
          )
        ]
      )
      ]
      ),
      )
    )
    );
  }
}