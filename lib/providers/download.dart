import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';

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
  static Future<bool> copyData() async {
    String path = Path.join(await getDatabasesPath(), 'audio.db');
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load(Path.join('assets', 'audio.db'));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await new File(path).writeAsBytes(bytes).then((file) {
        print('copied audio');
      });
    }
    return true;
  }

  static Future<List<Audio>> getData() async {
    final Future<Database> database = openDatabase(
      Path.join(await getDatabasesPath(), 'audio.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS "audio" (	"id"	INTEGER, "chapter" INTEGER,	"download"	INTEGER DEFAULT 0,	PRIMARY KEY("id"))',
        );
      },
      version: 1,
    );
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('audio');
    await db.close();
    return List.generate(maps.length, (i) {
      return Audio(
        chapter: maps[i]['chapter'],
        download: maps[i]['download'],
      );
    });
  }

  static Future<void> updateAudio(int chapter,bool type) async {
    final Future<Database> database = openDatabase(
      Path.join(await getDatabasesPath(), 'audio.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS "audio" (	"id"	INTEGER, "chapter" INTEGER,	"download"	INTEGER DEFAULT 0,	PRIMARY KEY("id"))',
        );
      },
      version: 1,
    );
    final Database db = await database;
    if(type){
    await db.update('audio', {'download': 1},
        where: 'chapter=?', whereArgs: [chapter]);
    } else {
      await db.update('audio', {'download': 0},
        where: 'chapter=?', whereArgs: [chapter]);
    }
    await db.close();
  }
 Future<List<Audio>> getAudioData() async {
    final Future<Database> database = openDatabase(
      Path.join(await getDatabasesPath(), 'audio.db')
    );
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('audio');
    await db.close();
    return List.generate(maps.length, (i) {
      return Audio(
        chapter: maps[i]['chapter'],
        download: maps[i]['download'],
      );
    });
  }
}
