import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/scene_tile.dart';
import 'package:geolocator/geolocator.dart';

class FullSceneTile extends StatelessWidget {
  final Scene scene;
  FullSceneTile({this.scene});

  Future<String> getLocality(Scene scene, {int version=0}) async {
//    return "1234567890abcefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz";
    List<Placemark> places = await Geolocator().placemarkFromCoordinates(
        scene.location.latitude, scene.location.longitude);
    //print(places[0].toString() + " " + places[0].locality +  " " + places[0].administrativeArea);
    String shortName =
        ", " + places[0].administrativeArea.substring(0, 2) + "...";
    if (stateShortcut.containsKey(places[0].administrativeArea)) {
      shortName = ", " + stateShortcut[places[0].administrativeArea];
    }

    switch(version){
      case 0:
        return places[0].locality + shortName;
        break;
      case 1:
        return "[" +places[0].name +  " " + places[0].thoroughfare + "] " + places[0].locality + ", " + places[0].administrativeArea +" " +  " " + places[0].postalCode;
        break;
      default:
        return places[0].locality + shortName;
    }
  }

  String getShortDescription(String desc) {
    final length = 85;
    if (desc.length > length) {
      return desc.substring(0, length - 4) + " ...";
    } else {
      return desc;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Full Scene Descrption"),
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: Padding(
          padding: EdgeInsets.only(top: 8.0),
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
                          future: getLocality(scene),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Flexible(child: Text(snapshot.data, overflow: TextOverflow.ellipsis) );
                            } else {
                              return Text("location");
                            }
                          })
                    ]),
                subtitle: Text('Lat: ${scene.location.latitude.toString()}, Long:${scene.location.longitude.toString()} '),
              ),
              FutureBuilder<String>( future: getLocality(scene, version: 1), builder: (context, snapshot) { if(snapshot.hasData) { return(Flexible(child: Text(snapshot.data))); } else { return Text("full loc"); }}),
              Padding( padding: EdgeInsets.all(18.0), child: Text(scene?.desc ?? "---")),
              ButtonBar(children: <Widget>[
                FlatButton(
                  child: const Text('Go Back'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: const Text('Show on Map'),
                  onPressed: () { Navigator.of(context).pushNamed('/MyMapPage', arguments: scene);},
                ),
                FlatButton(
                  child: const Text('Respond to This'),
                  onPressed: () {
                        Scene navigationScene = Scene(location: scene.location, desc: scene.desc, turnOnNavigation: true, created: scene.created);
                        //Navigator.of(context).pushNamed('/MyMapPage', arguments: navigationScene);
                        MapsLauncher.launchQuery('105 Valley Road Chestertown, Md 21620, USA');
                  },
                )
              ])
            ]),
          )),
    );
  }
}
