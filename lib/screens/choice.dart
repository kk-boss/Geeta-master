import 'package:flutter/material.dart';

import '../models/book.dart';

class Choice extends StatefulWidget {
  Choice({Key key}) : super(key: key);

  @override
  _ChoiceState createState() => _ChoiceState();
}

class _ChoiceState extends State<Choice> {
  int _chapterCount = 0;
  int _id = 0;
  bool _firstRun = true;
  var _currentIndex = 0;
  var _title = 'Choose Book';

  @override
  void didChangeDependencies() {
    if (_firstRun) {
      var routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      if (routeArgs != null) {
        _id = routeArgs["id"];
        _chapterCount = BOOK.firstWhere((test) => test.id == _id).chapter;
        _currentIndex = 1;
        _title = routeArgs['title'];
      }
      _firstRun = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: _currentIndex == 0
          ? buildListTile(context, 16)
          : buildGridView(16, context, _chapterCount),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.book), title: Text('Book')),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            title: Text('Chapter'),
          ),
        ],
        onTap: _currentIndex == 1
            ? (index) {
                setState(() {
                  _currentIndex = index;
                  _title = 'Choose Book';
                });
              }
            : null,
      ),
    );
  }

  Widget buildListTile(BuildContext ctx, double fontSize) {
    return ListView.builder(
        itemCount: BOOK.length,
        itemBuilder: (context, index) {
          final book = BOOK.firstWhere((test) => test.id == index + 1);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 5.0,
              child: ListTile(
                leading: Text((book.id).toString()),
                title: Text(
                  book.title,
                  style: TextStyle(fontSize: fontSize),
                ),
                onTap: () {
                  setState(() {
                    _chapterCount = book.chapter;
                    _id = book.id;
                    _currentIndex = 1;
                    _title = book.title;
                  });
                },
              ),
            ),
          );
        });
  }

  GridView buildGridView(
      double fontSize, BuildContext context, int chapterCount) {
    print('building gridView $chapterCount');
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 50,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: chapterCount,
      itemBuilder: (ctx, i) {
        return InkWell(
          child: Container(
            child: Center(
              child: Text(
                (i + 1).toString(),
                style: TextStyle(color: Colors.white, fontSize: fontSize),
              ),
            ),
            decoration: BoxDecoration(color: Colors.deepPurple),
          ),
          onTap: () {
            Navigator.of(context).pop({
              'chapter': i,
              'id': _id,
            });
          },
        );
      },
    );
  }
}
