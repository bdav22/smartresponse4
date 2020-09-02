import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:smartresponse4/box_decoration.dart';
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
                ButtonBar(children: <Widget>[
                  OutlineButton(
                    child: const Text('Notes/Chat'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/Logistics', arguments: scene);},
                  ),
                  OutlineButton(
                    child: const Text('Logistics'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/Logistics', arguments: scene);},
                  ),
                  OutlineButton(
                    child: const Text('ICS'),
                    onPressed: () { Navigator.of(context).pushNamed('/ICS', arguments: scene);},
                  ),
                ]),
                ButtonBar(children: <Widget>[
                  OutlineButton(
                    child: const Text('Show on Map'),
                    onPressed: () { Navigator.of(context).pushNamed('/MyMapPage', arguments: scene);},
                  ),
                  OutlineButton(
                    child: const Text('Directions'),
                    onPressed: () async {
                      //Scene navigationScene = Scene(location: scene.location, desc: scene.desc, turnOnNavigation: true, created: scene.created);
                      //Navigator.of(context).pushNamed('/MyMapPage', arguments: navigationScene);
                      String address = await scene.getAddress();
                      MapsLauncher.launchQuery(address);
                    }
                  )
                ])
              ]),
            )),
      ),
    );
  }
}
