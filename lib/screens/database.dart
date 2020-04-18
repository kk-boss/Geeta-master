import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';

import '../book.dart';
import '../models/chapter.dart';
import '../engliah.dart';
// import '../util/getData.dart';

var ok = 0;

// class Dog {
//   final int id;
//   final String name;
//   final int age;

//   Dog({this.id, this.name, this.age});

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'age': age,
//     };
//   }

//   @override
//   String toString() {
//     return 'Dog{id:$id, name:$name, age: $age}';
//   }
// }

class Data {
  final int book;
  final int chapter;
  final int verse;
  final String nepali;
  final String sanskrit;
  final String english;

  Data(
      {this.book,
      this.chapter,
      this.verse,
      this.nepali,
      this.sanskrit,
      this.english});
  Map<String, dynamic> toMap() {
    return {
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'nepali': nepali,
      'sanskrit': sanskrit,
      'english': english,
    };
  }
  // @override
  // String toString() {
  //   return 'Data{book:$book, chapter:$chapter,verse:$verse}';
  // }
}

// var fido = Dog(id: 1,name: 'hi',age: 7);
// var fidok = Dog(id: 1, name: 'helling', age: 7);
Future<void> createDog(Data kk) async {
  // Future<void> createDog() async {
  final Future<Database> database = openDatabase(
    Path.join(await getDatabasesPath(), 'geeta.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE IF NOT EXISTS "geeta" ("id" INTEGER,	"book"	INTEGER,	"chapter"	INTEGER,	"verse"	INTEGER,	"nepali"	TEXT,	"sanskrit"	TEXT, "english" TEXT, "isBookmark" INTEGER DEFAULT 0, "color" INTEGER DEFAULT 0,	PRIMARY KEY("id"))',
      );
    },
    version: 1,
  );
  Future<void> insertDog(Data ked) async {
    final Database db = await database;
    await db.insert('geeta', ked.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    // db.update('geeta', {'english': 'hi'},conflictAlgorithm: ConflictAlgorithm.replace);
    ok++;
    print(ok);
  }
// int len;
// Future<List<Data>> dogs()async{
//   final Database db = await database;
//   final List<Map<String, dynamic>> maps = await db.query('geeta',where: 'chapter=?', whereArgs: [18]);
//   len = maps.length;
//   return List.generate(maps.length, (i){
//     return Data(book: maps[i]['book'],chapter: maps[i]['chapter'],verse: maps[i]['verse'],sanskrit: maps[i]['sanskrit'],english: maps[i]['english'],);
//   });
// }
// await insertDog(fido);
  await insertDog(kk);

// print(await dogs());
// print(len);
}

class DataBase extends StatelessWidget {
  const DataBase({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('database')),
        body: Container(
          child: Column(
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  for (var j = 1; j <= 18; j++) {
                  final List<Chapter> chapters =
                      CHAPTER.where((test) => test.chapter == j).toList();
                  final int verseCount = chapters[0].verseCount;
                  final List<List<String>> verses = chapters[0].verse;
                  final List<String> engVerses = ENGLISH[j-1];
                  //  var i=0;
                  for (var i = 0; i < verseCount; i++) {
                    await createDog(Data(
                        book: 1,
                        chapter: j,
                        verse: i + 1,
                        nepali: verses[i][1],
                        sanskrit: verses[i][0],
                        english: engVerses[i]));
                  }
                  }
                },
                child: Text('Test'),
              ),
              //  Center(
              //    child: RaisedButton(
              //     onPressed: () async {
              //       await copyData();
              //     },
              //     child: Text('Insert Data'),
              // ),
              //  ),
            ],
          ),
        ));
  }
}
