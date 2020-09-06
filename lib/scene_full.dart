import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/map_location.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/user.dart';

class FullSceneTile extends StatelessWidget {

  final Scene scene;
  final String respond = "Respond";
  FullSceneTile({this.scene});


  String getShortDescription(String desc) {
    final length = 85;
    if (desc.length > length) {
      return desc.substring(0, length - 4) + " ...";
    } else {
      return desc;
    }
  }


  void respondFunction(BuildContext context) async {
    if (respond == "Respond") {

    } else {
      BackgroundLocationInterface().onStop();
      await Firestore.instance.collection("profiles").document(EmailStorage.instance.uid).updateData({
        "responding": "unbusy"
      });
      EmailStorage.instance.updateData();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Full Scene Description"),
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: Container(
        decoration: customBoxDecoration(),
        child: Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
            child: Card(
              shadowColor: Colors.red,
              margin: EdgeInsets.fromLTRB(20.0, 6, 20, 0.0),
              child: Column(children: <Widget>[
                ListTile(

                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
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
                              if(snapshot.connectionState == ConnectionState.waiting) { return Text('Loading...Connection Waiting'); }
                              if (snapshot.hasData) {
                                return Flexible(child: Text(snapshot.data, overflow: TextOverflow.ellipsis) );
                              } else {
                                return Text("location data is loading");
                              }
                            })
                      ]),
                  subtitle: Text('Lat: ${scene.location.latitude.toString()}, Long:${scene.location.longitude.toString()} '),
                ),
                FutureBuilder<String>( future: scene.getLocality( version: 1), builder: (context, snapshot) { if(snapshot.hasData) { return(Flexible(child: Text(snapshot.data))); } else { return Text("full loc"); }}),
                Padding( padding: EdgeInsets.all(18.0), child: Text(scene?.desc ?? "---")),

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
                      getMyButton(Colors.green, "Respond", () async {
                        String address = await scene.getAddress();
                        await Firestore.instance.collection("profiles").document(EmailStorage.instance.uid).updateData({
                          "responding": scene.ref.documentID
                        });
                        print("scene_tile.dart: Responding to this scene at: " + address);
                        BackgroundLocationInterface().onStart(scene.ref.documentID);
                        EmailStorage.instance.updateData();
                        Navigator.pop(context);
                      }),
                      getMyButton(Colors.blue, 'Map',  () {Navigator.pushNamed(context, '/MyMapPage', arguments: scene);}),
                      getMyButton(Colors.blue, 'Drive',  () async {
                        String address = await scene.getAddress();
                        MapsLauncher.launchQuery(address);
                      }),

                    ]),


              ]),
            )),
      ),
    );
  }
}
