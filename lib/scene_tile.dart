import 'package:flutter/material.dart';
import 'package:smartresponse4/scene_home.dart';
import 'package:geolocator/geolocator.dart';
class SceneTile extends StatelessWidget {

  final Scene scene;
  SceneTile({ this.scene });

  Future<String> getLocality() async {
    List<Placemark> places = await Geolocator().placemarkFromCoordinates(scene.location.latitude, scene.location.longitude);
    //print(places[0].toString() + " " + places[0].locality +  " " + places[0].administrativeArea);
    return places[0].locality +  ", " + places[0].administrativeArea;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),

      child: Card(
        shadowColor: Colors.red,
        margin: EdgeInsets.fromLTRB(20.0, 6, 20, 0.0),
        child: Column (
    children: <Widget>[
      ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.green,
           //backgroundImage: AssetImage('assets/StarOfLife.jpg'),
          ),
          title: Row (mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[ Text(scene.created.toDate().toLocal().toString().substring(0,19)), Text(scene.desc) ] ),
          subtitle: Row (mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[ Text(' ${scene.location.latitude.toString()}, ${scene.location.longitude.toString()} '),
                    FutureBuilder<String>(
                      future: getLocality(),
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                          return Text(snapshot.data);
                        } else {
                          return Text("location");
                        }
                      }
                    )] ),
        ),
      ButtonBar(
        children: <Widget> [
          FlatButton(
            child: const Text('Respond to This'),
            onPressed: () { },
          )
        ]
      )
      ]
      ),
      )
    );
  }
}