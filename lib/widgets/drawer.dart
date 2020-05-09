import 'package:flutter/material.dart';

Widget drawer(BuildContext context) {
  return Drawer(
      child: SafeArea(
    child: Column(
      children: <Widget>[
        InkWell(
          child: ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
          ),
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        InkWell(
          child: ListTile(
            leading: Icon(Icons.bookmark),
            title: Text('Bookmarks'),
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/bookmarks');
          },
        ),
        InkWell(
          child: ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/settings');
          },
        ),
      ],
    ),
  ));
}
