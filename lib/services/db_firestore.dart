import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/services/db_firestore_api.dart';

class DbFirestoreService implements DbApi {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionJournals = 'journals';

  @override
  Future<bool> addJournal(Journal journal) async {
    DocumentReference documentReference =
        await this._firestore.collection(this._collectionJournals).add({
      'date': journal.date,
      'mood': journal.mood,
      'note': journal.note,
      'uid': journal.uid,
    });
    return documentReference.id != null;
  }

  @override
  void deleteJournal(Journal journal) async {
    await this
        ._firestore
        .collection(this._collectionJournals)
        .doc(journal.documentID)
        .delete()
        .catchError((error) => print('Error deleting: $error'));
  }

  @override
  Future<Journal> getJournal(String documentID) async {
    return await this
        ._firestore
        .collection(this._collectionJournals)
        .doc(documentID)
        .get()
        .then((documentSnapshot) => Journal.fromDoc(documentSnapshot));
  }

  @override
  Stream<List<Journal>> getJournalList(String uid) {
    return this
        ._firestore
        .collection(this._collectionJournals)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      List<Journal> journalDocs =
          snapshot.docs.map((doc) => Journal.fromDoc(doc)).toList();
      journalDocs.sort((comp1, comp2) => comp2.date.compareTo(comp1.date));

      return journalDocs;
    });
  }

  @override
  void updateJournal(Journal journal) async {
    await this
        ._firestore
        .collection(this._collectionJournals)
        .doc(journal.documentID)
        .update({
      'date': journal.date,
      'mood': journal.mood,
      'note': journal.note,
    }).catchError((error) => print('Error updating: $error'));
  }

  @override
  void updateJournalWithTransaction(Journal journal) async {
    DocumentReference documentReference = this
        ._firestore
        .collection(this._collectionJournals)
        .doc(journal.documentID);
    var journalData = {
      'date': journal.date,
      'mood': journal.mood,
      'note': journal.note
    };
    this._firestore.runTransaction((transaction) async {
      await transaction.update(documentReference, journalData);
    });
  }
}
