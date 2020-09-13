import 'dart:async';
import 'package:journal/models/journal.dart';
import 'package:journal/services/db_firestore_api.dart';

class JournalEditBloc {
  final DbApi dbApi;
  final bool add;
  Journal selectedJournal;

  final StreamController<String> _dateController =
      StreamController<String>.broadcast();
  Sink<String> get dateEditChanged => this._dateController.sink;
  Stream<String> get dateEdit => this._dateController.stream;

  final StreamController<String> _moodController =
      StreamController<String>.broadcast();
  Sink<String> get moodEditChanged => this._moodController.sink;
  Stream<String> get moodEdit => this._moodController.stream;

  final StreamController<String> _noteController =
      StreamController<String>.broadcast();
  Sink<String> get noteEditChanged => this._noteController.sink;
  Stream<String> get noteEdit => this._noteController.stream;

  final StreamController<String> _saveJournalController =
      StreamController<String>.broadcast();
  Sink<String> get saveJournalChanged => this._saveJournalController.sink;
  Stream<String> get saveJournal => this._saveJournalController.stream;

  JournalEditBloc({this.add, this.selectedJournal, this.dbApi}) {
    this
        ._startEditListeners()
        .then((finished) => this._getJournal(add, this.selectedJournal));
  }

  void dispose() {
    this._dateController.close();
    this._moodController.close();
    this._noteController.close();
    this._saveJournalController.close();
  }

  Future<bool> _startEditListeners() async {
    await this._dateController.stream.listen((date) {
      selectedJournal.date = date;
    });
    await this._moodController.stream.listen((mood) {
      selectedJournal.mood = mood;
    });
    await this._noteController.stream.listen((note) {
      selectedJournal.note = note;
    });
    await this._saveJournalController.stream.listen((action) {
      if (action == 'Save') {
        this._saveJournal();
      }
    });
    return true;
  }

  void _getJournal(bool add, Journal journal) {
    if (add) {
      print('adding new journal...');
      this.selectedJournal = Journal();
      this.selectedJournal.date = DateTime.now().toString();
      this.selectedJournal.mood = 'Very Satisfied';
      this.selectedJournal.note = '';
      this.selectedJournal.uid = journal.uid;
    } else {
      this.selectedJournal.date = journal.date;
      this.selectedJournal.mood = journal.mood;
      this.selectedJournal.note = journal.note;
    }
    dateEditChanged.add(selectedJournal.date);
    moodEditChanged.add(selectedJournal.mood);
    noteEditChanged.add(selectedJournal.note);
  }

  void _saveJournal() {
    Journal journal = Journal(
        documentID: this.selectedJournal.documentID,
        date: DateTime.parse(this.selectedJournal.date).toIso8601String(),
        mood: this.selectedJournal.mood,
        note: this.selectedJournal.note,
        uid: this.selectedJournal.uid);

    this.add
        ? this.dbApi.addJournal(journal)
        : this.dbApi.updateJournal(journal);
  }
}
