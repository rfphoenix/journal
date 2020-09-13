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
            print('Here to add journal...');
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
            print('clicked add button...');
            await this
                ._addOrEditJournal(add: true, journal: Journal(uid: _uid));
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildListViewSeparated(AsyncSnapshot snapshot) {
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          String titleDate = this
              ._formatDates
              .dateFormatShortMonthDayYear(snapshot.data[index].date);
          String subtitle =
              snapshot.data[index].mood + "\n" + snapshot.data[index].note;
          return Dismissible(
            key: Key(snapshot.data[index].documentID),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              leading: Column(
                children: <Widget>[
                  Text(
                    this
                        ._formatDates
                        .dateFormatDayNumber(snapshot.data[index].date),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                        color: Colors.lightGreen),
                  ),
                  Text(this
                      ._formatDates
                      .dateFormatShortDayName(snapshot.data[index].date)),
                ],
              ),
              trailing: Transform(
                transform: Matrix4.identity()
                  ..rotateZ(this
                      ._moodIcons
                      .getMoodRotation(snapshot.data[index].mood)),
                alignment: Alignment.center,
                child: Icon(
                  this._moodIcons.getMoodIcon(snapshot.data[index].mood),
                  color:
                      this._moodIcons.getMoodColor(snapshot.data[index].mood),
                  size: 42.0,
                ),
              ),
              title: Text(
                titleDate,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(subtitle),
              onTap: () {
                this._addOrEditJournal(
                  add: false,
                  journal: snapshot.data[index],
                );
              },
            ),
            confirmDismiss: (direction) async {
              bool confirmDelete = await this._confirmDeleteJournal();
              if (confirmDelete) {
                this._homeBloc.deleteJournal.add(snapshot.data[index]);
              }
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: Colors.grey,
          );
        },
        itemCount: snapshot.data.length);
  }

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
