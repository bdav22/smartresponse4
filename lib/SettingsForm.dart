import 'package:flutter/material.dart';
import 'package:smartresponse4/constants.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/equipment.dart';
import 'package:smartresponse4/equipment_chooser.dart';
import 'package:smartresponse4/marker_chooser.dart';
import 'package:smartresponse4/marker_data.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/push_notifications.dart';
import 'package:smartresponse4/user.dart';




class SettingsForm extends StatefulWidget {

  final Profile userData;
  SettingsForm(this.userData);


  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    selectedPlacingMarker = MyMarker(shortName: "helmet");
    _currentIcon = widget.userData.icon;
    _currentEquipment = widget.userData.equipment;
  }

  // form values
  String _currentName;
  String _currentRank;
  String _currentDepartment;
  String _currentSquadID;
  String _currentIcon;
  String _currentEquipment;
  MyMarker selectedPlacingMarker;



  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
            children: <Widget>[
              SizedBox(height: 40.0),
              Text(
                'Update your profile settings.',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              RaisedButton(
                  color: Colors.blue[400],
                  child: Row(
                    children: <Widget>[
                      Text('Choose Your Marker ', style: TextStyle(color: Colors.white)),
                      Text('  Using:', style: TextStyle(color: Colors.blue[100])),
                      Image(image: AssetImage("assets/" + assetFromString(_currentIcon)), height: 40),
                    ],
                  ),
                  onPressed: () async {
                    await CustomMarkers.instance.getCustomMarkers();
                    selectedPlacingMarker = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) =>
                          ChooseMarker(markers: CustomMarkers.instance.myMarkerData, getMoreInfo: false)
                      ),
                    );
                    selectedPlacingMarker.desc =
                        EmailStorage.instance.email; //b/c every marker needs a unique descriptor
                    setState(() {
                      _currentIcon = selectedPlacingMarker?.shortName;
                    });
                    print("Settings.dart - CurrentIcon is = " + _currentIcon);
                    print("Settings.dart - User selected the following marker: " +
                        (selectedPlacingMarker?.commonName ?? "None selected") + " -- " +
                        (selectedPlacingMarker?.desc ?? "No Description") //also largely for the debugs^
                    );
                  }
              ),
              SizedBox(height: 10.0),
              RaisedButton(
                  color: Colors.blue[400],
                  child: Row(
                      children: <Widget>[
                        Text('Change Equipment', style: TextStyle(color: Colors.white)),
                        Flexible(child: Text( ' On: ' + _currentEquipment, style: TextStyle(color: Colors.blue[100]), overflow: TextOverflow.ellipsis,)),
                        //Image( image: AssetImage("assets/" + assetFromString(_currentEquipmentIcon)), height: 40 ),
                      ]),
                  onPressed: () async {
                    // userData is the profile already loaded
                    Equipment eq = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) =>
                            ChooseEquipment(profile: widget.userData),
                        ));
                    setState(() {
                      _currentEquipment = eq.equipmentName;
                    });
                    print("Settings.dart: selected equipment: " + _currentEquipment);
                  }
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: widget.userData.name,
                decoration: textInputDecoration.copyWith(hintText: 'Name'),
                validator: (val) => val.isEmpty ? 'Please enter a name' : null,
                onChanged: (val) => setState(() => _currentName = val),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: widget.userData.rank,
                decoration: textInputDecoration.copyWith(hintText: 'Rank'),
                validator: (val) => val.isEmpty ? 'Please enter a rank' : null,
                onChanged: (val) => setState(() => _currentRank = val),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: widget.userData.department,
                decoration: textInputDecoration.copyWith(hintText: 'Department'),
                validator: (val) => val.isEmpty ? 'Please enter a department' : null,
                onChanged: (val) => setState(() => _currentDepartment = val),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: widget.userData.squadID,
                decoration: textInputDecoration.copyWith(hintText: 'Departmental Code'),
                //validator: (val) => val.isEmpty ? 'Please enter a departmental code' : null,
                onChanged: (val) => setState(() => _currentSquadID = val),
              ),

              SizedBox(height: 40.0),
              RaisedButton(
                color: Colors.blue[400],
                child: Text('Modify Notifications', style: TextStyle(color: Colors.white)
                ),
                  onPressed: () async {

                  }
              ),
              RaisedButton(
                  color: Colors.blue[400],
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    PushNotificationsManager pnm = new PushNotificationsManager();
                    String _pnmtoken = await pnm.getToken();
                    print("profile has token:"+_pnmtoken);
                    if (_formKey.currentState.validate()) {
                      Profile p = Profile(
                        name: _currentName ?? widget.userData.name,
                        rank: _currentRank ?? widget.userData.rank,
                        department: _currentDepartment ?? widget.userData.department,
                        squadID: _currentSquadID ?? widget.userData.squadID,
                        email: EmailStorage.instance.email ?? widget.userData.email,
                        uid: widget.userData.uid ?? widget.userData.uid,
                        icon: _currentIcon ?? "helmet",
                        equipment: _currentEquipment ?? "unset",
                        token: _pnmtoken ?? "unset"
                      );
                      await DatabaseService(uid: widget.userData.uid).updateProfile(p);
                      EmailStorage.instance.userData = p;
                      //Navigator.pop(context);
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
            ]
        )
    );
  }
}