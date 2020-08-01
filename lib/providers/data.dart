import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/geeta.dart';
// import '../data/geeta.dart';
// import '../util/database.dart';
import 'package:flutter/services.dart' show rootBundle;

class DataProvider with ChangeNotifier {
  int _result = 0;
  int get result => _result;
  static Future<Database> initDatabase() async {
    return openDatabase(
      Path.join(await getDatabasesPath(), 'geeta.db'),
    );
  }

  static Future<List<Geeta>> getData(int book, int chapter) async {
    final Database db = await initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('geeta',
        where: 'book=? and chapter=?', whereArgs: [book, chapter]);
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
  // static Future<bool> copyData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   int isDbinserted = prefs.getInt("database");
  //   if (isDbinserted == null) {
  //     await Future.forEach(GEETA, (element) async {
  //       await createData(Geeta(
  //           book: element["book"],
  //           chapter: element["chapter"],
  //           verse: element["verse"],
  //           nepali: element["nepali"],
  //           sanskrit: element["sanskrit"],
  //           english: element["english"]));
  //     });
  //     await prefs.setInt("database", 1);
  //   }
  //   return true;
  // }
  static Future<bool> copyData() async {
    print("entered data");
    String path = Path.join(await getDatabasesPath(), 'geeta.db');
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load(Path.join('assets', 'geeta.db'));
       File file = new File(path);
       final Uint8List bytes = Uint8List(data.lengthInBytes);
       bytes.setRange(0, data.lengthInBytes, data.buffer.asUint8List());
      await file.writeAsBytes(bytes);
      print("data copied");
    }
    return true;
  }


  Future<void> setColor(int color, int chapter, List<int> verses) async {
    final Database db = await initDatabase();
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
  static Future<Database> initDatabase() async {
    return openDatabase(
      Path.join(await getDatabasesPath(), 'geeta.db'),
    );
  }

  Future<void> searchData(String text, int val) async {
    final Database db = await initDatabase();
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
