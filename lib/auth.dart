import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:smartresponse4/database.dart';
import 'package:smartresponse4/user.dart';

class AuthService {

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;


  //create user object based on FirebaseUser
  User _userFromFirebaseUser(auth.User user) {
    return user !=null ? User(uid: user.uid) : null;
  }

  //auth change user stream
  Stream<User> get user {
    return _auth.authStateChanges()
        .map(_userFromFirebaseUser);
  }

  // sign in anon
  Future signInAnon() async {
    try {
      auth.UserCredential result = await _auth.signInAnonymously();
      auth.User user = result.user;
      return _userFromFirebaseUser(user);
    } catch(e) {
      print("auth.dart: Error: " + e.toString());
      return null;
    }
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      auth.UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      auth.User user= result.user;
      return _userFromFirebaseUser(user);
      //await DatabaseService(uid: user.uid).updateUserData('John Smith', 'Captain', 'Goodwill Fire');

    } catch(e){
      print("auth.dart: Error: " + e.toString());
      return null;
    }
  }
  //register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      auth.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      auth.User user= result.user;

      //create a new document for the user with the uid
      await DatabaseService(uid: user.uid).createDBProfile(user.email);

      return _userFromFirebaseUser(user);
    } catch(e){
      print("auth.dart: Error: " + e.toString());
      return null;
    }
  }
  //sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e){
      print("auth.dart: Error: " + e.toString());
      return null;
    }
  }
}