
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/decoration.dart';
//import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/equipment.dart';
//import 'package:smartresponse4/equipment_riders.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/push_notifications.dart';


class NotificationsSelection extends StatefulWidget {
  final squadID;
  final uid;
  NotificationsSelection(this.squadID, this.uid);

  @override
  _NotificationsSelectionState createState() => _NotificationsSelectionState();
}

class _NotificationsSelectionState extends State<NotificationsSelection> {
  List<String> touched = [];
  Stream<List<Equipment>> _eqStream;
  Stream<List<String>> _notificationStream;
  Map<String, bool> values = {};



  @override
  void initState() {
    super.initState();
    _eqStream = context.read<Repository>().getEquipment(widget.squadID);
    _notificationStream = context.read<Repository>().getNotifications(widget.uid);
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Select Equipment Notifications')),
      body: Container(
        //decoration: customBoxDecoration(),
        child: Column(
          children: <Widget>[
            RaisedButton(
                color: Colors.blue[400],
                child: Text('Save and Go Back', style: TextStyle(color: Colors.white)
                ),
                onPressed: () async {
                  PushNotificationsManager pnm = PushNotificationsManager();
                  String _pnmtoken = await pnm.getToken();
                  for(String t in touched) {
                    bool v = values[t];
                    print("key: $t, value: " + v.toString());
                    String documentLocation = "departments/" + widget.squadID + "/equipment/$t/alerts/$_pnmtoken";
                    DocumentReference dr = FirebaseFirestore.instance.doc(documentLocation);
                    String profileLocation = "profiles/" + widget.uid + "/notifications/" + t;
                    DocumentReference pr = FirebaseFirestore.instance.doc(profileLocation);
                    print(documentLocation);
                    if(v) { //add this to the right place
                      dr.set( { "msg_id": _pnmtoken});
                      pr.set( { "eq": t } );
                    } else { //remove it from the right place
                      dr.delete();
                      pr.delete();
                    }

                  }

                  Navigator.pop(context);
                }
            ),
            Expanded(
              child: StreamBuilder< List<String> > (
                stream:_notificationStream,
                    builder: (BuildContext context, AsyncSnapshot<List<String>> notified) {

                  if(notified.hasData) {
                    print("notificiations.dart: " + notified.data.toString());

                    return StreamBuilder<List<Equipment>>(
                        stream: _eqStream,
                        builder: (BuildContext context, AsyncSnapshot<List<Equipment>> eqss) {
                          if (eqss.hasData) {
                            return ListView(
                                shrinkWrap: true,
                                children: eqss.data.map((Equipment eq) {
                                  return CheckboxListTile(
                                      title: new Text(eq?.equipmentName ?? "-"),
                                      value:  values.containsKey(eq?.equipmentName ?? "*-*") ? values[eq?.equipmentName ?? "*-*"] == true : notified.data.contains(eq?.equipmentName ?? "*-*"),
                                      onChanged: (bool value) {
                                        setState(() {
                                          values[eq.equipmentName] = value;
                                          if(!touched.contains(eq.equipmentName)) {
                                            touched.add(eq.equipmentName);
                                          }
                                          else {
                                            touched.remove(eq.equipmentName);
                                          }
                                        });
                                      }
                                  );
                                }).toList()
                            );
                          }
                          else {
                            return Text("Loading Equipment Data");
                          }
                        }
                    );
                  } //end notified has data
                      else {
                        return Text("Loading Notification Data");
                  }
                    } ),
            ),

          ],
        ),
      )
    );

/*
    new ListView(
        children: values.keys.map((String key) {
          return new CheckboxListTile(
            title: new Text(key),
            value: values[key],
            onChanged: (bool value) {
              setState(() {
                values[key] = value;
              });
            },
          );
        }).toList(),
      ),
    );
 */
  }
}
