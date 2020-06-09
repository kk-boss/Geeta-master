
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/verse.dart';
import '../providers/data.dart';
import '../models/geeta.dart';

class Search extends StatefulWidget {
  Search({Key key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _text = TextEditingController();
  List<bool> _selections = [true, false, false];
  int _val = 0;
  SearchProvider _searchProvider;
  @override
  void dispose() { 
    _searchProvider.clear();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    _searchProvider = Provider.of<SearchProvider>(context);
     List<Geeta> lists = _searchProvider.lists;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, kToolbarHeight),
          child: Builder(
            builder: (ctx) =>
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
                          if(str!=''){
                          await _searchProvider.searchData(str, _val);
                          }
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
                            if(_text.text!=''){
                            await _searchProvider.searchData(_text.text, _val);
                            }
                              FocusScope.of(context).unfocus();
                          })),
                ),
              ),
            ),
          ),
        ),
        body: _searchProvider.isSearchPressed
            ? lists.length > 0
                ? ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: (ctx, i) {
                      if (_val == 2) {
                        return Verse(geeta: lists[i],translation: lists[i].english,fontSize: 18,textColor: Colors.white,);
                      }
                      return Verse(geeta: lists[i],translation: lists[i].nepali,fontSize: 18,textColor: Colors.white,);
                    })
                : Center(
                    child: const Text('Nothing Found'),
                  )
            : Column(
              children: [
                Center(
                  child: ToggleButtons(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text('Sanskrit'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text('Nepali'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text('English'),
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
                const Text('Please Select a Language to Search'),
              ]));
  }
}
