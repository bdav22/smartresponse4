
import 'dart:io';

import 'package:background_locator/background_locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/map_location.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/user.dart';
import 'package:smartresponse4/wrapper.dart';


class SceneTile extends StatefulWidget {

  final Scene scene;
  final String respond="Respond";
  SceneTile({ this.scene} );
  @override
  _SceneTileState createState() => _SceneTileState();
}

class _SceneTileState extends State<SceneTile> {
  bool displayRespond = true;

  String getShortDescription(String desc) {
    final length = 85;
    if(desc.length > length) {
      return desc.substring(0,length-4) + " ...";
    }
    else {
      return desc;
    }
  }

  void respondFunction() async {
    if (widget.respond == "Respond") {
      String address = await widget.scene.getAddress();
      await FirebaseFirestore.instance.collection("profiles").doc(EmailStorage.instance.uid).update({
        "responding": widget.scene.ref.id
      });
      print("scene_tile.dart: Responding to this scene at: " + address);
      /*disposing old bglocator not needed - while it looks like we're using the scene, we aren't. it's all good */
      print("scene_tile.dart: okay about to start the service then ************************************************");
      //TODO: FIX FOR IOS
      if(Platform.isAndroid) {
        BackgroundLocationInterface().onStart(widget.scene.ref.id);
      }
      EmailStorage.instance.updateData();
    } else {
      //TODO: fix for ios
      if(Platform.isAndroid) {
        BackgroundLocationInterface().onStop();
      }
      await FirebaseFirestore.instance.collection("profiles").doc(EmailStorage.instance.uid).update({
        "responding": "unbusy"
      });
      EmailStorage.instance.updateData();
    }
  }


  @override
  Widget build(BuildContext context) {
    final p = ProfileInfo.of(context);
    Widget respondButton;
    //print("scene_tile.dart:" + scene.ref.documentID + " " + EmailStorage.instance.userData.responding + " " + this.displayRespond.toString());
    respondButton = getMyButton( "Respond", respondFunction, color: "go");
    return Padding(
      padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
        child: Container(
          margin: EdgeInsets.fromLTRB(20.0, 6, 20, 0.0),

      child: Card(
        color: appColorSuperBright,
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
              child: Text(widget.scene?.created?.toDate()?.toLocal()?.toString()?.substring(5, 16) ?? "---",
                  style: TextStyle(color: appColorMidLight)
              ),
            ),
            FutureBuilder<String>(
              future: widget.scene.getLocality(),
              builder: (context, snapshot) {
                if(snapshot.hasError) {
                    print('scene_tile.dart -- ${snapshot.error}');
                    return Flexible(child: Text('--', overflow: TextOverflow.ellipsis));
                }
                if(snapshot.connectionState == ConnectionState.waiting) { return Text(""); }
                if(snapshot.hasData) {
                  return Text(snapshot?.data ?? "location*", overflow: TextOverflow.ellipsis);
                } else {
                  return Text("---");
                }
              }
            )
          ]),
          subtitle: Column(
            children: <Widget>[
              Row (mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text( 'Priority: ${widget.scene?.priority ?? 2} '),
                    Text( 'Units: ${widget.scene?.units ?? 8} '),
                    ]
              ),
              Row (mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                   // Text(' ${scene.location.latitude.toString()}, ${scene.location.longitude.toString()} '),
                    Flexible(child: Text( getShortDescription(widget.scene?.desc ?? "--")) ),
                  ] ),
            ],
          ),
        ),


      ButtonBar(
        children: <Widget> [
          p.profile.responding != widget.scene.ref.id ? respondButton : SizedBox(),
          getMyButton( 'Map',  () {Navigator.pushNamed(context, '/MyMapPage', arguments: widget.scene);}),
          getMyButton('Drive',  () async {
            String address = await widget.scene.getAddress();
            MapsLauncher.launchQuery(address);
          }),
          getMyButton( "More",  () {Navigator.pushNamed(context, '/FullSceneTile', arguments: widget.scene);}),
        ]
      )
      ]
      ),
      )
    )
    );
  }
}