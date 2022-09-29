import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialmediaapp/models/userlocal.dart';
import 'package:socialmediaapp/screens/forgotmypassword.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? currentUserId;

  UserLocal? _createUser(User? user) {
    return user == null ? null : UserLocal.createUserByFirebase(user);
  }

  Stream<UserLocal?> get stateFollower {
    return _firebaseAuth.authStateChanges().map((event) => _createUser(event));
  }

  createUserByMail(String? email, String? password) async {
    if (email == null || password == null) {
      return null;
    }
    var loginCard = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return UserLocal.createUserByFirebase(loginCard.user);
  }

  loginUserByMail(String? email, String? password) async {
    if (email == null || email == "") {
      return null;
    } else if (password == null || password == "") {
      return null;
    }
    var loginCard = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return UserLocal.createUserByFirebase(loginCard.user);
  }

  loginWithGoogle() async {
    GoogleSignInAccount? googleAccount = await GoogleSignIn().signIn();
    GoogleSignInAuthentication myGoogleAuthCard =
        await googleAccount!.authentication;
    AuthCredential loginDocByNotUsingPassword =
        await GoogleAuthProvider.credential(
            idToken: myGoogleAuthCard.idToken,
            accessToken: myGoogleAuthCard.accessToken);
    UserCredential loginCard =
        await _firebaseAuth.signInWithCredential(loginDocByNotUsingPassword);

    return _createUser(loginCard.user);
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  Future<void> ForgotMyPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
