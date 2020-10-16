import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartresponse4/auth.dart';
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/loading.dart';
import 'package:smartresponse4/push_notifications.dart';
//import 'package:smartresponse4/route_generator.dart';
import 'package:smartresponse4/user.dart';
import 'package:smartresponse4/wrapper.dart';



void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PushNotificationsManager pushNotificationsManager;
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  void initState () {
    pushNotificationsManager = new PushNotificationsManager();
    pushNotificationsManager.init();
    //super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Cannot connect to services at this time");
        }
        if(snapshot.connectionState == ConnectionState.waiting) {
          print("main.dart: Connectionstate is waiting in initialization of the app");
          return Text("Loading..");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Provider<Repository>(
              create: (_) => Repository(FirebaseFirestore.instance),
              child: StreamProvider.value(
                value: AuthService().user,
                child: StreamProvider<User>.value(
                  value: AuthService().user,
                  child: MaterialApp(
                    home: Wrapper(),
                  ),
                ),
              )
          );
        }
        // Otherwise, show something whilst waiting for initialization to complete
        return Loading();
      }
    );
  }
}


