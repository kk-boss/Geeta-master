import 'package:flutter/material.dart';

import '../util/getData.dart';
import '../widgets/datalist.dart';

class Search extends StatefulWidget {
  Search({Key key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _text = TextEditingController();
  List<bool> _selections = [true, false, false];
  int _val = 0;
  bool _buttonSearched = false;
  List<dynamic> lists;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, kToolbarHeight),
          child: Builder(
            builder: (ctx) =>
                // centerTitle: true,
                SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.tealAccent,
                      borderRadius: BorderRadius.circular(35)),
                  child: ListTile(
                      leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          }),
                      title: TextField(
                        controller: _text,
                        onSubmitted: (str) async {
                          lists = await searchData(str, _val);
                          setState(() {
                            _buttonSearched = true;
                          });
                        },
                        textInputAction: TextInputAction.search,
                        autofocus: true,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Search Keyword',
                        ),
                      ),
                      trailing: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async {
                            lists = await searchData(_text.text, _val);
                            setState(() {
                              _buttonSearched = true;
                              FocusScope.of(context).unfocus();
                            });
                          })),
                ),
              ),
            ),
          ),
        ),
        body: _buttonSearched
            ? lists.length > 0
                ? ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: (ctx, i) {
                      if (_val == 2) {
                        return buildData(lists[i].sanskrit, lists[i].english,
                            18, Colors.white, lists[i].color,1);
                      }
                      return buildData(lists[i].sanskrit, lists[i].nepali, 18,
                          Colors.white, lists[i].color,1);
                    })
                : Center(
                    child: Text('Nothing Found'),
                  )
            : Column(
              children: [
                Center(
                  child: ToggleButtons(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Sanskrit'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Nepali'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('English'),
                      ),
                    ],
                    isSelected: _selections,
                    onPressed: (index) {
                      setState(() {
                        _selections = _selections.map((val) => false).toList();
                        _selections[index] = !_selections[index];
                        _val = index;
                      });
                    },
                  ),
                ),
                Text('Please Select a Language to Search'),
              ]));
  }
}
