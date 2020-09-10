import 'package:flutter/material.dart';
import 'package:journal/blocs/login_bloc.dart';
import 'package:journal/services/authentication.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    this._loginBloc = LoginBloc(authenticationApi: AuthenticationService());
  }

  @override
  void dispose() {
    this._loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
            child: Icon(
              Icons.account_circle,
              size: 88.0,
              color: Colors.white,
            ),
            preferredSize: Size.fromHeight(40.0)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder(
                stream: this._loginBloc.email,
                builder: (BuildContext context, AsyncSnapshot snapshot) =>
                    TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    icon: Icon(Icons.mail_outline),
                    errorText: snapshot.error,
                  ),
                  onChanged: this._loginBloc.emailChanged.add,
                ),
              ),
              StreamBuilder(
                stream: this._loginBloc.password,
                builder: (BuildContext context, AsyncSnapshot snapshot) =>
                    TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      icon: Icon(Icons.security),
                      errorText: snapshot.error),
                  onChanged: this._loginBloc.passwordChanged.add,
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              this._buildLoginAndCreateButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginAndCreateButtons() {
    return StreamBuilder(
        initialData: 'Login',
        stream: this._loginBloc.loginOrCreateButton,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == 'Login') {
            return this._buttonsLogin();
          } else if (snapshot.data == 'Create Account') {
            return this._buttonsCreateAccount();
          }
        });
  }

  Column _buttonsLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        StreamBuilder(
          initialData: false,
          stream: this._loginBloc.enableLoginCreateButton,
          builder: (BuildContext context, AsyncSnapshot snapshot) =>
              RaisedButton(
            elevation: 16.0,
            child: Text('Login'),
            color: Colors.lightGreen.shade200,
            disabledColor: Colors.grey.shade100,
            onPressed: snapshot.data
                ? () => this._loginBloc.loginOrCreateButtonChanged.add('Login')
                : null,
          ),
        ),
        FlatButton(
            onPressed: () {
              this._loginBloc.loginOrCreateButtonChanged.add('Create Account');
            },
            child: Text('Create Account')),
      ],
    );
  }

  Column _buttonsCreateAccount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        StreamBuilder(
          initialData: false,
          stream: this._loginBloc.enableLoginCreateButton,
          builder: (BuildContext context, AsyncSnapshot snapshot) =>
              RaisedButton(
            elevation: 16.0,
            child: Text('Create Account'),
            color: Colors.lightGreen.shade200,
            disabledColor: Colors.grey.shade100,
            onPressed: snapshot.data
                ? () => this
                    ._loginBloc
                    .loginOrCreateButtonChanged
                    .add('Create Account')
                : null,
          ),
        ),
        FlatButton(
            onPressed: () {
              this._loginBloc.loginOrCreateButtonChanged.add('Login');
            },
            child: Text('Login')),
      ],
    );
  }
}
