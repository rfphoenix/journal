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
      {String email, String password}) {
    // TODO: implement createUserWithEmailAndPassword
    throw UnimplementedError();
  }

  @override
  Future<bool> isEmailVerified() async {
    // TODO: implement isEmailVerified
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailVerification() async {
    // TODO: implement sendEmailVerification
    throw UnimplementedError();
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
