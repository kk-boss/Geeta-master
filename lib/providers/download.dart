import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/audio.dart';
import '../data/audio.dart';
import '../util/database.dart';

class Audio {
  final int chapter;
  final int download;
  Audio({this.chapter, this.download});
  Map<String, dynamic> toMap() {
    return {
      'chapter': chapter,
      'download': download,
    };
  }
}

class Download with ChangeNotifier {
  static Future<Database> initDatabase()async {
    return openDatabase(
      Path.join(await getDatabasesPath(), 'audio.db'),
    );
  }
  static Future<bool> copyAudioData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int isDbinserted = prefs.getInt("isAudioCreated");
    if (isDbinserted == null) {
      await Future.forEach(AUDIO, (element) async {
        await createAudioData(MyAudio(
          chapter: element["chapter"],
          id: element["id"],
        ));
      });
      await prefs.setInt("isAudioCreated", 1);
    }
    return true;
  }

  static Future<List<Audio>> getData() async {
    final Database db = await initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('audio');
    await db.close();
    return List.generate(maps.length, (i) {
      return Audio(
        chapter: maps[i]['chapter'],
        download: maps[i]['download'],
      );
    });
  }

  static Future<void> updateAudio(int chapter, bool type) async {
    final Database db = await initDatabase();
    if (type) {
      await db.update('audio', {'download': 1},
          where: 'chapter=?', whereArgs: [chapter]);
    } else {
      await db.update('audio', {'download': 0},
          where: 'chapter=?', whereArgs: [chapter]);
    }
    await db.close();
  }
}
