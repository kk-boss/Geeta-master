import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../book.dart';
import '../util/getData.dart';
import '../widgets/datalist.dart';

class Bookmarks extends StatefulWidget {
  @override
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  int id;
  int chapter;
  int verse;
  int _val;
  @override
  void initState() {
    super.initState();
    // _loadprefs();
  }
  Future<int> getLang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _val = prefs.getInt('lang') ?? 0;
    return _val;
  }
  // _loadprefs() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     chapter = prefs.getInt('bookChapter') ?? 0;
  //     id = prefs.getInt('bookId') ?? 0;
  //     verse = prefs.getInt('bookVerse') ?? 0;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookmarks')),
      body: FutureBuilder(
          future: Future.wait([getBook(),getLang()]),
          builder: (ctx, snapsot) {
            if (!snapsot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final snapshot = snapsot.data[0];
            if (snapshot.length == 0) {
              return Center(
                child: Text('No Bookmarks'),
              );
            }
            final items = snapshot;
            return ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  final String langData = _val==0?item.nepali:item.english;
                  print(item.nepali);
                  return Dismissible(
                      key: Key(item.toString()),
                      onDismissed: (direction) async {
                        await delBookmark(item.chapter, item.verse);
                        Scaffold.of(ctx).showSnackBar(SnackBar(
                          content: Text('Item Removed from Bookmark'),
                        ));
                      },
                      child: buildData(
                          item.sanskrit, langData, 18, Colors.white,0,1));
                });
          }),
    );
  }
}
