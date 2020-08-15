import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:smartresponse4/scene.dart';

class FullSceneTile extends StatelessWidget {

  final Scene scene;

  FullSceneTile({this.scene});


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
                          future: scene.getLocality(),
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
              FutureBuilder<String>( future: scene.getLocality( version: 1), builder: (context, snapshot) { if(snapshot.hasData) { return(Flexible(child: Text(snapshot.data))); } else { return Text("full loc"); }}),
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
                  child: const Text('Directions'),
                  onPressed: () async {
                    //Scene navigationScene = Scene(location: scene.location, desc: scene.desc, turnOnNavigation: true, created: scene.created);
                    //Navigator.of(context).pushNamed('/MyMapPage', arguments: navigationScene);
                    MapsLauncher.launchQuery(await scene.getAddress());
                  }
                )
              ])
            ]),
          )),
    );
  }
}
