import 'package:flutter/material.dart';

class BookTitle extends StatelessWidget {
  const BookTitle({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: kToolbarHeight / 1.5,
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
        ),
        child: Center(
          child: Tooltip(
            message: title,
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).pushNamed('/choice');
      },
    );
  }
}

class ChapterNumber extends StatelessWidget {
  const ChapterNumber({
    Key key,
    @required int currentPage,
    @required int id,
  })  : _currentPage = currentPage,
        _id = id,
        super(key: key);

  final int _currentPage;
  final int _id;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: kToolbarHeight / 1.5,
        width: kToolbarHeight / 1.5,
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
        ),
        child: Center(
          child: Text(
            (_currentPage + 1).toString(),
            style: Theme.of(context).textTheme.headline6,
            textScaleFactor: 0.75,
            overflow: TextOverflow.clip,
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).pushNamed('/choice',
            arguments: {'id': _id, 'chapter': _currentPage + 1});
      },
    );
  }
}
