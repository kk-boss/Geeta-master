import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../book.dart';
import '../widgets/verse.dart';
import '../providers/data.dart';
import '../controllers/sharedprefs.dart';

class Bookmarks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final getBook = dataProvider.getBookmark();
    final lang = getLang();
    return Scaffold(
      appBar: AppBar(title: Text('Bookmarks')),
      body: FutureBuilder(
          future: Future.wait([getBook, lang]),
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
                  final String langData =
                      snapsot.data[1] == 0 ? item.nepali : item.english;
                  return Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction) async {
                      items.removeAt(i);
                      await dataProvider
                          .delBookmark(item.chapter, item.verse)
                          .then((_) {
                            Scaffold.of(ctx).removeCurrentSnackBar();
                        Scaffold.of(ctx).showSnackBar(SnackBar(
                          content: const Text('Verse Removed from Bookmarks'),
                          behavior: SnackBarBehavior.floating,
                        ));
                      });
                    },
                    child: Verse(
                      geeta: item,
                      translation: langData,
                      fontSize: 18,
                      textColor: Colors.white,
                    ),
                    background: Container(
                      padding: const EdgeInsets.only(
                        right: 12,
                      ),
                      alignment: Alignment.centerLeft,
                      color: Colors.red,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      padding: const EdgeInsets.only(
                        right: 12,
                      ),
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
