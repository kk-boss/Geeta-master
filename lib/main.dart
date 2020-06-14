import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/choice.dart';
import './screens/bookmarks.dart';
import './screens/settings.dart';
import './screens/home.dart';
import './screens/search.dart';
import './screens/audio.dart';
import './screens/theme_chooser.dart';
import './providers/audio.dart';
import './providers/selection.dart';
import './providers/data.dart';
import './providers/theme_manager.dart';
import './providers/font.dart';
import './providers/language.dart';
import './providers/bookmarks.dart';
import './screens/about-app.dart';
import './screens/about-us.dart';
import './providers/download.dart';
import './util/strings.dart';
import './controllers/sharedprefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseAdMob.instance.initialize(appId: appId);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _bottomPadding = 0.0;
  BannerAd _bannerAd;
  Timer _timer;
  InterstitialAd _interstitialAd;
  @override
  void initState() {
    super.initState();
    _bannerAd = createBannerAd()..load();
    _interstitialAd = InterstitialAd(
      adUnitId: interId,
      listener: (event) {
        if (event == MobileAdEvent.failedToLoad) {
          print(event);
        }
      },
    );
    _timer = Timer.periodic(
        Duration(
          minutes: 1,
        ), (timer) async {
      DateTime time = DateTime.now();
      String prefTime = await getTime();
      if (prefTime == null) {
        _interstitialAd
          ..load()
          ..show();
        await setTime(time.toString());
      } else {
        Duration difference = time.difference(DateTime.parse(prefTime));
        if (difference.inMinutes > 10) {
          _interstitialAd
            ..load()
            ..show();
          await setTime(time.toString());
        }
      }
    });
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerId,
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.failedToLoad) {
          if (_bottomPadding != 0.0)
            setState(() {
              _bottomPadding = 0.0;
            });
        }
        if (event == MobileAdEvent.loaded) {
          if (_bottomPadding != 50.0)
            setState(() {
              _bottomPadding = 50.0;
            });
        }
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _timer.cancel();
    _interstitialAd.dispose();
    super.dispose();
  }

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
      ],
      child: Consumer<ThemeManager>(builder: (context, manager, _) {
        return MaterialApp(
          theme: manager.themeData,
          title: 'Bhagavad Gita',
          home: HomePage(),
          routes: {
            '/choice': (ctx) => ChoiceScreen(),
            '/bookmarks': (ctx) => Bookmarks(),
            '/settings': (ctx) => Settings(),
            '/search': (ctx) => Search(),
            '/audio': (ctx) => AudioDownload(),
            '/aboutApp': (ctx) => AboutApp(),
            '/aboutUs': (ctx) => AboutUs(),
            '/theme': (ctx) => ThemeChooser(),
          },
          builder: (context, widget) {
            _bannerAd..show();
            return Padding(
              padding: EdgeInsets.only(
                bottom: _bottomPadding,
              ),
              child: widget,
            );
          },
        );
      }),
    );
  }
}
