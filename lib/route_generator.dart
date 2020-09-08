import 'package:flutter/material.dart';
import 'package:smartresponse4/Settings.dart';
import 'package:smartresponse4/chat.dart';
import 'package:smartresponse4/ICS.dart';
import 'package:smartresponse4/google_map.dart';
import 'package:smartresponse4/authenticate.dart';
import 'package:smartresponse4/messages_compose.dart';
import 'package:smartresponse4/profile_dept.dart';
import 'package:smartresponse4/scene_logistic.dart';
import 'package:smartresponse4/messages_with_private.dart';
import 'package:smartresponse4/scene_full.dart';
import 'package:smartresponse4/scene.dart';
import 'package:smartresponse4/user.dart';



class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    //final args = settings.arguments;

    switch (settings.name) {
      case '/chat':
        final Scene scene = settings?.arguments;
        if(scene != null ) {
          return MaterialPageRoute(builder: (_) => Chat(scene: scene));
        }
        else {
          return MaterialPageRoute(builder: (_) => Text("?? Loading CHAT Error ?? "));
        }
        break;

      case '/dms':
        return MaterialPageRoute(builder: (_) => PrivateMessage());

      case '/Department':
        print("route_generator.dart: " + EmailStorage.instance.userData.squadID + " is my squadID");
        return MaterialPageRoute(builder: (_) => DepartmentProfileList(EmailStorage.instance.userData.squadID));
        break;

      case '/Compose':
        return MaterialPageRoute(builder: (_) => ComposePrivateMessage(EmailStorage.instance.userData.squadID));
        break;

      case '/Logistics':
        final Scene scene = settings?.arguments;
        if(scene != null ) {
          return MaterialPageRoute(builder: (_) => Logistic(scene: scene));
        } else {
          return MaterialPageRoute(builder: (_) => Logistic());
        }
        break;
      case '/MyMapPage':
        final Scene scene = settings?.arguments;
        if(scene != null ) {
          return MaterialPageRoute(builder: (_) => MyMapPage(scene: scene));
        }
        else {
          return MaterialPageRoute(builder: (_) => MyMapPage());
        }
        break;
        // return MaterialPageRoute(builder: (_) => MyMapPage());


      case '/ICS':
        final Scene scene = settings?.arguments;
        if(scene != null ) {
          return MaterialPageRoute(builder: (_) => ICS(scene));
        }
        else {
          return MaterialPageRoute(builder: (_) => Text("?? Loading ICS Error ?? "));
        }
        break;

      case '/Settings':
        return MaterialPageRoute(builder: (_) => Settings());

      case '/FullSceneTile':
        final Scene scene = settings.arguments;
        return MaterialPageRoute(builder: (_) => FullSceneTile(scene: scene));
      default:
        return MaterialPageRoute(builder: (_) => Authenticate());
        //throw("Unknown navigation choice ... routegenerator");
    }


  }
}


