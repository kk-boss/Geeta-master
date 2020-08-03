import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/providers.dart';
import './screens/screens.dart';

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
          value: SearchProvider(),
        ),
        ChangeNotifierProvider.value(
          value: ThemeManager(),
        ),
        ChangeNotifierProvider.value(
          value: FontManager(),
        ),
        ChangeNotifierProvider.value(
          value: LanguageManager(),
        ),
        ChangeNotifierProvider.value(
          value: BookmarkManager(),
        ),
        ChangeNotifierProvider.value(
          value: Gita(),
        ),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, _) {
          return MaterialApp(
            theme: themeManager.themeData,
            title: 'Bhagavad Gita',
            home: Home(),
            routes: {
              '/choice': (ctx) => ChoiceScreen(),
              '/bookmarks': (ctx) => Bookmarks(),
              '/settings': (ctx) => Settings(),
              '/search': (ctx) => Search(),
              '/audio': (ctx) => AudioDownload(),
              '/aboutApp': (ctx) => AboutApp(),
              '/aboutUs': (ctx) => AboutUs(),
              '/theme': (ctx) => ThemeChooser(),
              '/test': (ctx) => FirebaseTest(),
            },
          );
        },
      ),
    );
  }
}
