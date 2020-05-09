import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/choice.dart';
import './screens/bookmarks.dart';
import './screens/settings.dart';
import './screens/home.dart';
import './screens/search.dart';
import './screens/audio.dart';
import './providers/audio.dart';
import './providers/selection.dart';
import './providers/data.dart';
import './providers/download.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: MyAudio(),
        ),
        ChangeNotifierProvider.value(
          value: Selection(),
        ),
        ChangeNotifierProvider.value(
          value: DataProvider(),
        ),
        ChangeNotifierProvider.value(
          value: SearchProvider(),
        ),
        ChangeNotifierProvider.value(
          value: Download(),
        ),
      ],
      child: MaterialApp(
        title: 'Geeta',
        home: WillPopScope(child: HomePage(),onWillPop: (){
          return Future.delayed(Duration(seconds: 0),(){
            return false;
          });
        },),
        routes: {
          '/choice': (ctx) => ChoiceScreen(),
          '/bookmarks': (ctx) => Bookmarks(),
          '/settings': (ctx) => Settings(),
          '/search': (ctx) => Search(),
          '/audio': (ctx)=>AudioDownload(),
        },
      ),
    );
  }
}
