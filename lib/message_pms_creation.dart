//this file is responsible for both checking if the existing pms might exist and then also creating the relevant connections if it indeed does not.abstract



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartresponse4/user.dart';

Future<DocumentReference> privateMessageGetOrCreate(String myUID, String theirUID, String theirName)  async {
    QuerySnapshot docs = await Firestore.instance.collection("profiles/" + myUID + "/private_messages").where("otheruid",isEqualTo: theirUID).limit(10).getDocuments();
    print(docs.documents.length);
    if(docs.documents.length > 0) {
      return docs.documents[0].reference;
    }

    DocumentReference newDoc = await Firestore.instance.collection("private_messages").add({
      'user1': EmailStorage.instance.userData.name,
      'user1uid': myUID,
      'user2': theirName,
      'user2uid': theirUID
    });

    Firestore.instance.collection("profiles").document(myUID).collection("private_messages").add({
      'dms': newDoc,
      'otheruser': theirName,
      'otheruid': theirUID
    });

    Firestore.instance.collection("profiles").document(theirUID).collection("private_messages").add({
      'dms': newDoc,
      'otheruser': EmailStorage.instance.userData.name,
      'otheruid': myUID
    });
    //then we need to create it and all its things
    return newDoc;
}