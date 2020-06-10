import 'package:flutter/material.dart';

import '../models/book.dart';

class ChoiceScreen extends StatefulWidget {

  @override
  _ChoiceScreenState createState() => _ChoiceScreenState();
}

class _ChoiceScreenState extends State<ChoiceScreen> {
  int _chapterCount = 0;
  int _id = 0;
  bool _firstRun = true;
  int _initialIndex = 0;
  @override
  void initState() {
    super.initState();  
  }
  @override
  void didChangeDependencies() {
    if (_firstRun) {
      var routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, int>;
      if (routeArgs != null) {
        _id = routeArgs["id"];
        _chapterCount = BOOK.where((test) => test.id == _id).toList()[0].chapter;
        _initialIndex = 1;
      }
      _firstRun = false;
    }
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        initialIndex: _initialIndex,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Geeta'),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: const Text('Book'),
                ),
                Tab(
                  child: const Text('Chapter'),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView.builder(
                itemCount: BOOK.length,
                itemBuilder: (ctx, i) {
                  return buildListTile(
                      ctx, BOOK.where((test) => test.id == i + 1).toList());
                },
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 50,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _chapterCount,
                itemBuilder: (ctx, i) {
                  return InkWell(
                    child: Container(
                      child: Center(
                        child: Text(
                          (i + 1).toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      decoration: BoxDecoration(color: Colors.deepPurple),
                    ),
                    onTap: () async {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/', (Route<dynamic> route) => false,
                          arguments: {
                            'chapter': i,
                            'id': _id,
                          });
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListTile(BuildContext ctx, List book) {
    return InkWell(
      child: ListTile(
        leading: Text((book[0].id).toString()),
        title: Text(book[0].title),
      ),
      onTap: () {
        DefaultTabController.of(ctx).animateTo(1);
        setState(() {
          _chapterCount = book[0].chapter;
          _id = book[0].id;
        });
      },
    );
  }
}
