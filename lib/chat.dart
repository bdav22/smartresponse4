import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:smartresponse4/user.dart';
import 'package:smartresponse4/profile_tile.dart';
import 'package:smartresponse4/profile.dart';






class Chat extends StatefulWidget {
  const Chat({Key key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  final EmailStorage es = EmailStorage.instance;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  Future<void> sendMessageCallback() async {
    if (messageController.text.length > 0) {
      FirebaseUser user = await _auth.currentUser();
      //print("log this: "+  messageController.text + " " + user_email);
      await
      _firestore.collection('messages').add({
        'text': messageController.text,
        'from': EmailStorage.instance.userData.name,
        'from-uid': user.uid,
        'sent': FieldValue.serverTimestamp()
      });
      messageController.clear();

      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  void initState() {
    super.initState();
   }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('messages').orderBy('sent', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  List<DocumentSnapshot> docs = snapshot.data.documents;

                  List<Widget> messages = docs
                      .map((doc) => Message(
                    from: doc.data['from'],
                    text: doc.data['text'],
                    sent: doc.data['sent'],
                    uid: doc.data['from-uid'],
                    me: doc.data['from-uid'] == es.uid,
                  ))
                      .toList();

                  return ListView(
                    reverse: true,
                    controller: scrollController,
                    children: [
                      ...messages,
                    ],
                  );
                },
              ),
            ),
            Container(child: Row(
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

class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({Key key, this.text, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.orangeAccent,
      onPressed: callback,
      child: Text(text),
    );
  }
}

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
      child: Column(
        crossAxisAlignment: me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  from,
                ),
                Text (
                  //sent?.toDate()?.toLocal()?.toString() ?? "broken date",
                  sent?.toDate()?.toLocal()?.toString()?.substring(0,19) ?? "BROKEN DATE",
                  style: TextStyle(color: Colors.blueGrey),
                )
              ]
          ),
          Material(
            color: me ? Colors.teal : Colors.red,
            borderRadius: BorderRadius.circular(10.0),
            elevation: 6.0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Text( text ),
            ),
          ),
        ],
      ),
    )
      );
  }
}
