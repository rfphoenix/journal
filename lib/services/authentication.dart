import 'package:firebase_auth/firebase_auth.dart';
import 'package:journal/services/authentication_api.dart';

class AuthenticationService implements AuthenticationApi {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FirebaseAuth getFirebaseAuth() {
    return this._firebaseAuth;
  }

  @override
  Future<String> currentUserUid() async {
    User user = await this.getFirebaseAuth().currentUser;
    return user.uid;
  }

  @override
  Future<String> createUserWithEmailAndPassword(
      {String email, String password}) async {
    UserCredential user = await this
        .getFirebaseAuth()
        .createUserWithEmailAndPassword(email: email, password: password);

    return user.user.uid;
  }

  @override
  Future<bool> isEmailVerified() async {
    User user = await this.getFirebaseAuth().currentUser;
    return user.emailVerified;
  }

  @override
  Future<void> sendEmailVerification() async {
    User user = await this.getFirebaseAuth().currentUser;
    user.sendEmailVerification();
  }

  @override
  Future<String> signInWithEmailAndPassword(
      {String email, String password}) async {
    UserCredential user = await this
        ._firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);

    return user.user.uid;
  }

  @override
  Future<void> signOut() async {
    return await this.getFirebaseAuth().signOut();
  }
}
