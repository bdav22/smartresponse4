import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/message_list_private.dart';
import 'package:smartresponse4/user.dart';

class PrivateMessage extends StatefulWidget {
  const PrivateMessage({Key key}) : super(key: key);

  @override
  _PrivateMessageState createState() => _PrivateMessageState();
}

class _PrivateMessageState extends State<PrivateMessage> {
  @override
  Widget build(BuildContext context) {
    String myuid = EmailStorage.instance.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Container(
        decoration: customBoxDecoration(),
        child: SafeArea(
          child:StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection("profiles/"+myuid+"/private_messages").snapshots(),
                  builder: (context, snapshot) {
                      if(snapshot.hasError) { return Text('Error: ${snapshot.error}');    }
                      if(snapshot.connectionState == ConnectionState.waiting) { return Text('Loading...'); }
                    //this is a singular profile of a specific user - from it, we make a streambuilder of its private messages
                    if(!snapshot.hasData) {
                      return Center ( child: CircularProgressIndicator() );
                    }
                    else {
                      List<Widget> messages = snapshot.data.documents.map((doc) =>
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,  MaterialPageRoute(builder: (context) =>
                                Scaffold(
                                    appBar: AppBar(
                                      title: Text('DMs with: ' + (doc['otheruser'] ?? "unknown")),
                                    ),
                                    body: PrivateMessageList(doc['dms'])),
                                    //Text("List to be updated here with " + (doc['otheruser'] ?? "unknown"))),
                            ));
                          },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(20.0,5,20.0,5),
                                  child: Card(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                                      child: Text("Messages with: " + (doc['otheruser'] ?? "unknown")),
                                  ),
                                ),
                            )
                        ),
                      ).toList();
                       return ListView(
                         children: [ ...messages],
                       );
                    }
                  }
                )
          )
        )
      );
  }
}
