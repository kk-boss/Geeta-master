import 'package:flutter/material.dart';
import '../util/strings.dart';

Widget drawer(BuildContext context) {
  return Drawer(
      child: SafeArea(
    child: Column(
      children: <Widget>[
        InkWell(
          child: ListTile(
            leading: Icon(Icons.home),
            title: const Text(home),
          ),
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        InkWell(
          child: ListTile(
            leading: Icon(Icons.bookmark),
            title: const Text(bookmarks),
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/bookmarks');
          },
        ),
        InkWell(
          child: ListTile(
            leading: Icon(Icons.settings),
            title: const Text(settings),
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/settings');
          },
        ),
        InkWell(
          child: ListTile(
            leading: Icon(Icons.android),
            title: const Text('About App'),
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/aboutApp');
          },
        ),
        InkWell(
          child: ListTile(
            leading: Icon(Icons.assessment),
            title: const Text('About Us'),
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/aboutUs');
          },
        ),
      ],
    ),
  ));
}
