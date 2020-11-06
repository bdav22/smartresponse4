
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/equipment.dart';
import 'package:smartresponse4/equipment_riders.dart';
import 'package:smartresponse4/marker_data.dart';
import 'package:smartresponse4/profile.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/profile_tile.dart';

class DepartmentProfileList extends StatefulWidget {
  final String squadID;
  DepartmentProfileList(this.squadID) {
    print("profile_dept.dart: Department Profile Created with " + squadID);
  }

  @override
  _DepartmentProfileListState createState() => _DepartmentProfileListState();
}

class _DepartmentProfileListState extends State<DepartmentProfileList> {
  Stream<List<Profile>> _squadStream;
  Stream<List<Equipment>> _eqStream;
  List<bool> _selections = List.generate(3, (_) => false);

  @override
  void initState() {
    super.initState();
  //  print("initState with " + widget.squadID);
    _squadStream = context.read<Repository>().getSquadProfiles(widget.squadID);
    _eqStream = context.read<Repository>().getEquipment(widget.squadID);
    _selections[0] = true;
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold (
      appBar: AppBar(
          title: Text('Smart Response'),
          backgroundColor: appColorMid,
          elevation: 0.0,
      ),
      body: FutureBuilder<MarkerData>(
      future: CustomMarkers.instance.getCustomMarkers(),
      builder: (BuildContext context, AsyncSnapshot<MarkerData> customMarkersData) {
      if(customMarkersData.hasData) {
        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ToggleButtons (
              children: [
                Image.asset("assets/firehat279.png", width: 50),
                Image.asset("assets/firetruck279.png", width: 50),
                Image.asset("assets/emstruck279.png", width: 50)
              ],
              isSelected: _selections,
              onPressed: (int index) {
                setState(() {
                  _selections[index] = true;// = ! _selections[index];
                  for(int i = 0; i < _selections.length - 1; i++) {
                    _selections[ (index + i + 1) % _selections.length] = false;
                  }
                });
              }
            ),
            Expanded(
              child:   Container(
                width: double.infinity,
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
                                print("profile_dept.dart: I am a squadmate of squad: " + responder.squadID + " - " + responder.name);
                                print("profile_dept.dart: I'm displayed as eq=" + responder.icon);
                                if( !((_selections[0] && responder.icon =="helmet") ||
                                    (_selections[1] && responder.icon =="truck") ||
                                    (_selections[2] && responder.icon =="ems"))
                                ) {
                                  print("profile_dept.dart: returning null");
                                  return SizedBox();
                                }
                                return Card(
                                  shape: cardShape(),
                                  elevation: 15,
                                  shadowColor: Colors.black,
                                  child: ListTile(
                                      title: Column(
                                        children: <Widget>[
                                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                            Text(responder.name + " "),
                                            Container(
                                                child: Flexible(child: Text("[" + responder.rank + "]",
                                                  style: TextStyle(fontSize: 14.0),
                                                  overflow: TextOverflow.ellipsis,),)),


                                            responder.responding == "unbusy"
                                                ?
                                            Text("Ready", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))
                                                :
                                            Text("Responding",
                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[500]),)
                                          ]),

                                          responder.responding == "unbusy" || responder.responding == "" ? Text("") :
                                          StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance.collection("scenes").doc(
                                                  responder.responding).snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasError) {
                                                  return Text('Error: ${snapshot.error}');
                                                }
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return Text('Loading...Connection Waiting');
                                                }
                                                if (snapshot.hasData) {
                                                  return FutureBuilder<String>(
                                                      future: sceneFromSnapshot(snapshot.data).getAddress(),
                                                      builder: (context, address) {
                                                        if (address.hasError) {
                                                          return Text('Error: ${address.error}');
                                                        }
                                                        if (address.connectionState == ConnectionState.waiting) {
                                                          return Text('Loading...Connection Waiting2');
                                                        }
                                                        if (address.hasData)
                                                          return Text(address?.data ?? "-Address Loading-",
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(fontSize: 13.0),);
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
                                        print("profile_dept.dart: Responder to string is " + responder.uid.toString());
                                        Profile p = await getProfile(responder.uid);
                                        Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => ProfileTile(profile: p)));
                                      }
                                  ),
                                );
                              }).toList()
                          );
                      }
                    }
                ),
              ),
            ),

            Container (
                width: double.infinity,
                color: Colors.blue[500],
                alignment: Alignment.center,
                child: Text("TEMPORARY EQ LIST")
            ),
            Container (
              height: 200,
              width: double.infinity,
              decoration: customBoxDecoration(),
              child: StreamBuilder<List<Equipment>> (
                  stream: _eqStream,
                  builder: (BuildContext context, AsyncSnapshot<List<Equipment>> eqss) {
                    if (eqss.hasData) {
                      return ListView(
                          shrinkWrap: true,
                          children: eqss.data.map((Equipment eq) {
                            print("profile_dept.dart: Eq is " + eq.equipmentName);
                            if( !((_selections[0] && eq.iconName =="helmet") ||
                                (_selections[1] && eq.iconName =="truck") ||
                                (_selections[2] && eq.iconName =="ems"))
                            ) {
                              print("profile_dept.dart: returning null");
                              return SizedBox();
                            }
                            return Card(
                              shape: cardShape(),
                              elevation: 15,
                              shadowColor: Colors.black,
                              child: ListTile(
                                title: Text(eq.equipmentName),
                                  onTap: () async {
                                    print("profile_dept.dart: Tap to string is " + eq.equipmentName.toString());
                                    //get the list of profiles that are on this equipment
                                    //display them in this other page.
                                    List<Profile> riders = null;
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => EquipmentRiders(riders, eq)));
                                  }
                              ),
                            );
                          }).toList()
                      );
                    }
                    else {
                      return Text("Loading Equipment Data");
                    }
                  }
              ),
            ),
          ],
        );
      }
      else {
        return Text("Loading Assets..");
      }
        }
      ),
    );
  }
}
