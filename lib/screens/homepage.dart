import 'package:Bhagavad_Gita/util/strings.dart';
import 'package:Bhagavad_Gita/widgets/drawer.dart';
import 'package:Bhagavad_Gita/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../widgets/verse.dart';
import '../providers/providers.dart';
import '../models/book.dart';
import '../util/variables.dart';
import '../controllers/database-helper.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime currentBackPressTime;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    DatabaseHelper.disposeDatabase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final gita = Provider.of<Gita>(context);
    final selectionProvider = Provider.of<Selection>(context);
    final String title =
        BOOK.where((test) => test.id == gita.book).toList().first.title;
    final int chapter =
        BOOK.where((test) => test.id == gita.book).toList().first.chapter;
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
                        onPressed: (gita.chapter > 1)
                            ? () {
                                gita.fetchAndSetData(
                                    gita.book, gita.chapter - 1);
                              }
                            : null,
                      ),
                    ),
                    Spacer(),
                    Flexible(
                      flex: 20,
                      child: InkWell(
                        child: BookTitle(title: title),
                        onTap: () async {
                          final result = await Navigator.of(context)
                              .pushNamed('/choice') as Map<String, int>;
                          if (result != null) {
                            await gita.fetchAndSetData(
                                result['id'], result['chapter'] + 1);
                          }
                        },
                      ),
                    ),
                    Spacer(),
                    Flexible(
                      flex: 4,
                      child: InkWell(
                        child: ChapterNumber(
                          currentPage: gita.chapter,
                        ),
                        onTap: () async {
                          final result = await Navigator.of(context)
                              .pushNamed('/choice', arguments: {
                            'id': gita.book,
                            'chapter': gita.chapter + 1
                          }) as Map<String, int>;
                          if (result != null) {
                            await gita.fetchAndSetData(
                                result['id'], result['chapter'] + 1);
                          }
                        },
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: (gita.chapter < chapter)
                            ? () {
                                gita.fetchAndSetData(
                                    gita.book, gita.chapter + 1);
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
                            await Provider.of<BookmarkManager>(context,
                                    listen: false)
                                .setBookmark(gita.book, gita.chapter,
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
            Builder(
              builder: (context) {
                if (gita.items.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                selectionProvider.add(gita.items.length);
                return Consumer2<FontManager, LanguageManager>(
                    builder: (context, fontManager, langManager, _) {
                  return ListView.builder(
                    key: ValueKey(gita.chapter),
                    itemCount: gita.items.length,
                    itemBuilder: (context, index) {
                      final item = gita.items[index];
                      final String langData = langManager.language == 0
                          ? item.nepali
                          : item.english;
                      return InkWell(
                        child: Verse(
                          geeta: item,
                          translation: langData,
                          fontSize: fontManager.fontSize,
                          textColor: selectionProvider.textColor[index],
                          download: gita.audio[gita.chapter - 1].download,
                          scaffoldKey: _scaffoldKey,
                        ),
                        onTap: () {
                          selectionProvider.selectVerse(
                              index, item.sanskrit, langData);
                        },
                      );
                    },
                  );
                });
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
                            await gita.setColor(
                                col, gita.chapter, selectionProvider.list);
                            selectionProvider.clear();
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
