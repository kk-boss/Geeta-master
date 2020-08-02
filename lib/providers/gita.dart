import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:path/path.dart' as Path;

import '../models/geeta.dart';
import '../models/audio.dart';
import '../controllers/database-helper.dart';
import '../controllers/sharedprefs.dart';

class Gita with ChangeNotifier {
  List<Geeta> _items = [];
  List<Audio> _audio = [];

  List<Geeta> get items => _items;
  List<Audio> get audio => _audio;

  int chapter = 1;
  int book = 7;

  Gita() {
    copyData();
  }

  Future<void> initializeSavedState() async {
    final savedState = await getSavedState();
    book = savedState[0] ?? 7;
    chapter = savedState[1] ?? 1;
  }

  Future<void> fetchAndSetData(int book, int chapter) async {
    if (!(await databaseExists(await DatabaseHelper.getDatabasePath()))) {
      print('database doesn\'t exist');
      return;
    }
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
        color: maps[i]['color'],
        audio: maps[i]['audio'],
      );
    });
    this.chapter = chapter;
    this.book = book;
    notifyListeners();
    await setSavedState(book, chapter);
  }

  Future<void> fetchAndSetAudioData() async {
    final Database db = await DatabaseHelper.initDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(DatabaseHelper.AUDIO_TABLE_NAME);
    _audio = List.generate(maps.length, (i) {
      return Audio(
        id: maps[i]['id'],
        download: maps[i]['isDownload'],
      );
    });
  }

  Future<void> updateAudio(int chapter, bool type) async {
    final Database db = await DatabaseHelper.initDatabase();
    if (type) {
      await db.update(DatabaseHelper.AUDIO_TABLE_NAME, {'isDownload': 1},
          where: 'id=?', whereArgs: [chapter]);
    } else {
      await db.update(DatabaseHelper.AUDIO_TABLE_NAME, {'isDownload': 0},
          where: 'id=?', whereArgs: [chapter]);
    }
    await fetchAndSetAudioData();
    notifyListeners();
  }

  Future<bool> copyData() async {
    String path = await DatabaseHelper.getDatabasePath();
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle
          .load(Path.join('assets', DatabaseHelper.DATABASE_FILE_NAME));
      File file = new File(path);
      final Uint8List bytes = Uint8List(data.lengthInBytes);
      bytes.setRange(0, data.lengthInBytes, data.buffer.asUint8List());
      await file.writeAsBytes(bytes);
    }
    await initializeSavedState();
    await fetchAndSetAudioData();
    fetchAndSetData(book, chapter);
    return true;
  }

  Future<void> setColor(int color, int chapter, List<int> verses) async {
    final Database db = await DatabaseHelper.initDatabase();
    for (var verse in verses) {
      await db.update(DatabaseHelper.MAIN_TABLE_NAME, {'color': color},
          where: 'chapter=? and verse=?', whereArgs: [chapter, verse]);
    }
    fetchAndSetData(book, chapter);
  }
}
