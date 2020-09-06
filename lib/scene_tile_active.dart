
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/map_location.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/user.dart';


class SceneTileActive extends StatelessWidget {

  final Scene scene;
  final String respond = "Leave";
  SceneTileActive({ this.scene });

  /*
  @override
  _SceneTileState createState() => _SceneTileState();
}

class _SceneTileState extends State<SceneTile> {
   */

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
                if(snapshot.connectionState == ConnectionState.waiting) { return Text(""); }
                if(snapshot.hasData) {
                  return Text(snapshot?.data ?? "location*", overflow: TextOverflow.ellipsis);
                } else {
                  return Text("Data Missing - Report");
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

      Column(
          children: <Widget> [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget> [
                    getMyButton(Colors.blue, 'Chat',  () {Navigator.pushNamed(context, '/chat', arguments: scene);}),
                    getMyButton(Colors.blue, "ICS", () {Navigator.of(context).pushNamed('/ICS', arguments: scene);}),
                    getMyButton(Colors.blue, "Logistics", () {Navigator.of(context).pushNamed('/Logistics', arguments: scene);}),
            ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget> [
                getMyButton(Colors.blue, 'More',  () {Navigator.pushNamed(context, '/FullSceneTile', arguments: scene);}),
                getMyButton(Colors.blue, 'Map',  () {Navigator.pushNamed(context, '/MyMapPage', arguments: scene);}),
                getMyButton(Colors.blue, 'Drive',  () async {
                  String address = await scene.getAddress();
                  MapsLauncher.launchQuery(address);
                }),

          ]),
          Container(
            padding: EdgeInsets.fromLTRB(10,0,10,0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: Colors.red,
              child: Container ( width: double.infinity,
                  child: Center (child:Text(respond, style: TextStyle( color: Colors.white)))),
                  onPressed: () async {
                    //EmailStorage.instance.updateData();
                    //if(EmailStorage.instance.userData?.responding != widget.scene.ref.documentID) {
                    if(respond == "Respond") {
                      String address = await scene.getAddress();
                      await Firestore.instance.collection("profiles").document(EmailStorage.instance.uid).updateData({
                        "responding": scene.ref.documentID
                      });
                      print("scene_tile.dart: Responding to this scene at: " + address);
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
                ),
        ]
      )
      ]
      ),
      )
    )
    );
  }
}