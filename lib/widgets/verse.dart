import 'package:flutter/material.dart';

import '../util/variables.dart';
import '../models/geeta.dart';
import './player.dart';

class Verse extends StatelessWidget {
  Verse(
      {Key key,
      @required this.geeta,
      this.translation,
      this.fontSize,
      this.textColor,
      this.download,
      this.scaffoldKey,
      this.showAudio = true})
      : super(key: key);
  final Geeta geeta;
  final String translation;
  final double fontSize;
  final Color textColor;
  final int download;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool showAudio;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color:
              textColor == Colors.grey[400] ? textColor : color[geeta.color]),
      child: Column(
        children: <Widget>[
          if (geeta.book == 7)
            Text(
              geeta.sanskrit ?? '',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headline6.color,
              ),
            ),
          Text(
            translation ?? geeta.nepali,
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).textTheme.headline6.color,
            ),
          ),
          if (geeta.book == 7 && showAudio)
            download == 1
                ? Player(
                    chapter: geeta.chapter,
                    verse: geeta.verse,
                    scaffoldKey: scaffoldKey,
                  )
                : FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/audio');
                    },
                    child: Text(
                      'Download Audio',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
        ],
      ),
    );
  }
}
