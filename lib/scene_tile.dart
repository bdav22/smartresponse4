import 'package:flutter/material.dart';
import 'package:smartresponse4/scene.dart';
import 'package:geolocator/geolocator.dart';

final Map<String, String> stateShortcut = {
  "Maryland": "MD",
  "Delaware": "DE",
  "Pennsylvania": "PA",
  "Ohio": "OH",
  "Utah": "UT",
  "Tennessee": "TN",
  "North Carolina": "NC",
  "South Carolina": "SC",
  "Virginia": "VA",
  "West Virginia": "WV",
  "New Jersey": "NJ",
  "New York": "NY",
  "Vermont": "VT",
  "New Hampshire": "NH",
  "Maine": "ME",
  "Mississippi": "MS",
  "Colorado": "CO",
  "Florida": "FL",
  "Georgia": "GA",
  "Massachusetts": "MA",
  "Michigan": "MI",
  "Minnesota": "MN"
};


class SceneTile extends StatelessWidget {

  final Scene scene;
  SceneTile({ this.scene });
  //TODO: could update this for more regions, but there is a shortcut to protect the card from overload
  //TODO: if/when a new client comes aboard, we'll want to make sure there region is covered here.


  Future<String> getLocality() async {
    List<Placemark> places = await Geolocator().placemarkFromCoordinates(scene.location.latitude, scene.location.longitude);
    //print(places[0].toString() + " " + places[0].locality +  " " + places[0].administrativeArea);
    String shortName = ", " + places[0].administrativeArea.substring(0,2) + "...";
    if(stateShortcut.containsKey(places[0].administrativeArea)) {
      shortName = ", " + stateShortcut[places[0].administrativeArea];
    }

    return places[0].locality + shortName;
  }

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
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        elevation: 15,
        shadowColor: Colors.black,
        //margin: EdgeInsets.fromLTRB(20.0, 6, 20, 0.0),
        child: Column (
    children: <Widget>[
      ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.green,
           //backgroundImage: AssetImage('assets/StarOfLife.jpg'),
          ),
          title: Row (mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Text(scene.created.toDate().toLocal().toString().substring(0,16)),
            FutureBuilder<String>(
              future: getLocality(),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return Text(snapshot.data);
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
            child: const Text('Respond to This'),
            onPressed: () { },
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