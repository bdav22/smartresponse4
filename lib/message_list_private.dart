


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartresponse4/decoration.dart';
import 'package:smartresponse4/chat.dart';
import 'package:smartresponse4/message.dart';
import 'package:smartresponse4/user.dart';

class PrivateMessageList extends StatefulWidget {

  final DocumentReference pmsRef;
  const PrivateMessageList(this.pmsRef, {Key key}) : super(key: key);
  _PrivateMessageListState createState() => _PrivateMessageListState();


}


class _PrivateMessageListState extends State<PrivateMessageList> {

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }


  Future<void> sendMessageCallback() async {
    if (messageController.text.length > 0) {
      auth.User user = auth.FirebaseAuth.instance.currentUser;
      //print("log this: "+  messageController.text + " " + user_email);
      await widget.pmsRef.collection('messages').add({
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


  Widget build(BuildContext context) {
    return Container(
      decoration: customBoxDecoration(),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: widget.pmsRef.collection('messages').orderBy('sent', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  List<DocumentSnapshot> docs = snapshot.data.docs;

                  List<Widget> messages = docs
                      .map((doc) => Message(
                    from: doc.data()['from'],
                    text: doc.data()['text'],
                    sent: doc.data()['sent'],
                    uid: doc.data()['from-uid'],
                    me: doc.data()['from-uid'] == EmailStorage.instance.uid,
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
