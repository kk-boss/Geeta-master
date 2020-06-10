import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';

import '../widgets/drawer.dart';
import '../util/variables.dart';
import '../models/book.dart';
import '../models/geeta.dart';
import '../controllers/sharedprefs.dart';
import '../widgets/verse.dart';
import '../providers/selection.dart';
import '../providers/data.dart';
import '../providers/download.dart';
import '../widgets/progress.dart';
import '../util/strings.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;
  int _id = 7;
  PageController _controller = new PageController();
  Future<bool> _copy;
  Future<double> _font;
  Future<List<Geeta>> _geeta;
  Future<int> _lang;
  Future<bool> _copyAudio;
  Future<List<Audio>> _audio;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFirstInit = true;
  Timer _timer;
  InterstitialAd _interstitialAd;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      restoreState();
    });
    super.initState();
    _copyAudio = Download.copyAudioData().then((onValue) {
      _audio = Download.getData();
      return onValue;
    });
    _copy = DataProvider.copyData().then((onValue) {
      _geeta = DataProvider.getData(_id, _currentPage + 1);
      return onValue;
    });
    _lang = getLang();
    _font = getFont();
    _interstitialAd = InterstitialAd(
      adUnitId: interId,
      listener: (event) {
        if(event == MobileAdEvent.failedToLoad){
         print(event);
        }
      },
    );
     _timer = Timer.periodic(Duration(minutes: 15), (timer) {
       _interstitialAd..load()..show().catchError((onError){
         print('Error occured');
       });
    });
  }

  Future<void> restoreState() async {
    var _routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, int>;
    List<int> restore = await getSavedState();
    int id = restore[0];
    int chapter = restore[1];
    if (id != null && chapter != null && _routeArgs == null) {
      _id = id;
      _currentPage = chapter;
      _controller = PageController(initialPage: _currentPage);
      setState(() {
        _geeta = DataProvider.getData(_id, _currentPage + 1);
      });
    }
  }

  @override
  void didChangeDependencies() {
    if (_isFirstInit) {
      var routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, int>;
      if (routeArgs != null) {
        _currentPage = routeArgs['chapter'] ?? 0;
        _id = routeArgs['id'] ?? 7;
        _controller = PageController(initialPage: _currentPage);
        setBookId(_id);
        setChapter(_currentPage);
      }
      _isFirstInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() { 
    _interstitialAd.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaquery = MediaQuery.of(context);
    final selectionProvider = Provider.of<Selection>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final String title = BOOK.where((test) => test.id == _id).toList()[0].title;
    final int chapter =
        BOOK.where((test) => test.id == _id).toList()[0].chapter;
    return Scaffold(
        key: _scaffoldKey,
        appBar: !selectionProvider.verses.contains(true)
            ? AppBar(
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: (_currentPage > 0)
                            ? () async {
                                _controller.jumpToPage(_currentPage - 1);
                                _geeta =
                                    DataProvider.getData(_id, _currentPage + 1);
                                await setBookId(_id);
                                await setChapter(_currentPage);
                              }
                            : null,
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: InkWell(
                        child: Container(
                          height: kToolbarHeight / 1.5,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(31, 32, 122, 1)),
                          child: Center(
                            child: Tooltip(
                              message: title,
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed('/choice');
                        },
                      ),
                    ),
                    Flexible(
                      child: InkWell(
                        child: Container(
                          width: kToolbarHeight / 1.5,
                          height: kToolbarHeight / 1.5,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(31, 32, 122, 1)),
                          child: Center(
                              child: Text((_currentPage + 1).toString())),
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed('/choice',
                              arguments: {
                                'id': _id,
                                'chapter': _currentPage + 1
                              });
                        },
                      ),
                    ),
                    Flexible(
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: (_currentPage < chapter - 1)
                            ? () async {
                                _controller.jumpToPage(_currentPage + 1);
                                _geeta =
                                    DataProvider.getData(_id, _currentPage + 1);
                                await setBookId(_id);
                                await setChapter(_currentPage);
                              }
                            : null,
                      ),
                    ),
                    Flexible(
                      child: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/search');
                          }),
                    )
                  ],
                ),
              )
            : PreferredSize(
                preferredSize: const Size(double.infinity, kToolbarHeight),
                child: Builder(
                  builder: (ctx) => AppBar(
                    centerTitle: true,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            selectionProvider.clear();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () {
                            Share.share(selectionProvider.selection
                                    .toString()
                                    .replaceAll(RegExp(r'[\[\]]'), '')
                                    .replaceAll(',', '')
                                    .trim() +
                                appUrl);
                            selectionProvider.clear();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.bookmark),
                          onPressed: () async {
                            await dataProvider.addBookmarks(
                                _id, _currentPage + 1, selectionProvider.list);
                            Scaffold.of(ctx).showSnackBar(SnackBar(
                              content: Text(
                                  selectionProvider.list.length.toString() +
                                      addedToBookmarks),
                              behavior: SnackBarBehavior.floating,
                            ));
                            selectionProvider.clear();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.content_copy),
                          onPressed: () {
                            Clipboard.setData(new ClipboardData(
                                text: selectionProvider.selection
                                        .toString()
                                        .replaceAll(RegExp(r'[\[\]]'), '')
                                        .replaceAll(',', '')
                                        .trim() +
                                    appUrl));
                            Scaffold.of(ctx).showSnackBar(SnackBar(
                              content: const Text(copiedToClipboard),
                              behavior: SnackBarBehavior.floating,
                            ));
                            selectionProvider.clear();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
        drawer: drawer(context),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: _controller,
              itemBuilder: (ct, j) {
                return FutureBuilder(
                    future: Future.wait([_copy, _copyAudio]),
                    builder: (context, snapsho) {
                      if (!snapsho.hasData) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(loading),
                              Progress(),
                            ],
                          ),
                        );
                      }
                      if (snapsho.hasData) {
                        return FutureBuilder(
                          future: Future.wait([_geeta, _font, _lang, _audio]),
                          builder: (contx, snapsot) {
                            if (snapsot.hasError) {
                              print(snapsot.error);
                            }
                            if (!snapsot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final snapshot = snapsot.data[0];
                            final audiosnapshot = snapsot.data[3];
                            selectionProvider.add(snapshot.length);
                            return Column(
                              children: <Widget>[
                                if (_id == 7)
                                  Container(
                                      width: double.infinity,
                                      color: Colors.grey,
                                      child: Text(
                                        TITLE[j],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: snapsot.data[1]),
                                      )),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: snapshot.length,
                                    itemBuilder: (ctx, i) {
                                      final String langData =
                                          snapsot.data[2] == 0
                                              ? snapshot[i].nepali
                                              : snapshot[i].english;
                                      return InkWell(
                                        child: Verse(
                                          geeta: snapshot[i],
                                          translation: langData,
                                          fontSize: snapsot.data[1],
                                          textColor:
                                              selectionProvider.textColor[i],
                                          download: audiosnapshot[j].download,
                                          scaffoldKey: _scaffoldKey,
                                        ),
                                        onTap: () {
                                          selectionProvider.selectVerse(i,
                                              snapshot[i].sanskrit, langData);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        return Center(child: const Text(fileNotCopied));
                      }
                    });
              },
              itemCount: chapter,
              onPageChanged: (page) {
                _currentPage = page;
                selectionProvider.clear();
              },
            ),
            selectionProvider.verses.contains(true)
                ? Container(
                    color: Colors.blue,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: color.map((c) {
                        return InkWell(
                          onTap: () async {
                            final int col =
                                color.indexWhere((test) => test == c);
                            await Provider.of<DataProvider>(context,
                                    listen: false)
                                .setColor(col, _currentPage + 1,
                                    selectionProvider.list);
                            selectionProvider.clear();
                            setState(() {
                              _geeta =
                                  DataProvider.getData(_id, _currentPage + 1);
                            });
                          },
                          child: Container(
                            child: SizedBox(
                              height: mediaquery.size.width / 10,
                              width: mediaquery.size.width / 10,
                            ),
                            color: c,
                          ),
                        );
                      }).toList(),
                    ))
                : Container()
          ],
        ));
  }
}
