import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/marker_data.dart';



class MarkerInfo extends StatelessWidget {
  final DocumentReference ref;
  final String title;
  final String snippet;
  final String icon;

  MarkerInfo(this.ref, this.title, this.snippet, this.icon);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text("Marker Information"),
        backgroundColor: appColorMid,
    ),
        body: Container(
          width: double.infinity,
          decoration: customBoxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Card(
                shape: cardShape(),
                elevation: 15,
                shadowColor: Colors.black,
                    child: Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        child: Text("Title: " + title,
                          style: TextStyle(fontSize: 14.0),
                        )
                    ),
              ),
              Card(
                shape: cardShape(),
                elevation: 15,
                shadowColor: Colors.black,
                child: Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    child: Text("Info: " + snippet,
                      style: TextStyle(fontSize: 14.0),
                    )
                ),
              ),
              Card(
                shape: cardShape(),
                elevation: 15,
                shadowColor: Colors.black,
                child: Container(
                    padding: EdgeInsets.all(10),
                    width: 150,
                    child: Image.asset("assets/" + assetFromString(icon), width: 50),
                ),
              ),
              RaisedButton(
                color: Colors.redAccent,
                child: Text(
                  'Remove This Marker',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  ref.delete();
                  Navigator.pop(context);
                },
              ),
              RaisedButton(
                color: Colors.green[500],
                child: Text(
                  'Back',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
    );
  }
}