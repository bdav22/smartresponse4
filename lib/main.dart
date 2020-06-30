import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:smartresponse4/auth.dart';

import 'package:smartresponse4/route_generator.dart';
import 'package:smartresponse4/user.dart';
import 'package:smartresponse4/wrapper.dart';



void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {



  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      value: AuthService().user,
      child: StreamProvider<User>.value(
        value: AuthService().user,
        child: MaterialApp(
          home: Wrapper(),
          initialRoute: '/',
          onGenerateRoute: RouteGenerator.generateRoute,
        ),
      ),
    );
  }
}
