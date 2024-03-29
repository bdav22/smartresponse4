
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/box_decoration.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/profile_tile.dart';
import 'package:smartresponse4/scene.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/scene_tile.dart';
import 'package:smartresponse4/utility.dart';

class Logistic extends StatefulWidget {

  final Scene scene;
  const Logistic({this.scene, Key key}) : super(key: key);
  _LogisticState createState() => _LogisticState();

}


class _LogisticState extends State<Logistic> {
  Stream<List<Responder>> _respondersStream;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _respondersStream = context.read<Repository>().getResponders(widget.scene.ref.documentID); //, widget.scene.location);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Scene Logistics"),
        ),
        body:   Container(
          decoration: customBoxDecoration(),
            child: Column(
            children: <Widget>[
              Card( child: Container( width: double.infinity, padding: EdgeInsets.all(5), color: Colors.blueGrey[50],  child: Center(child:Text("Scene Information", textScaleFactor: 2.0,)))),
              SceneTile(scene: widget.scene),
              Card( child: Container( width: double.infinity, padding: EdgeInsets.all(5), color: Colors.blueGrey[50],  child: Center(child:Text("Responders and ETAs", textScaleFactor: 2.0,)))),
              Expanded(
                child:  StreamBuilder<List<Responder>>(
                  stream: _respondersStream,
                  builder: (BuildContext context, AsyncSnapshot<List<Responder>> snapshot) {
                    if(snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    switch(snapshot.connectionState) {
                      case ConnectionState.waiting: return Text('Loading...');
                      default:
                         return ListView(
                            children: snapshot.data.map((Responder responder) {
                              return Card(
                                  shape: cardShape(),
                                  elevation: 15,
                                  shadowColor: Colors.black,
                                  child: ListTile(
                                    title: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text(responder.profile?.name ?? "name broke?"),
                                     Text( "Responding",
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                      )]),
                                    subtitle:
                                    FutureBuilder<double>(
                                        future: distanceBetweenInMinutes(responder.profile.location, widget.scene.location),
                                        builder: (context, snapshot) {
                                            return Text("ETA: ~" + (snapshot?.data?.toInt()?.toString() ?? "??") + " minutes");
                                        }
                                    ),
                                    onTap: () {
                                      print(responder.toString());
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileTile(profile: responder.profile)));
                                    }
                                  ),
                              );
                          }).toList(),
                          );
                    }
                    }
                 )
              ),
            ]
          )
      )
    );
  }


}