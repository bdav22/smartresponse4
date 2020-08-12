import 'package:flutter/material.dart';
import 'package:smartresponse4/constants.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/user.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/loading.dart';



class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  final _formKey = GlobalKey<FormState>();


  // form values
  String _currentName;
  String _currentRank;
  String _currentDepartment;

  @override
  Widget build(BuildContext context) {

    User user = Provider.of<User>(context);

    return Material(
      child: StreamBuilder<UserData>(
          stream: DatabaseService(uid: user.uid).userData,
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              UserData userData = snapshot.data;
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
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Department'),
                      validator: (val) =>
                      val.isEmpty
                          ? 'Please enter a department'
                          : null,
                      onChanged: (val) =>
                          setState(() => _currentDepartment = val),
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
                            await DatabaseService(uid: user.uid).updateUserData(
                                _currentName ?? snapshot.data.name,
                                _currentRank ?? snapshot.data.rank,
                                _currentDepartment ?? snapshot.data.department,
                                EmailStorage.instance.email
                            );
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
                DatabaseService(uid: user.uid).createDBProfile();
                return Loading();
              }

          }
      ),
    );
  }
}