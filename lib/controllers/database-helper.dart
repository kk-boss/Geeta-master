import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;

class DatabaseHelper {
  static Database _db;
  static const String DATABASE_FILE_NAME = 'geeta.db';
  static const String MAIN_TABLE_NAME = 'geeta';
  // static const String SCHEDULE_TABLE_NAME = 'schedule';

  static Future<String> getDatabasePath() async {
    return Path.join(await getDatabasesPath(), DATABASE_FILE_NAME);
  }

  static Future<Database> initDatabase() async {
    if (_db == null) {
      _db = await openDatabase(
        await getDatabasePath(),
      );
    }
    return _db;
  }

  static Future<bool> copyAudioData() async {
    String path = await getDatabasePath();
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle
          .load(Path.join('assets', DatabaseHelper.DATABASE_FILE_NAME));
      File file = new File(path);
      final Uint8List bytes = Uint8List(data.lengthInBytes);
      bytes.setRange(0, data.lengthInBytes, data.buffer.asUint8List());
      await file.writeAsBytes(bytes);
    }
    return true;
  }
}
