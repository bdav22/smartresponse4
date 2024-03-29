
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/box_decoration.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/profile.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/profile_tile.dart';

class DepartmentProfileList extends StatefulWidget {
  final String squadID;
  DepartmentProfileList(this.squadID) {
   // print("Created with " + squadID);
  }

  @override
  _DepartmentProfileListState createState() => _DepartmentProfileListState();
}

class _DepartmentProfileListState extends State<DepartmentProfileList> {
  Stream<List<Profile>> _squadStream;

  @override
  void initState() {
    super.initState();
  //  print("initState with " + widget.squadID);
    _squadStream = context.read<Repository>().getSquadProfiles(widget.squadID);

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold (
      appBar: AppBar(
          title: Text('Smart Response'),
          backgroundColor: Colors.lightBlue,
          elevation: 0.0,
      ),
      body: Container(
        decoration: customBoxDecoration(),
        child: StreamBuilder<List<Profile>>(
          stream: _squadStream,
          builder: (BuildContext builder, AsyncSnapshot<List<Profile>> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text('Loading...');
              default:
                return ListView(
                  children: snapshot.data.map((Profile responder) {
                   // print("I am a squadmate of squad: " + responder.squadID + " - " + responder.name);
                    return Card(
                      shape: cardShape(),
                      elevation: 15,
                      shadowColor: Colors.black,
                      child: ListTile(
                          title: Column(
                            children: <Widget>[
                              Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                Text(responder.name),
                                responder.responding == "unbusy" ?
                                        Text("Ready",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))   :
                                Text( "Responding", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green), )
                              ]),
                              responder.responding == "unbusy" ? Text("") :
                              StreamBuilder<DocumentSnapshot>(
                                stream: Firestore.instance.collection("scenes").document(responder.responding).snapshots(),
                                builder: (context, snapshot) {
                                    if(snapshot.hasData) {
                                      return FutureBuilder<String>(
                                        future: sceneFromSnapshot(snapshot.data).getAddress(),
                                          builder: (context, address) { return Text(address?.data ?? "-abc-", overflow: TextOverflow.ellipsis); } ,

                                      );
                                    }
                                    else {
                                      return Text("b");
                                    }
                                }

                              )
                            ],
                          ),
                          /*subtitle:
                          FutureBuilder<double>(
                              future: distanceBetweenInMinutes(responder.loc, widget.scene.location),
                              builder: (context, snapshot) {
                                return Text("ETA: ~" + (snapshot?.data?.toInt()?.toString() ?? "??") + " minutes");
                              }
                          ),

                           */
                          onTap: () async {
                            print(responder.toString());
                            Profile p = await getProfile(responder.uid);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileTile(profile: p)));
                          }
                      ),
                    );
                  }).toList()
                );
            }
          }
        ),
      ),
    );
  }
}
