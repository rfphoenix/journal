import 'dart:async';
import 'package:journal/services/authentication_api.dart';
import 'package:journal/services/db_firestore_api.dart';
import 'package:journal/models/journal.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeBloc {
  final DbApi dbApi;
  final AuthenticationApi authenticationApi;

  final StreamController<List<Journal>> _journalController =
      StreamController<List<Journal>>.broadcast();
  Sink<List<Journal>> get _addListJournal => this._journalController.sink;
  Stream<List<Journal>> get listJournal => this._journalController.stream;

  final StreamController<Journal> _journalDeleteController =
      StreamController<Journal>.broadcast();
  Sink<Journal> get deleteJournal => this._journalDeleteController.sink;

  HomeBloc({this.dbApi, this.authenticationApi}) {
    this._startListeners();
  }

  void dispose() {
    this._journalController.close();
    this._journalDeleteController.close();
  }

  void _startListeners() async {
    User user = await this.authenticationApi.getFirebaseAuth().currentUser;
    this.dbApi.getJournalList(user.uid).listen((journalDocs) {
      this._addListJournal.add(journalDocs);
    });

    this._journalDeleteController.stream.listen((journal) {
      this.dbApi.deleteJournal(journal);
    });
  }
}
