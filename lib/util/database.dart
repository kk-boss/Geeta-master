import 'dart:async';
import 'package:path/path.dart' as Path;
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import '../models/geeta.dart';
import '../models/audio.dart';

int run = 0;
var streamController = BehaviorSubject<int>();
Sink get resultSink => streamController.sink;
Stream<int> get resultStream => streamController.stream;
Future<int> createData(Geeta data)async{
final Future<Database> database = openDatabase(Path.join(await getDatabasesPath(),'geeta.db'),
onCreate: (db,version){
  return db.execute('CREATE TABLE "geeta" ("id" INTEGER,	"book"	INTEGER,	"chapter"	INTEGER,	"verse"	INTEGER,	"nepali"	TEXT,	"sanskrit"	TEXT, "english" TEXT, "isBookmark" INTEGER DEFAULT 0, "color" INTEGER DEFAULT 0,	PRIMARY KEY("id"))');
},
version: 1,
);
Future<int> insertData(Geeta dd)async{
  final Database db = await database;
  await db.insert('geeta', dd.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
  run++;
  resultSink.add(run);
return run;
}
return (await insertData(data));
}
Future<bool> createAudioData(MyAudio data)async{
final Future<Database> database = openDatabase(Path.join(await getDatabasesPath(),'audio.db'),
onCreate: (db,version){
  return db.execute('CREATE TABLE "audio" (	"id"	INTEGER, "chapter" INTEGER,	"download"	INTEGER DEFAULT 0,	PRIMARY KEY("id"))');
},
version: 1,
);
Future<bool> insertAudioData(MyAudio dd)async{
  final Database db = await database;
  await db.insert('audio', dd.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
return true;
}
return (await insertAudioData(data));
}