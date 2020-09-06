import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/constants.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/scene.dart';



class ICSSettings extends StatefulWidget {
  final Scene scene;
  ICSSettings(this.scene);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<ICSSettings> {

  final _formKey = GlobalKey<FormState>();


  // form values
  String _currentName;
  String _currentPosition;

  @override
  Widget build(BuildContext context) {

    return Material(
      child: Container(
        decoration: customBoxDecoration(),
        child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 40.0),
                      Text(
                        'Update your profile settings.',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      SizedBox(height: 40.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Name'),
                        validator: (val) => val.isEmpty ? 'Please enter a name'  : null,
                        onChanged: (val) => setState(() => _currentName = val),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Position'),
                        validator: (val) => val.isEmpty? 'Please enter a rank' : null,
                        onChanged: (val) => setState(() => _currentPosition = val),
                      ),
                      SizedBox(height: 40.0),
                      RaisedButton(
                          color: Colors.blue[400],
                          child: Text(
                            'Update',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              CommandPosition p = CommandPosition(_currentName, _currentPosition, false);
                              Repository(Firestore.instance).updateICS(widget.scene.ref.documentID, p);
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
                )));
              }
}