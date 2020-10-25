import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/constants.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/marker_chooser.dart';
import 'package:smartresponse4/marker_data.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/user.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/loading.dart';



class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    selectedPlacingMarker = MyMarker(shortName: "truck");
  }

  // form values
  String _currentName;
  String _currentRank;
  String _currentDepartment;
  String _currentSquadID;
  MyMarker selectedPlacingMarker;

  @override
  Widget build(BuildContext context) {

    User user = Provider.of<User>(context);
    if(user == null) {
      print("Settings.dart: user is null and is currently loading - please hold");
      return Loading();
    }
    return Material(
      child: Container(
        decoration: customBoxDecoration(),
        child: StreamBuilder<Profile>(
            stream: DatabaseService(uid: user.uid).profile,
            builder: (context, snapshot) {
              if(snapshot.hasError) {
                print('Settings.dart -- ${snapshot.error}');
                return Flexible(child: Text('--', overflow: TextOverflow.ellipsis));
            }
             if(snapshot.connectionState == ConnectionState.waiting) {
               print("Settings.dart: connection stream is waiting right now");
               return Text("()");
             }

              if(snapshot.hasData) {
                print("Settings.dart: in database service user.uid is " + user.uid);
                Profile userData = snapshot.data;
                //snapshot.hasData ? snapshot.data : UserData(name: "", rank: "", department: "");
                return Form(
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
                        initialValue: userData.name,
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Name'),
                        validator: (val) =>
                        val.isEmpty
                            ? 'Please enter a name'
                            : null,
                        onChanged: (val) => setState(() => _currentName = val),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        initialValue: userData.rank,
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Rank'),
                        validator: (val) =>
                        val.isEmpty
                            ? 'Please enter a rank'
                            : null,
                        onChanged: (val) => setState(() => _currentRank = val),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        initialValue: userData.department,
                        decoration: textInputDecoration.copyWith(hintText: 'Department'),
                        validator: (val) => val.isEmpty ? 'Please enter a department'  : null,
                        onChanged: (val) => setState(() => _currentDepartment = val),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        initialValue: userData.squadID,
                        decoration: textInputDecoration.copyWith(hintText: 'Departmental Code'),
                        //validator: (val) => val.isEmpty ? 'Please enter a departmental code' : null,
                        onChanged: (val) => setState(() => _currentSquadID = val),
                      ),
                      SizedBox(height: 10.0),
                      RaisedButton(
                        color: Colors.blue[400],
                        child: Text( 'Choose a Marker', style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          await CustomMarkers.instance.getCustomMarkers();
                          selectedPlacingMarker = await Navigator.push(context,
                            MaterialPageRoute(builder: (context) =>
                                ChooseMarker(markers: CustomMarkers.instance.myMarkerData, getMoreInfo: false)
                            ),
                          );
                          selectedPlacingMarker.desc =  EmailStorage.instance.email;
                          print("Settings.dart - User selected the following marker: " +
                              (selectedPlacingMarker?.commonName ?? "None selected") + " -- " +
                              (selectedPlacingMarker?.desc ?? "No Description")
                          );
                        }
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
                              Profile p = Profile(name: _currentName ?? snapshot.data.name,
                                  rank: _currentRank ?? snapshot.data.rank,
                                  department: _currentDepartment ?? snapshot.data.department,
                                  squadID: _currentSquadID ?? snapshot.data.squadID,
                                  email: EmailStorage.instance.email,
                                  uid: user.uid,
                                  responding: snapshot.data.responding,
                                  icon: selectedPlacingMarker.shortName,
                              );
                              await DatabaseService(uid: user.uid).updateProfile(p);
                              EmailStorage.instance.userData = p;
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
                );
              }
                else {
                  print("Settings.dart - hasData was null, waiting on that");
                  //DatabaseService(uid: user.uid).createDBProfile();
                  return Loading();
                }

            }
        ),
      ),
    );
  }
}