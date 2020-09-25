

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


/*
Color dark = Color.fromRGBO(0,33,2,1.0);
Color middark = Color.fromRGBO(2,55,5,1.0);
Color mid = Color.fromRGBO(10,60,10,1.0);
Color midlight = Color.fromRGBO(0,90,6,1.0);
Color light = Color.fromRGBO(0,132,9,1.0);
Color bright = Color.fromRGBO(140,200,140,1.0);
Color midbright = Color.fromRGBO(180,240,180,1.0);
Color midbright2 = Color.fromRGBO(200,250,200,1.0);
Color midbright3 = Color.fromRGBO(230,250,230,1.0);
Color superbright = Color.fromRGBO(255,255,255,1.0);
*/

//odds/evens in scene_home control some of the look and feel of that menu - use appropriately.

//Color appColorLight = Colors.blue[600];  //gradient start
Color appColorLight = Color.fromRGBO(6,123,194,1.0);
//Color appColorMiddleDark = Colors.blue[900]; //gradient end
Color appColorMiddleDark = Color.fromRGBO(49,63,77,1.0);
//Color appColorMid = Colors.blue[700];  //app bar bgcolor
Color appColorMid = Color.fromRGBO(27,38,79,1.0);
Color appColorMidLight = Colors.blue[600]; //text time/date on scenetiles
Color appColorDark = Colors.blue[900]; //text on text bars

Color appColorBright = Colors.blue[400]; //responding

Color appColorMidBright3 = Colors.white; //Colors.blue[100]; //bg on text bars
Color appColorSuperBright = Colors.white; //card bg colors

Color appColorMidBright = Colors.blue[300];
Color appColorMidBright2 = Colors.blue[200];

Color appColorGo = Colors.green; //green buttons - "GO" buttons
Color appColorButton = appColorMidLight; //blue buttons -- default button color
Color appColorUnusableButton = Colors.white;


Widget getMyButton(String text, Function f, {String color="default"}) {
  Color usedColor = appColorButton;
  switch(color) {
    case "invisible":
      usedColor = appColorUnusableButton;
      break;
    case "go":
      usedColor = appColorGo;
      break;
    case "default":
      break;
    default:
      break;
  }
  if(color == "invisible") {
    return SizedBox(width: 86);
  }
  return RaisedButton(
    color: usedColor,
    elevation: 5.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Text(text, style: TextStyle(color: Colors.white)),
    onPressed: f
  );
}




BoxDecoration customBoxDecoration({bool inverted=false}) {
  return BoxDecoration (
    gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        //colors: [Colors.grey[700], Colors.blueAccent[400]]),
      colors: inverted ? [appColorMiddleDark, appColorLight] : [appColorLight, appColorMiddleDark]),
  );
}


BoxDecoration myBoxDecoration() {
  return BoxDecoration(
    border: Border.all(
        width: 2.0
    ),
    borderRadius: BorderRadius.all(
        Radius.circular(10.0) //         <--- border radius here
    ),
  );
}

RoundedRectangleBorder cardShape() {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(11.0),
    side: BorderSide(
      color: Colors.grey[700],
      width: 2.0,
    ),
  );
}