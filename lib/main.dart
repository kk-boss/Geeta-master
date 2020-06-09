import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:native_state/native_state.dart';

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
import './screens/about-app.dart';
import './screens/about-us.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Admob.initialize(getAppId());
  FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
  runApp(SavedState(child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _bottomPadding = 0.0;
  BannerAd _bannerAd;
  @override
  void initState() { 
    super.initState();
    _bannerAd = createBannerAd()..load();
  }
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
        if(event==MobileAdEvent.failedToLoad){
          if(_bottomPadding!=0.0)
          setState(() {
            _bottomPadding = 0.0;
          });
        }
        if(event==MobileAdEvent.loaded){
          if(_bottomPadding!=50.0)
          setState(() {
            _bottomPadding = 50.0;
          });
        }
      },
    );
  }
  @override
  void dispose() {
    _bannerAd.dispose();
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
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
