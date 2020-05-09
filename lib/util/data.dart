import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
import '../models/geeta.dart';
List<String> lang = ['sanskrit','nepali','english'];
Future<List<Geeta>> getData(int chapter) async {
  final Future<Database> database = openDatabase(
    Path.join(await getDatabasesPath(), 'geeta.db'),
    // Path.join('assets', 'geeta.db'),
  );
  final Database db = await database;
  final List<Map<String, dynamic>> maps = await db.query('geeta',where: 'chapter=?', whereArgs: [chapter]);
  await db.close();
  return List.generate(maps.length, (i){
    return Geeta(book: maps[i]['book'],chapter: maps[i]['chapter'],verse: maps[i]['verse'],sanskrit: maps[i]['sanskrit'],nepali: maps[i]['nepali'],english: maps[i]['english'],color: maps[i]['color']);
  });
}
Future<void> addBookmark(int chapter,List<int> verses)async{
  final Future<Database> database = openDatabase(
    Path.join(await getDatabasesPath(), 'geeta.db'),
  );
  final Database db = await database;
  for (var verse in verses) {
  await db.update('geeta', {'isBookmark': 1},where: 'chapter=? and verse=?',whereArgs: [chapter,verse]);
  }
  await db.close();
}
Future<List<Geeta>> getBook() async {
  final Future<Database> database = openDatabase(
    Path.join(await getDatabasesPath(), 'geeta.db'),
  );
  final Database db = await database;
  final List<Map<String, dynamic>> maps = await db.query('geeta',where: 'isBookmark=?', whereArgs: [1]);
  await db.close();
  return List.generate(maps.length, (i){
    return Geeta(book: maps[i]['book'],chapter: maps[i]['chapter'],verse: maps[i]['verse'],sanskrit: maps[i]['sanskrit'],nepali: maps[i]['nepali'],english: maps[i]['english'],color: maps[i]['color']);
  });
}
Future<void> delBookmark(int chapter,int verse)async{
  final Future<Database> database = openDatabase(
    Path.join(await getDatabasesPath(), 'geeta.db'),
  );
  final Database db = await database;
  await db.update('geeta', {'isBookmark': 0},where: 'chapter=? and verse=?',whereArgs: [chapter,verse]);
  await db.close();
}
Future<bool> copyData()async{
  String path = Path.join(await getDatabasesPath(), 'geeta.db');
  if(FileSystemEntity.typeSync(path)==FileSystemEntityType.notFound){
    ByteData data = await rootBundle.load(Path.join('assets','geeta.db'));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes);
    await new File(path).writeAsBytes(bytes).then((file){
      print('copied');
    });
  }
  return true;
}
Future<void> setColor(int color, int chapter, List<int> verses)async{
  final Future<Database> database = openDatabase(
    Path.join(await getDatabasesPath(), 'geeta.db'),
  );
  final Database db = await database;
  for (var verse in verses) {
  await db.update('geeta', {'color': color},where: 'chapter=? and verse=?',whereArgs: [chapter,verse]);
  }
  await db.close();
}
Future<List<Geeta>> searchData(String text, int val)async{
  final Future<Database> database = openDatabase(
    Path.join(await getDatabasesPath(), 'geeta.db'),
  );
  final Database db = await database;
  final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM geeta WHERE ${lang[val]} LIKE ?',['%$text%']);
  await db.close();
   return List.generate(maps.length, (i){
    return Geeta(book: maps[i]['book'],chapter: maps[i]['chapter'],verse: maps[i]['verse'],sanskrit: maps[i]['sanskrit'],nepali: maps[i]['nepali'],english: maps[i]['english'],color: maps[i]['color']);
  });
}