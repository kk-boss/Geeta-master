import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/geeta.dart';
import '../data/geeta.dart';
import '../util/database.dart';

class DataProvider with ChangeNotifier {
  int _result = 0;
  int get result => _result;
  Future<List<Geeta>> get fetchBookmark => getBookmark();
  Future<Database> database() async {
    return openDatabase(
      Path.join(await getDatabasesPath(), 'geeta.db'),
    );
  }

  static Future<List<Geeta>> getData(int book, int chapter) async {
    final Future<Database> database = openDatabase(
      Path.join(await getDatabasesPath(), 'geeta.db'),
    );
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('geeta',
        where: 'book=? and chapter=?', whereArgs: [book, chapter]);
    // await db.close();
    return List.generate(maps.length, (i) {
      return Geeta(
          book: maps[i]['book'],
          chapter: maps[i]['chapter'],
          verse: maps[i]['verse'],
          sanskrit: maps[i]['sanskrit'],
          nepali: maps[i]['nepali'],
          english: maps[i]['english'],
          color: maps[i]['color']);
    });
  }

  Future<void> addBookmarks(int id, int chapter, List<int> verses) async {
    final Future<Database> database = this.database();
    final Database db = await database;
    for (var verse in verses) {
      await db.update('geeta', {'isBookmark': 1},
          where: 'book=? and chapter=? and verse=?',
          whereArgs: [id, chapter, verse]);
    }
    await db.close();
  }

  Future<List<Geeta>> getBookmark() async {
    final Future<Database> database = this.database();
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('geeta', where: 'isBookmark=?', whereArgs: [1]);
    await db.close();
    return List.generate(maps.length, (i) {
      return Geeta(
          book: maps[i]['book'],
          chapter: maps[i]['chapter'],
          verse: maps[i]['verse'],
          sanskrit: maps[i]['sanskrit'],
          nepali: maps[i]['nepali'],
          english: maps[i]['english'],
          color: maps[i]['color']);
    });
  }

  Future<void> delBookmark(int chapter, int verse) async {
    final Future<Database> database = this.database();
    final Database db = await database;
    await db.update('geeta', {'isBookmark': 0},
        where: 'chapter=? and verse=?', whereArgs: [chapter, verse]);
    await db.close();
    notifyListeners();
  }

  static Future<bool> copyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int isDbinserted = prefs.getInt("database");
    if (isDbinserted == null) {
      await Future.forEach(GEETA, (element) async {
        await createData(Geeta(
            book: element["book"],
            chapter: element["chapter"],
            verse: element["verse"],
            nepali: element["nepali"],
            sanskrit: element["sanskrit"],
            english: element["english"]));
      });
      await prefs.setInt("database", 1);
    }
    return true;
  }

  Future<void> setColor(int color, int chapter, List<int> verses) async {
    final Future<Database> database = this.database();
    final Database db = await database;
    for (var verse in verses) {
      await db.update('geeta', {'color': color},
          where: 'chapter=? and verse=?', whereArgs: [chapter, verse]);
    }
    await db.close();
    notifyListeners();
  }
}

class SearchProvider with ChangeNotifier {
  List<Geeta> _lists = [];
  List<String> lang = ['sanskrit', 'nepali', 'english'];
  bool _isSearchPressed = false;
  List<Geeta> get lists => _lists;
  bool get isSearchPressed => _isSearchPressed;
  Future<Database> database() async {
    return openDatabase(
      Path.join(await getDatabasesPath(), 'geeta.db'),
    );
  }

  Future<void> searchData(String text, int val) async {
    final Future<Database> database = this.database();
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('SELECT * FROM geeta WHERE ${lang[val]} LIKE ?', ['%$text%']);
    await db.close();
    _lists.clear();
    List.generate(maps.length, (i) {
      return _lists.add(Geeta(
          book: maps[i]['book'],
          chapter: maps[i]['chapter'],
          verse: maps[i]['verse'],
          sanskrit: maps[i]['sanskrit'],
          nepali: maps[i]['nepali'],
          english: maps[i]['english'],
          color: maps[i]['color']));
    });
    _isSearchPressed = true;
    notifyListeners();
  }

  void clear() {
    _lists.clear();
    _isSearchPressed = false;
  }
}
