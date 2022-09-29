import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserLocal {
  final String id;
  final String username;
  final String pphoto;
  final String email;
  final String about;

  UserLocal(
      {required this.id,
      required this.username,
      required this.pphoto,
      required this.email,
      this.about = ""});

  factory UserLocal.createUserByFirebase(User? user) {
    return UserLocal(
        id: user!.uid,
        username: user.displayName.toString(),
        pphoto: user.photoURL.toString(),
        email: user.email.toString());
  }

  factory UserLocal.createUserByDoc(DocumentSnapshot doc) {
    return UserLocal(
        id: doc.id,
        username: doc.get("username"),
        pphoto: doc.get("pphoto"),
        email: doc.get("email"),
        about: doc.get("about"));
  }
}
