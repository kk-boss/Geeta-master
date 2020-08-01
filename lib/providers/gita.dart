import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/geeta.dart';
import '../controllers/database-helper.dart';

class Gita with ChangeNotifier {
  List<Geeta> _items = [];

  List<Geeta> get items => _items;

  Future<void> fetchAndSetData(int book, int chapter) async {
    final Database db = await DatabaseHelper.initDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.MAIN_TABLE_NAME,
        where: 'book=? and chapter=?',
        whereArgs: [book, chapter]);
    _items = List.generate(maps.length, (i) {
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
  }
}
