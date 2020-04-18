import 'package:flutter/material.dart';

// import './screens/home.dart';
import './screens/choice.dart';
import './screens/bookmarks.dart';
import './screens/settings.dart';
import './screens/database.dart';
import './screens/myhome.dart';
import './screens/search.dart';
import './screens/audio.dart';

void main()async{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Key _key = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geeta',
      home: HomePage(),
      routes: {
        '/choice': (ctx) => ChoiceScreen(),
        '/bookmarks': (ctx) => Bookmarks(),
        '/settings': (ctx) => Settings(key: _key),
        '/database': (ctx) => DataBase(key: _key),
        '/search': (ctx) => Search(),
        '/audio': (ctx) => AudioTest(),
      },
    );
  }
}
