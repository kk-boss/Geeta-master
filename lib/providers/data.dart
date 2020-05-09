import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import '../models/geeta.dart';

class DataProvider with ChangeNotifier {
// List<String> lang = ['sanskrit','nepali','english'];
  Future<List<Geeta>> get fetchBookmark => getBookmark();
  Future<Database> database() async {
    return openDatabase(
      Path.join(await getDatabasesPath(), 'geeta.db'),
    );
  }

  Future<List<Geeta>> getData(int book, int chapter) async {
    final Future<Database> database = this.database();
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('geeta',
        where: 'book=? and chapter=?', whereArgs: [book, chapter]);
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

  Future<void> addBookmark(int id, int chapter, List<int> verses) async {
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
    String path = Path.join(await getDatabasesPath(), 'geeta.db');
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load(Path.join('assets', 'geeta.db'));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await new File(path).writeAsBytes(bytes).then((file) {
        print('copied');
      });
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
