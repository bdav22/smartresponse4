//this file is responsible for both checking if the existing pms might exist and then also creating the relevant connections if it indeed does not.abstract



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartresponse4/user.dart';

Future<DocumentReference> privateMessageGetOrCreate(String myUID, String theirUID, String theirName)  async {
    QuerySnapshot docs = await FirebaseFirestore.instance.collection("profiles/" + myUID + "/private_messages").where("otheruid",isEqualTo: theirUID).limit(10).get();

    if(docs.docs.length > 0) {
      print("message_pms_creation.dart: " + docs.docs.length.toString() + " "  + docs.docs[0].id);
      return docs.docs[0].data()['dms'];
    }
    print("message_pms_creation.dart: " + "setting up private messages");

    DocumentReference newDoc = await FirebaseFirestore.instance.collection("private_messages").add({
      'user1': EmailStorage.instance.userData.name,
      'user1uid': myUID,
      'user2': theirName,
      'user2uid': theirUID
    });

    FirebaseFirestore.instance.collection("profiles").doc(myUID).collection("private_messages").add({
      'dms': newDoc,
      'otheruser': theirName,
      'otheruid': theirUID
    });

    FirebaseFirestore.instance.collection("profiles").doc(theirUID).collection("private_messages").add({
      'dms': newDoc,
      'otheruser': EmailStorage.instance.userData.name,
      'otheruid': myUID
    });
    //then we need to create it and all its things
    return newDoc;
}