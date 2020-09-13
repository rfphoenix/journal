import 'package:flutter/material.dart';
import 'package:journal/blocs/journal_edit_bloc_provider.dart';
import 'package:journal/blocs/journal_entry_bloc.dart';
import 'package:journal/blocs/authentication_bloc_provider.dart';
import 'package:journal/classes/format_dates.dart';
import 'package:journal/classes/mood_icons.dart';

class EditEntry extends StatefulWidget {
  @override
  _EditEntryState createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  JournalEditBloc _journalEditBloc;
  FormatDates _formatDates;
  MoodIcons _moodIcons;
  TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    this._formatDates = FormatDates();
    this._moodIcons = MoodIcons();
    this._noteController = TextEditingController();
    this._noteController.text = '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this._journalEditBloc = JournalEditBlocProvider.of(context).journalEditBloc;
  }

  @override
  void dispose() {
    this._noteController.dispose();
    this._journalEditBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Entry',
          style: TextStyle(color: Colors.lightGreen.shade800),
        ),
        automaticallyImplyLeading: false,
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreen, Colors.lightGreen.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SafeArea(
          minimum: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder(
                  stream: this._journalEditBloc.dateEdit,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      print('I am here...');
                      return Container();
                    }
                    return FlatButton(
                      padding: EdgeInsets.all(0.0),
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        String pickerDate =
                            await this._selectDate(snapshot.data);
                        this._journalEditBloc.dateEditChanged.add(pickerDate);
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.calendar_today,
                            size: 22.0,
                            color: Colors.black54,
                          ),
                          SizedBox(
                            width: 16.0,
                          ),
                          Text(
                            this
                                ._formatDates
                                .dateFormatShortMonthDayYear(snapshot.data),
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    );
                  }),
              StreamBuilder(
                  stream: this._journalEditBloc.moodEdit,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<MoodIcons>(
                          value: this._moodIcons.getMoodIconsList()[this
                              ._moodIcons
                              .getMoodIconsList()
                              .indexWhere(
                                  (icon) => icon.title == snapshot.data)],
                          items: this
                              ._moodIcons
                              .getMoodIconsList()
                              .map((MoodIcons selected) {
                            return DropdownMenuItem<MoodIcons>(
                                value: selected,
                                child: Row(
                                  children: <Widget>[
                                    Transform(
                                      transform: Matrix4.identity()
                                        ..rotateZ(this
                                            ._moodIcons
                                            .getMoodRotation(selected.title)),
                                      alignment: Alignment.center,
                                      child: Icon(
                                          this
                                              ._moodIcons
                                              .getMoodIcon(selected.title),
                                          color: this
                                              ._moodIcons
                                              .getMoodColor(selected.title)),
                                    ),
                                    SizedBox(
                                      width: 16.0,
                                    ),
                                    Text(selected.title)
                                  ],
                                ));
                          }).toList(),
                          onChanged: (selected) {
                            this
                                ._journalEditBloc
                                .moodEditChanged
                                .add(selected.title);
                          }),
                    );
                  }),
              StreamBuilder(
                stream: this._journalEditBloc.noteEdit,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  this._noteController.value =
                      this._noteController.value.copyWith(text: snapshot.data);
                  return TextField(
                    controller: this._noteController,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Note',
                      icon: Icon(Icons.subject),
                    ),
                    maxLines: null,
                    onChanged: (note) =>
                        this._journalEditBloc.noteEditChanged.add(note),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                    color: Colors.grey.shade100,
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  FlatButton(
                    onPressed: () {
                      this._addOrUpdateJournal();
                    },
                    child: Text('Save'),
                    color: Colors.lightGreen.shade100,
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Future<String> _selectDate(String selectedDate) async {
    DateTime initialDate = DateTime.parse(selectedDate);

    final DateTime pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      selectedDate = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              initialDate.hour,
              initialDate.minute,
              initialDate.second,
              initialDate.millisecond,
              initialDate.microsecond)
          .toString();
    }
    return selectedDate;
  }

  void _addOrUpdateJournal() {
    this._journalEditBloc.saveJournalChanged.add('Save');
    Navigator.pop(context);
  }
}
