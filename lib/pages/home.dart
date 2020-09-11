import 'package:flutter/material.dart';
import 'package:journal/blocs/authentication_bloc.dart';
import 'package:journal/blocs/authentication_bloc_provider.dart';
import 'package:journal/blocs/home_bloc.dart';
import 'package:journal/blocs/home_bloc_provider.dart';
import 'package:journal/blocs/journal_entry_bloc.dart';
import 'package:journal/blocs/journal_edit_bloc_provider.dart';
import 'package:journal/classes/format_dates.dart';
import 'package:journal/classes/mood_icons.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/pages/edit_entry.dart';
import 'package:journal/services/db_firestore.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthenticationBloc _authenticationBloc;
  HomeBloc _homeBloc;
  String _uid;
  MoodIcons _moodIcons = MoodIcons();
  FormatDates _formatDates = FormatDates();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this._authenticationBloc =
        AuthenticationBlocProvider.of(context).authenticationBloc;
    this._homeBloc = HomeBlocProvider.of(context).homeBloc;
    this._uid = HomeBlocProvider.of(context).uid;
  }

  @override
  void dispose() {
    this._homeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Journal',
          style: TextStyle(color: Colors.lightGreen.shade800),
        ),
        elevation: 0.0,
        bottom: PreferredSize(
            child: Container(), preferredSize: Size.fromHeight(32.0)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.lightGreen, Colors.lightGreen.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.lightGreen.shade800,
              ),
              onPressed: () {
                this._authenticationBloc.logoutUser.add(true);
              }),
        ],
      ),
      body: StreamBuilder(
        stream: this._homeBloc.listJournal,
        builder: ((BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return this._buildListViewSeparated(snapshot);
          } else {
            return Center(
              child: Container(
                child: Text('Add Journal'),
              ),
            );
          }
        }),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        child: Container(
          height: 44.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.lightGreen.shade50, Colors.lightGreen],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: 'Add Journal Entry',
          backgroundColor: Colors.lightGreen.shade300,
          child: Icon(Icons.add),
          onPressed: () async {
            this._addOrEditJournal(add: true, journal: Journal(uid: _uid));
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildListViewSeparated(AsyncSnapshot snapshot) {}

  void _addOrEditJournal({bool add, Journal journal}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => JournalEditBlocProvider(
                journalEditBloc: JournalEditBloc(
                    add: add,
                    selectedJournal: journal,
                    dbApi: DbFirestoreService()),
                child: EditEntry(),
              ),
          fullscreenDialog: true),
    );
  }

  Future<bool> _confirmDeleteJournal() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Journal"),
          content: Text("Are you sure you would like to Delete?"),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text('CANCEL')),
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(
                  'DELETE',
                  style: TextStyle(color: Colors.red),
                )),
          ],
        );
      },
    );
  }
}
