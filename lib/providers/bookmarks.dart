import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';

import '../models/geeta.dart';

class BookmarkManager with ChangeNotifier {
  List<Geeta> _bookmarks;

  BookmarkManager() {
    _loadBookmark();
  }
  static Future<Database> initDatabase() async {
    return openDatabase(
      Path.join(await getDatabasesPath(), 'geeta.db'),
    );
  }

  void _loadBookmark() {
   initDatabase().then((Database db) {
        db.query('geeta', where: 'isBookmark=?', whereArgs: [1]).then(
            (List<Map<String, dynamic>> maps) {
          _bookmarks = List.generate(maps.length, (i) {
            return Geeta(
                book: maps[i]['book'],
                chapter: maps[i]['chapter'],
                verse: maps[i]['verse'],
                sanskrit: maps[i]['sanskrit'],
                nepali: maps[i]['nepali'],
                english: maps[i]['english'],
                color: maps[i]['color']);
          });
          notifyListeners();
        });
      });
  }

  List<Geeta> get bookmarks {
    if (_bookmarks == null) {
      _bookmarks = [];
    }
    return _bookmarks;
  }

  Future<void> setBookmark(int id, int chapter, List<int> verses) async {
    final Database db = await initDatabase();
    for (var verse in verses) {
      await db.update('geeta', {'isBookmark': 1},
          where: 'book=? and chapter=? and verse=?',
          whereArgs: [id, chapter, verse]);
    }
    await db.close();
    notifyListeners();
    _loadBookmark();
  }

  Future<void> deleteBookmark(int chapter, int verse) async {
    final Database db = await initDatabase();
    await db.update('geeta', {'isBookmark': 0},
        where: 'chapter=? and verse=?', whereArgs: [chapter, verse]);
    await db.close();
    notifyListeners();
    _loadBookmark();
  }
}
