
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/decoration.dart';
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
          backgroundColor: appColorMid,
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
                                Text(responder.name + " "),
                                Container(
                                    child: Flexible( child: Text("[" + responder.rank + "]",
                                      style: TextStyle(fontSize: 14.0),
                                      overflow: TextOverflow.ellipsis,),)),


                                responder.responding == "unbusy" ?
                                        Text("Ready",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))   :
                                Text( "Responding", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[500]), )
                              ]),
                              responder.responding == "unbusy" ? Text("") :
                              StreamBuilder<DocumentSnapshot>(
                                stream: Firestore.instance.collection("scenes").document(responder.responding).snapshots(),
                                builder: (context, snapshot) {
                                    if(snapshot.hasError) { return Text('Error: ${snapshot.error}');    }
                                    if(snapshot.connectionState == ConnectionState.waiting) { return Text('Loading...Connection Waiting'); }
                                    if(snapshot.hasData) {
                                      return FutureBuilder<String>(
                                        future: sceneFromSnapshot(snapshot.data).getAddress(),
                                        builder: (context, address) {
                                          if(address.hasError) { return Text('Error: ${address.error}');    }
                                          if(address.connectionState == ConnectionState.waiting) { return Text('Loading...Connection Waiting2'); }
                                          if(address.hasData)
                                            return Text(address?.data ?? "-Address Loading-", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.0),);
                                          else
                                            return Text("-address Loading-");
                                        }

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
                            print("profile_dept.dart: Responder to string is " + responder.toString());
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
