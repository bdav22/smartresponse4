import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/constants.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/scene.dart';
import 'package:provider/provider.dart';



class ICSSettings extends StatefulWidget {
  final Scene scene;
  ICSSettings(this.scene);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<ICSSettings> {

  final _formKey = GlobalKey<FormState>();
  //form values
  Profile _profile;
  String _currentPosition;

  Stream<List<Profile>> _squadStream;

  @override
  void initState() {
    super.initState();
    _squadStream = context.read<Repository>().getSquadProfiles(widget.scene.squad);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
        title: Text("ICS Selector"),
        backgroundColor: appColorMid,
    ),
    body: Material(
      child: Container(
        decoration: customBoxDecoration(),
        child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
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
                                  if (!snapshot.hasData) return Text("Loading..No data");
                                  return Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Card(
                                          child: InputDecorator(
                                              decoration: const InputDecoration.collapsed(
                                                //labelText: 'Activity',
                                                hintText: ' Select Person ',
                                                hintStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.0,
                                                  fontFamily: "OpenSans",
                                                  fontWeight: FontWeight.normal,
                                                ),
//                                                helperText: "Select Person",
                                                //contentPadding: EdgeInsets.all(10),
                                              ),
                                              isEmpty: _profile == null,
                                              child: Theme(
                                                data: Theme.of(context).copyWith(
                                                  canvasColor: appGradientBack,
                                                ),
                                                child: DropdownButton<Profile>(
                                                  isExpanded: true,
                                                  value: _profile,
                                                  isDense: false,
                                                  onChanged: (Profile newValue) {
                                                    setState(() {
                                                      _profile = newValue;
                                                      print("messages_compose.dart:" +
                                                          (_profile?.name ?? " null - ") +
                                                          " was selected");
                                                    });
                                                  },
                                                  items: snapshot.data.map((Profile p) {
                                                    return DropdownMenuItem<Profile>(
                                                      value: p,
                                                      child: Container(
                                                        decoration: dropDownBoxDecoration(),
                                                        padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Text(p.name , overflow: TextOverflow.ellipsis),
                                                            Flexible(child: Text(" - " + p.rank, overflow: TextOverflow.ellipsis),),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              )),
                                        ),
                                      ),
                                    ],
                                  );
                              }
                            }),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Position'),
                        validator: (val) => val.isEmpty? 'Please enter a position' : null,
                        onChanged: (val) => setState(() => _currentPosition = val),
                      ),

                      RaisedButton(
                          color: Colors.blue[400],
                          child: Text(
                            'Update',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              CommandPosition p = CommandPosition(_profile.name, _currentPosition, _profile.uid, widget.scene.ref.id, "tbd");
                              Repository(FirebaseFirestore.instance).updateICS(widget.scene.ref.id, p);
                              Navigator.pop(context);
                            }
                          }
                      ),
                      RaisedButton(
                        color: Colors.redAccent,
                        child: Text(
                          'Back',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                )
      ))
    );
              }
}