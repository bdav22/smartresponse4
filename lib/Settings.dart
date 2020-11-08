import 'package:flutter/material.dart';
import 'package:smartresponse4/SettingsForm.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/user.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/loading.dart';



class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  @override
  void initState() {
    super.initState();
  }





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
                //snapshot.hasData ? snapshot.data : UserData(name: "", rank: "", department: "");
                return SettingsForm(snapshot.data);
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