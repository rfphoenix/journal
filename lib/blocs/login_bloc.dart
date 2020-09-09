import 'dart:async';
import 'package:journal/classes/validator.dart';
import 'package:journal/services/authentication_api.dart';

class LoginBloc with Validators {
  final AuthenticationApi authenticationApi;
  String _email;
  String _password;
  bool _emailValid;
  bool _passwordValid;

  final StreamController<String> _emailController =
      StreamController<String>.broadcast();
  Sink<String> get emailChanged => this._emailController.sink;
  Stream<String> get email =>
      this._emailController.stream.transform(validateEmail);

  final StreamController<String> _passwordController =
      StreamController<String>.broadcast();
  Sink<String> get passwordChanged => this._passwordController.sink;
  Stream<String> get password =>
      this._passwordController.stream.transform(validatePassword);

  final StreamController<bool> _enableLoginCreateButtonController =
      StreamController<bool>.broadcast();
  Sink<bool> get enableLoginCreateButtonChanged =>
      this._enableLoginCreateButtonController.sink;
  Stream<bool> get enableLoginCreateButton =>
      this._enableLoginCreateButtonController.stream;

  final StreamController<String> _loginOrCreateButtonController =
      StreamController<String>();
  Sink<String> get loginOrCreateButtonChanged =>
      this._loginOrCreateButtonController.sink;
  Stream<String> get loginOrCreateButton =>
      this._loginOrCreateButtonController.stream;

  final StreamController<String> _loginOrCreateController =
      StreamController<String>();
  Sink<String> get loginOrCreateChanged => this._loginOrCreateController.sink;
  Stream<String> get loginOrCreate => this._loginOrCreateController.stream;

  LoginBloc({this.authenticationApi}) {
    this._startListenersIfEmailPasswordAreValid();
  }

  void dispose() {
    this._passwordController.close();
    this._emailController.close();
    this._enableLoginCreateButtonController.close();
    this._loginOrCreateButtonController.close();
    this._loginOrCreateController.close();
  }

  void _startListenersIfEmailPasswordAreValid() {
    email.listen((email) {
      this._email = email;
      this._emailValid = true;
      this._updateEnableLoginCreateButtonStream();
    }).onError((error) {
      this._email = '';
      this._emailValid = false;
      this._updateEnableLoginCreateButtonStream();
    });

    password.listen((password) {
      this._password = password;
      this._passwordValid = true;
      this._updateEnableLoginCreateButtonStream();
    }).onError((error) {
      this._password = '';
      this._passwordValid = false;
      this._updateEnableLoginCreateButtonStream();
    });

    loginOrCreate.listen((action) {
      action == 'Login' ? _logIn() : _createAccount();
    });
  }

  void _updateEnableLoginCreateButtonStream() {
    if (this._emailValid == true && this._emailValid == true) {
      this.enableLoginCreateButtonChanged.add(true);
    } else {
      this.enableLoginCreateButtonChanged.add(false);
    }
  }

  Future<String> _logIn() async {
    String result = '';
    if (this._emailValid && this._passwordValid) {
      await this
          .authenticationApi
          .signInWithEmailAndPassword(
              email: this._email, password: this._password)
          .then((user) {
        result = 'Success';
      }).catchError((error) {
        print('Login error: $error');
        result = error;
      });
      return result;
    } else {
      return 'Email and Password are not valid';
    }
  }

  Future<String> _createAccount() async {
    String result = '';
    if (this._emailValid && this._passwordValid) {
      await this
          .authenticationApi
          .createUserWithEmailAndPassword(
              email: this._email, password: this._password)
          .then((user) {
        print('Created user: $user');
        result = 'Created user: $user';
        this
            .authenticationApi
            .signInWithEmailAndPassword(
                email: this._email, password: this._password)
            .then((user) {})
            .catchError((error) async {
          print('Login error: $error');
          result = error;
        });
      }).catchError((error) async {
        print('Creating user error: $error');
      });
      return result;
    } else {
      return 'Error creating user';
    }
  }
}
