import 'package:flutter/material.dart';
import 'package:smartresponse4/Settings.dart';
import 'package:smartresponse4/chat.dart';
import 'package:smartresponse4/ICS.dart';
import 'package:smartresponse4/google_map.dart';
import 'package:smartresponse4/authenticate.dart';
import 'package:smartresponse4/private_message.dart';
import 'package:smartresponse4/scene_full.dart';
import 'package:smartresponse4/scene.dart';



class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    //final args = settings.arguments;

    switch (settings.name) {
      case '/chat':
        return MaterialPageRoute(builder: (_) => Chat());

      case '/dms':
        return MaterialPageRoute(builder: (_) => PrivateMessage());

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
        return MaterialPageRoute(builder: (_) => ICS());

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


