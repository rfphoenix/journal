import 'package:flutter/material.dart';
import 'package:journal/blocs/journal_entry_bloc.dart';

class JournalEditBlocProvider extends InheritedWidget {
  final JournalEditBloc journalEditBloc;

  const JournalEditBlocProvider({Key key, Widget child, this.journalEditBloc})
      : super(key: key, child: child);

  static JournalEditBlocProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<JournalEditBlocProvider>();
  }

  @override
  bool updateShouldNotify(JournalEditBlocProvider oldWidget) {
    return this.journalEditBloc != oldWidget.journalEditBloc;
  }
}
