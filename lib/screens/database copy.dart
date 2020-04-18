import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';

import '../book.dart';
import '../models/chapter.dart';
var run = 0;
class Data{
  final int book;
  final int chapter;
  final int verse;
  final String nepali;
  final String english;

  Data({this.book, this.chapter, this.verse, this.nepali, this.english});
  Map<String,dynamic> toMap(){
    return {
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'nepali': nepali,
      'english': english,
    };
  }
}
Future<void> createData(Data data1)async{
final Future<Database> database = openDatabase(Path.join(await getDatabasesPath(),'mydata.db'),
onCreate: (db,version){
  return db.execute('CREATE TABLE IF NOT EXISTS "note" (	"book"	INTEGER,	"chapter"	INTEGER,	"verse"	INTEGER,	"nepali"	TEXT,	"english"	TEXT,	PRIMARY KEY("book"))',);
},
version: 1,
);
Future<void> insertData(Data dd)async{
  final Database db = await database;
  await db.insert('note', dd.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
  run++;
print(run);
}
await insertData(data1);
}

class DataBase extends StatelessWidget {
  const DataBase({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Chapter> chapters = CHAPTER
        .where((test) => test.chapter == 1)
        .toList();
    final int verseCount = chapters[0].verseCount;
    final List<List<String>> verses = chapters[0].verse;
    return Scaffold(
      appBar: AppBar(
        title: Text('database')
      ),
      body: Container(child: Column(
        children: <Widget>[
           RaisedButton(onPressed: (){
            for (var i = 0; i < verseCount; i++) {
              createData(Data(book: 1,chapter:1,verse:i+1,nepali:verses[i][1],english:verses[i][0]));
            }
          }, child: Text('Test'),),
        ],
      ),)
    );
  }
}