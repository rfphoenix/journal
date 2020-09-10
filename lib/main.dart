import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:journal/blocs/authentication_bloc.dart';
import 'package:journal/blocs/authentication_bloc_provider.dart';
import 'package:journal/blocs/home_bloc.dart';
import 'package:journal/blocs/home_bloc_provider.dart';
import 'package:journal/services/authentication.dart';
import 'package:journal/services/db_firestore.dart';
import 'package:journal/pages/home.dart';
import 'package:journal/pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final AuthenticationService authenticationService = AuthenticationService();
    final AuthenticationBloc authenticationBloc =
        AuthenticationBloc(authenticationService);

    return AuthenticationBlocProvider(
        authenticationBloc: authenticationBloc,
        child: StreamBuilder(
            initialData: null,
            stream: authenticationBloc.user,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: Colors.lightGreen,
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData) {
                return HomeBlocProvider(
                  homeBloc: HomeBloc(
                    authenticationApi: authenticationService,
                    dbApi: DbFirestoreService(),
                  ),
                  uid: snapshot.data,
                  child: this._buildMaterialApp(Home()),
                );
              } else {
                return this._buildMaterialApp(Login());
              }
            }));
  }

  MaterialApp _buildMaterialApp(Widget homePage) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Security Inherited',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        canvasColor: Colors.lightGreen.shade50,
        bottomAppBarColor: Colors.lightGreen,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: homePage,
    );
  }
}
