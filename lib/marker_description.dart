import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/box_decoration.dart';
import 'package:smartresponse4/constants.dart';


class MarkerDescription extends StatelessWidget {

  // form values
  final myController = TextEditingController();

  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Marker Description'),
      ),
      body: Material(
        child: Container(
            padding:  EdgeInsets.fromLTRB(20.0, 6, 20, 0.0),
            decoration: customBoxDecoration(),
          child: Form(
          child: Column(
            children: <Widget>[
              SizedBox(height: 40.0),
              Container(width:double.infinity, padding: EdgeInsets.fromLTRB(10,10,10,10), child: Text(
                'Give Information For This Marker:',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              )),
              SizedBox(height: 40.0),
              TextFormField(
                  controller: myController,
                  decoration: textInputDecoration.copyWith(
                  hintText: 'Enter Your Marker Description Here'),
              ),
              SizedBox(height: 40.0),
              RaisedButton(
              color: Colors.blue[400],
              child: Text(
              'Submit Description',
              style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                String text = myController.text;
                print("text: " + text);
                Navigator.pop(context, text);
              }
              ),

          ]),
          )
        ),
      ),
    );

  }


}