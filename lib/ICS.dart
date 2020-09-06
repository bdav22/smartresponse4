import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/ics_setting.dart';
import 'package:smartresponse4/scene.dart';
import 'package:provider/provider.dart';

class ICS extends StatefulWidget {

  final Scene scene;
  ICS(this.scene);
  _ICSState createState() => _ICSState();
}


class _ICSState extends State<ICS> {

  Stream< List<CommandPosition> > _commandStream;


  @override
  void initState() {
    super.initState();
    _commandStream = context.read<Repository>().getCommandPositions(widget.scene.ref.documentID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ICS"),
      ),
      body: Container(
        width: double.infinity,
        decoration: customBoxDecoration(),
        child: StreamBuilder<List<CommandPosition>>(
          stream: _commandStream,
          builder: (BuildContext context, AsyncSnapshot<List<CommandPosition>> snapshot) {
            if(snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
            }
            switch(snapshot.connectionState) {
              case ConnectionState.waiting:
                return Card(child: Container(padding: EdgeInsets.all(5), child: Text('Loading (or waiting for entries)...')));
              default:
                return ListView(
                  children: snapshot.data.map((CommandPosition cp) {
                    return ListTile(
                            title: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Card(
                                    elevation: 15,
                                    shadowColor: Colors.black, child:
                                          Container (
                                            padding: EdgeInsets.all(10),
                                              child: Text((cp?.position ?? "--") + "  -  " + (cp?.name ?? "-"))),
                                  ),
                                ),
                                      RawMaterialButton(
                                        onPressed: () {
                                          Repository(Firestore.instance).removeCommandPosition(widget.scene.ref.documentID, cp.documentID);
                                        }, elevation: 2.0, fillColor: Colors.green,
                                        child: Icon(Icons.delete_outline, size: 25.0,),
                                        padding: EdgeInsets.all(5.0),
                                        shape: CircleBorder(),
                                      )
                                    ],
                                  )
                          );
                  }).toList(),
                );
            }
          }
        )
      ),
      floatingActionButton:
//          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
//            Card(child: Padding ( padding: EdgeInsets.all(5), child: Text("Add another position")), ),
            FloatingActionButton(onPressed: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ICSSettings(widget.scene)
                ));
              }, tooltip: 'Add A New Person To this Scene', child: Icon(Icons.add))
//          ]
//    ),


    );
  }
}
