import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/geeta.dart';
import '../controllers/database-helper.dart';

class BookmarkManager with ChangeNotifier {
  List<Geeta> _bookmarks;

  BookmarkManager() {
    // _loadBookmark();
  }

  void _loadBookmark() {
    DatabaseHelper.initDatabase().then((Database db) {
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
    }).catchError((err) {
      _bookmarks = [];
    });
  }

  List<Geeta> get bookmarks {
    if (_bookmarks == null) {
      _bookmarks = [];
    }
    return _bookmarks;
  }

  Future<void> setBookmark(int id, int chapter, List<int> verses) async {
    final Database db = await DatabaseHelper.initDatabase();
    for (var verse in verses) {
      await db.update('geeta', {'isBookmark': 1},
          where: 'book=? and chapter=? and verse=?',
          whereArgs: [id, chapter, verse]);
    }
    notifyListeners();
    _loadBookmark();
  }

  Future<void> deleteBookmark(int chapter, int verse) async {
    final Database db = await DatabaseHelper.initDatabase();
    await db.update('geeta', {'isBookmark': 0},
        where: 'chapter=? and verse=?', whereArgs: [chapter, verse]);
    notifyListeners();
    _loadBookmark();
  }
}
