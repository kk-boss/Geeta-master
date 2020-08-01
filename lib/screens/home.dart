import 'dart:async';

import 'package:Bhagavad_Gita/providers/font.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../controllers/sharedprefs.dart';
import '../models/book.dart';
import '../models/geeta.dart';
import '../providers/providers.dart';
import '../util/strings.dart';
import '../util/variables.dart';
import '../widgets/drawer.dart';
import '../widgets/title.dart';
import '../widgets/verse.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;
  int _id = 7;
  final PageController _controller = new PageController();
  Future<bool> _copy;
  Future<List<Geeta>> _geeta;
  Future<bool> _copyAudio;
  Future<List<Audio>> _audio;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFirstInit = true;
  DateTime currentBackPressTime;
  FirebaseMessaging _messaging = FirebaseMessaging();

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
    _messaging.subscribeToTopic('all');
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('mesage received');
        print("onMessage: $message");
        var notification = message["notification"];
        // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Hi"),));
        showDialog(
            context: _scaffoldKey.currentState.context,
            builder: (context) {
              return AlertDialog(
                title: Text(notification["title"]),
                content: Text(notification["body"]),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'))
                ],
              );
            });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {},
    );
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
      if (_controller.hasClients) {
        _controller.jumpToPage(_currentPage);
      }
      // setState(() {
      _geeta = DataProvider.getData(_id, _currentPage + 1);
      // });
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
        if (_controller.hasClients) {
          _controller.jumpToPage(_currentPage);
        }
        setBookId(_id);
        setChapter(_currentPage);
      }
      _isFirstInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    print('Controller disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaquery = MediaQuery.of(context);
    final selectionProvider = Provider.of<Selection>(context);
    final String title = BOOK.where((test) => test.id == _id).toList()[0].title;
    final int chapter =
        BOOK.where((test) => test.id == _id).toList()[0].chapter;
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          _scaffoldKey.currentState
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text('Press back again to exit'),
            ));
          return Future.value(false);
        }
        return Provider.of<MyAudio>(context, listen: false).disposeAudio();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: !selectionProvider.verses.contains(true)
            ? AppBar(
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      flex: 4,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: (_currentPage > 0 && _controller.hasClients)
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
                    Spacer(),
                    Flexible(
                      flex: 20,
                      child: BookTitle(title: title),
                    ),
                    Spacer(),
                    Flexible(
                      flex: 4,
                      child: ChapterNumber(currentPage: _currentPage, id: _id),
                    ),
                    Flexible(
                      flex: 4,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: (_currentPage < chapter - 1 &&
                                _controller.hasClients)
                            ? () async {
                                // _controller.nextPage(
                                //   duration: Duration(milliseconds: 200),
                                //   curve: Curves.easeInCubic,
                                // );
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
                      flex: 4,
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
                            await Provider.of<BookmarkManager>(context)
                                .setBookmark(_id, _currentPage + 1,
                                    selectionProvider.list);
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
              itemBuilder: (_, j) {
                return FutureBuilder(
                    future: Future.wait([_copy, _copyAudio]),
                    builder: (context, snapsho) {
                      if (!snapsho.hasData) {
                        return Center(
                          child: Text(loading),
                        );
                      }
                      if (snapsho.hasData) {
                        return FutureBuilder(
                          future: Future.wait([_geeta, _audio]),
                          builder: (contx, snapsot) {
                            if (snapsot.hasError) {
                              print(snapsot.error);
                            }
                            if (!snapsot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final snapshot = snapsot.data[0];
                            final audiosnapshot = snapsot.data[1];
                            selectionProvider.add(snapshot.length);
                            return Consumer2<FontManager, LanguageManager>(
                                builder:
                                    (context, fontManager, langManager, _) {
                              return Column(
                                children: <Widget>[
                                  if (_id == 7)
                                    Container(
                                        width: double.infinity,
                                        color: Colors.grey,
                                        child: Text(
                                          TITLE[_currentPage],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontManager.fontSize),
                                        )),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: snapshot.length,
                                      itemBuilder: (ctx, i) {
                                        final String langData =
                                            langManager.language == 0
                                                ? snapshot[i].nepali
                                                : snapshot[i].english;
                                        return InkWell(
                                          child: Verse(
                                            geeta: snapshot[i],
                                            translation: langData,
                                            fontSize: fontManager.fontSize,
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
                            });
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
        ),
      ),
    );
  }
}
