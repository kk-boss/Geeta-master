import 'package:flutter/material.dart';

import '../models/book.dart';

class ChoiceScreen extends StatefulWidget {
  static const String routeName = '/choice';

  @override
  _ChoiceScreenState createState() => _ChoiceScreenState();
}

class Modeel {
  final int id;
  final int chapter;

  Modeel({this.id, this.chapter});
}

class _ChoiceScreenState extends State<ChoiceScreen> {
  int chapterCount = 0;
  int id = 0;
  bool firstRun = true;
  int initialIndex = 0;
  @override
  void initState() {
    super.initState();  
  }
  @override
  void didChangeDependencies() {
    if (firstRun) {
      var routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, int>;
      if (routeArgs != null) {
        id = routeArgs["id"];
        chapterCount = BOOK.where((test) => test.id == id).toList()[0].chapter;
        initialIndex = 1;
      }
      firstRun = false;
    }
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        initialIndex: initialIndex,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Geeta'),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text('Book'),
                ),
                Tab(
                  child: Text('Chapter'),
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
                itemCount: chapterCount,
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
                            'id': id,
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
          chapterCount = book[0].chapter;
          id = book[0].id;
        });
      },
    );
  }
}
