import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:smartresponse4/scene.dart';


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

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
          width: 2.0
      ),
      borderRadius: BorderRadius.all(
          Radius.circular(10.0) //         <--- border radius here
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
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
                if(snapshot.hasData) {
                  return Text(snapshot?.data ?? "location",
                          overflow: TextOverflow.ellipsis);
                } else {
                  return Text("location");
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
          FlatButton(
            child: const Text('More Info'),
            onPressed: () {
              Navigator.pushNamed(context, '/FullSceneTile', arguments: scene);
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
        ]
      )
      ]
      ),
      )
    )
    );
  }
}