import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';

import 'package:geeta/widgets/drawer.dart';
import '../util/getData.dart';
import '../widgets/datalist.dart';
import '../book.dart';
import '../models/geeta.dart';
import '../util/initialGetters.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<int> verseCounts = [
    40,
    71,
    43,
    42,
    28,
    43,
    28,
    27,
    35,
    41,
    52,
    16,
    31,
    24,
    20,
    21,
    28,
    76
  ];
  List<Color> textColor = [];
  List<String> selection = [];
  static int currentPage = 0;
  int id = 7;
  PageController _controller = new PageController();
  ScrollController _scroll = ScrollController();
  final List<bool> verseSelected = [];
  bool firstInit = true;
  var result;
  int verss;
  Database db;
  Future<bool> _copy;
  Future<double> _font;
  Future<List<Geeta>> _geeta;
  Future<int> _lang;
  @override
  void initState() {
    super.initState();
    _copy = copyData().then((onValue){
      _geeta = getData(currentPage + 1);
      return onValue;
    });
    _lang = getLang();
  }

  // Future<int> _initializeFromArgs(_) async {
  //   final routeArgs =
  //       ModalRoute.of(context).settings.arguments as Map<String, int>;
  //   if (routeArgs != null) {
  //     currentPage = routeArgs['chapter'] ?? 11;
  //     print(currentPage);
  //     // id = routeArgs['id'];
  //     // chapterCount = routeArgs['chapterCount'];
  //   }
  //   return currentPage;
  // }
  // Future<Database> _initDB()async{
  //   db = await openDatabase(
  //   Path.join(await getDatabasesPath(), 'geetaa.db'),
  // );
  // print('opened');
  // return db;
  // }
  @override
  void didChangeDependencies() {
    print('didChangedDependencies');
    if (firstInit) {
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, int>;
      if (routeArgs != null) {
        setState(() {
          currentPage = routeArgs['chapter'] ?? 0;
          id = routeArgs['id'] ?? 7;
          _geeta = getData(currentPage + 1);
          _controller = new PageController(initialPage: currentPage);
        });
        // id = routeArgs['id'];
        // chapterCount = routeArgs['chapterCount'];
        // _controller = new PageController(initialPage: currentPage);
      }
      firstInit = false;
    }
    super.didChangeDependencies();
    _font = getFont();
  }

  void _clearAll() {
    textColor.clear();
    selection.clear();
    verseSelected.clear();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaquery = MediaQuery.of(context);
    final String title = BOOK.where((test) => test.id == id).toList()[0].title;
    for (var i = 0; i < verseCounts.length; i++) {
      verseSelected.add(false);
      textColor.add(Colors.white);
      selection.add('');
    }
    _font = getFont();
    print('setstate');
    return Scaffold(
        appBar: !verseSelected.contains(true)
            ? AppBar(
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        // if (chapter > 1)
                        //   setState(() {
                        //     chapter = chapter - 1;
                        //     _saveprefs(chapter, id, chapterCount);
                        //   });
                        setState(() {
                          if (currentPage > 0) {
                            _controller.jumpToPage(currentPage - 1);
                          }
                        });
                      },
                    ),
                    InkWell(
                      child: Container(
                        width: mediaquery.size.width/3,
                        height: kToolbarHeight/1.5,
                        decoration: BoxDecoration(color: Color.fromRGBO(31, 32, 122, 1)),
                        child: Center(
                          child: Text(
                            title,
                            // id == 0 ? 'Title' : bookTitle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      onTap: () async {
                        result = await Navigator.of(context)
                            .pushReplacementNamed('/choice');
                      },
                    ),
                    InkWell(
                      child: Container(
                        child: Text((currentPage + 1).toString()),
                      ),
                      onTap: () {
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        // if (chapter < chapterCount)
                        //   setState(() {
                        //     chapter = chapter + 1;
                        //     _saveprefs(chapter, id, chapterCount);
                        //   });
                        setState(() {
                          if (currentPage < 17) {
                            _controller.jumpToPage(currentPage + 1);
                          }
                        });
                      },
                    ),
                    IconButton(icon: Icon(Icons.search), onPressed: (){
                      Navigator.of(context).pushNamed('/search');
                    })
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
                            setState(() {
                              _clearAll();
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () {
                            Share.share(selection
                                    .toString()
                                    .replaceAll(RegExp(r'[\[\]]'), '')
                                    .replaceAll(',', '')
                                    .trim() +
                                ' Santosh Thapa Chutiya Ho');
                                setState(() {
                              _clearAll();
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.bookmark),
                          onPressed: () async {
                            await addBookmark(currentPage + 1, verss);
                            // _savebookmarks(id, chapter, bookselection);
                            Scaffold.of(ctx).showSnackBar(SnackBar(
                              content: const Text('Added to Bookmarks'),
                            ));
                            setState(() {
                              _clearAll();
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.content_copy),
                          onPressed: () {
                            Clipboard.setData(new ClipboardData(
                                text: selection
                                        .toString()
                                        .replaceAll(RegExp(r'[\[\]]'), '')
                                        .replaceAll(',', '')
                                        .trim() +
                                    ' Santosh Thapa Chutiya Ho'));
                            Scaffold.of(ctx).showSnackBar(SnackBar(
                              content: const Text('Copied to Clipboard'),
                            ));
                            setState(() {
                              _clearAll();
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
        drawer: drawer(context),
        body: id == 7
            ?
            Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  PageView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _controller,
                    itemBuilder: (ct, j) {
                      return FutureBuilder(
                          future: _copy,
                          builder: (context, snapsho) {
                            if (!snapsho.hasData) {
                              return Center(child: Text('Copying Database'));
                            }
                            if (snapsho.hasData) {
                              return FutureBuilder(
                                future: Future.wait([_geeta, _font,_lang]),
                                builder: (contx, snapsot) {
                                  if (!snapsot.hasData) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final snapshot = snapsot.data[0];
                                  for (var i = 0; i < snapshot.length; i++) {
                                    verseSelected.add(false);
                                    textColor.add(Colors.white);
                                    selection.add('');
                                  }
                                  return ListView.builder(
                                    controller: _scroll,
                                    itemCount: snapshot.length,
                                    itemBuilder: (ctx, i) {
                                      final String langData = snapsot.data[2]==0?snapshot[i].nepali:snapshot[i].english;
                                      return InkWell(
                                        child: buildData(
                                            snapshot[i].sanskrit,
                                            langData,
                                            snapsot.data[1],
                                            textColor[i],
                                            snapshot[i].color,
                                            snapshot[i].verse),
                                        onTap: () {
                                          setState(() {
                                            verss = snapshot[i].verse;
                                            verseSelected[i] =
                                                !verseSelected[i];
                                            if (textColor[i] == Colors.white) {
                                              textColor[i] = Colors.grey[400];
                                            } else {
                                              textColor[i] = Colors.white;
                                            }
                                            if (selection.contains(
                                                '${snapshot[i].sanskrit}\n${snapshot[i].nepali}\n')) {
                                              selection.remove(
                                                  '${snapshot[i].sanskrit}\n${snapshot[i].nepali}\n');
                                            } else {
                                              // selection.add('${snapshot[i].sanskrit}\n${snapshot[i].nepali}');
                                              selection.insert(i,
                                                  '${snapshot[i].sanskrit}\n${snapshot[i].nepali}\n');
                                            }
                                          });
                                        },
                                      ); //inkwell
                                    },
                                  );
                                },
                              );
                            } //i added
                            else {
                              return Center(child: Text('File Not Copied'));
                            }
                          });
                    },
                    itemCount: 18,
                    onPageChanged: (page) {
                      setState(() {
                        currentPage = page;
                        _clearAll();
                        _geeta = getData(currentPage + 1);
                      });
                    },
                  ),
                  verseSelected.contains(true)
                      ? Container(
                          color: Colors.blue,
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: color.map((c) {
                              return InkWell(
                                onTap: () async {
                                  final int col =
                                      color.indexWhere((test) => test == c);
                                  await setColor(col, currentPage + 1, verss);
                                  setState(() {
                                    _clearAll();
                                    _geeta = getData(currentPage + 1);
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
              )
            // })
            : Center(
                child: Text('No data'),
              ));
  }
}
