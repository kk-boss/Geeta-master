import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/geeta.dart';
import '../controllers/database-helper.dart';

class SearchProvider with ChangeNotifier {
  List<Geeta> _lists = [];
  List<String> lang = ['sanskrit', 'nepali', 'english'];
  bool _isSearchPressed = false;
  List<Geeta> get lists => _lists;
  bool get isSearchPressed => _isSearchPressed;

  Future<void> searchData(String text, int val) async {
    final Database db = await DatabaseHelper.initDatabase();
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('SELECT * FROM geeta WHERE ${lang[val]} LIKE ?', ['%$text%']);
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
