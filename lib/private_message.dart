import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/box_decoration.dart';
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
                    //this is a singular profile of a specific user - from it, we make a streambuilder of its private messages
                    if(!snapshot.hasData) {
                      return Center ( child: CircularProgressIndicator() );
                    }
                    else {
                      List<Widget> messages = snapshot.data.documents.map((doc) =>
                        GestureDetector(
                          onTap: () {
                              //TODO: bring up the full list of messages here - can we pass off to Message.dart?
                            Navigator.push(context,  MaterialPageRoute(builder: (context) =>
                                Scaffold(
                                    appBar: AppBar(
                                      title: Text('DMs with: ' + ( doc['user1'] == EmailStorage.instance.email ? doc['user2']: doc['user1'])),
                                    ),
                                    body: Text("List to be updated here with " + ( doc['user1'] == EmailStorage.instance.email ? doc['user2']: doc['user1']))),
                            ));
                          },
                            child: Card(
                              child: Text("Messages with: " + ( doc['user1'] == EmailStorage.instance.email ? doc['user2']: doc['user1'])),
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
