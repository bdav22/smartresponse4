
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/profile_tile.dart';

class Message extends StatelessWidget {
  final String from;
  final String text;
  final Timestamp sent;
  final String uid;
  final bool me;

  const Message({Key key, this.from, this.text, this.sent, this.uid, this.me}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
          onTap: () async {
            Profile p = await getProfile(this.uid);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileTile(profile: p)));
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: Card(
              child: Container (
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                child: Row (
                  children: <Widget>[
                    Padding ( padding: EdgeInsets.fromLTRB(2,0,10,0), child: CircleAvatar(
                      backgroundColor: Colors.black,
                    ),),
                    Expanded (
                      //padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      //decoration: BoxDecoration(color: Colors.green),
                      child: Column(
                        crossAxisAlignment: me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: <Widget>[
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                    Flexible (
                                      child: Text(
                                         "From: " + from ,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: DefaultTextStyle.of(context).style.fontSize * 1.25 ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ),
                                  Text (
                                    //sent?.toDate()?.toLocal()?.toString() ?? "broken date",
                                    "sent: " + (sent?.toDate()?.toLocal()?.toString()?.substring(5,16) ?? "BROKEN DATE"),
                                    style: TextStyle(color: Colors.blueGrey),
                                    overflow: TextOverflow.fade,
                                  ),
                                ]
                            ),
                            Container (
                              //TODO: decide if we want these next two lines in or not
                              //color: Colors.red,
                              //width: double.infinity, //CHANGE THIS TO SEE WHICH WE LIKE BETTER

                              //color: me ? Colors.teal : Colors.red,
                              //borderRadius: BorderRadius.circular(10.0),
                              //elevation: 6.0,
                              child:  DecoratedBox (
                                  decoration: BoxDecoration(
                                    /*
                                    boxShadow: [ BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ), ],
                                     */
                                    shape: BoxShape.rectangle,
                                    color: !me ? Colors.grey[100] : Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                child:  Padding( padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                                  child: Text( text, textDirection: me ? TextDirection.rtl : TextDirection.ltr, ),
                                ),
                              ),
                            ),
                          ],
                      ),
                    ),
                  ] ,
                ),
              ),
          ),
          )
      );
  }
}
