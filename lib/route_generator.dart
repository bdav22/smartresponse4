import 'package:flutter/material.dart';
import 'package:smartresponse4/FirstPage.dart';
import 'package:smartresponse4/Settings.dart';
import 'package:smartresponse4/chat.dart';
import 'package:smartresponse4/home.dart';
import 'package:smartresponse4/main.dart';
import 'package:smartresponse4/ICS.dart';






class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/chat':
        return MaterialPageRoute(builder: (_) => Chat());

      case'/FirstPage':
        return MaterialPageRoute(builder: (_) => FirstPage());


      case '/ICS':
        return MaterialPageRoute(builder: (_) => ICS());

      case '/Settings':
        return MaterialPageRoute(builder: (_) => Settings());









        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ICS(),
          );
        }


        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => Chat(),
          );
        }


    }
  }
}