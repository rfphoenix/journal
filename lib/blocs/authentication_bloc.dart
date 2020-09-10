import 'dart:async';
import 'package:journal/services/authentication_api.dart';

class AuthenticationBloc {
  final AuthenticationApi authenticationApi;
  final StreamController<String> _authenticationController =
      StreamController<String>();
  Sink<String> get addUser => this._authenticationController.sink;
  Stream<String> get user => this._authenticationController.stream;
  final StreamController<bool> _logoutController = StreamController<bool>();
  Sink<bool> get logoutUser => this._logoutController.sink;
  Stream<bool> get listLogoutUser => this._logoutController.stream;

  AuthenticationBloc(this.authenticationApi) {
    this.onAuthChanged();
  }

  void dispose() {
    this._authenticationController.close();
    this._logoutController.close();
  }

  void onAuthChanged() {
    print('trying to authenticate....');
    this.authenticationApi.getFirebaseAuth().authStateChanges().listen((user) {
      final String uid = user != null ? user.uid : null;
      print('$uid');
      addUser.add(uid);
    });

    this._logoutController.stream.listen((logout) {
      if (logout == true) {
        this._signOut();
      }
    });
  }

  void _signOut() {
    this.authenticationApi.signOut();
  }
}
