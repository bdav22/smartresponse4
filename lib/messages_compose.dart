import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/chat.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/message_list_private.dart';
import 'package:smartresponse4/message_pms_creation.dart';
import 'package:smartresponse4/profile.dart';
import 'package:smartresponse4/user.dart';
import 'package:smartresponse4/database.dart';
import 'package:provider/provider.dart';

class ComposePrivateMessage extends StatefulWidget {
  final String squadID;
  const ComposePrivateMessage(this.squadID, {Key key}) : super(key: key);


  @override
  _ComposePrivateMessageState createState() => _ComposePrivateMessageState();
}

class _ComposePrivateMessageState extends State<ComposePrivateMessage> {
  Stream<List<Profile>> _squadStream;
  Profile _profile;

  TextEditingController messageController = TextEditingController();




  Future<void> sendMessageCallback() async {
    if(_profile == null) {
      //error here
      print("messages_compose.dart: ERROR in messages_compose _uid=" + (_profile?.uid ?? "uid null") + "  _name=" + (_profile?.name ?? "name null"));
      return;
    }
    DocumentReference pmsRef = await privateMessageGetOrCreate(EmailStorage.instance.uid, _profile.uid, _profile.name);
    if (messageController.text.length > 0) {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      //print("log this: "+  messageController.text + " " + user_email);
      await pmsRef.collection('messages').add({
        'text': messageController.text,
        'from': EmailStorage.instance.userData.name,
        'from-uid': user.uid,
        'sent': FieldValue.serverTimestamp()
      });
      messageController.clear();
    }
    Navigator.pop(context);

    Navigator.push(context,  MaterialPageRoute(builder: (context) =>
        Scaffold(
            appBar: AppBar(
              title: Text('DMs with: ' + (_profile?.name ?? "unknown")),
              backgroundColor: appColorMid,
            ),
            body: PrivateMessageList(pmsRef),)
      //Text("List to be updated here with " + (doc['otheruser'] ?? "unknown"))),
    ));
  }


  @override
  void initState() {
    super.initState();
    _squadStream = context.read<Repository>().getSquadProfiles(widget.squadID);
  }




  @override
  Widget build(BuildContext context) {    return Scaffold (
    appBar: AppBar(
      title: Text('Smart Response'),
      backgroundColor: appColorMid,
      elevation: 0.0,
    ),
    body: Container(
      decoration: customBoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            child: StreamBuilder<List<Profile>>(
                stream: _squadStream,
                builder: (BuildContext builder, AsyncSnapshot<List<Profile>> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Text('Loading...');
                    default:
                      if(!snapshot.hasData) return Text("Loading..No data");
                      return Row(
                          children: <Widget>[
                            Card(child:
                            Container(padding: EdgeInsets.all(15), child: Text("To: ")) ),
                            Expanded(
                              child: Card(
                                child: InputDecorator(
                                    decoration: const InputDecoration(
                                      //labelText: 'Activity',
                                      hintText: '   Select',
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: "OpenSans",
                                        fontWeight: FontWeight.normal,
                                      ),
                                      helperText: "Select Message Recipient",
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                    isEmpty: _profile == null,
                                    child:
                                          DropdownButton<Profile>(
                                          value: _profile,
                                          isDense: true,
                                          onChanged: (Profile newValue) {
                                            setState(() {
                                              _profile = newValue;
                                              print("messages_compose.dart:" + ( _profile?.name ?? " null - " ) + " was selected");
                                            });
                                          },
                                          items: snapshot.data.map((Profile p) {
                                            return new DropdownMenuItem<Profile>(
                                              value: p,
                                              child: new Container( decoration: myBoxDecoration(), padding: EdgeInsets.fromLTRB(10,2,10,0),
                                                                  child: Text(p.name))
                                            );
                                          }).toList(),
                                        )
                                ),
                              ),
                            ),
                          ],
                        );

                  }
                }
            ),
          ),
          Expanded(child: Text("-")),
          Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    onSubmitted: (value) => sendMessageCallback(),
                    decoration: InputDecoration(
                      hintText: "Enter a Message...",
                      border: const OutlineInputBorder(),
                    ),
                    controller: messageController,
                  ),
                ),
                SendButton(
                  text: "Send",
                  callback: sendMessageCallback,
                )
              ],
            ),
          ),


        ],
      ),
    ),
  );
  }
}
