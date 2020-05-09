import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio.dart';

class Player extends StatelessWidget {
  const Player({Key key, this.chapter, this.verse,this.scaffoldKey}) : super(key: key);
  final int chapter;
  final int verse;
  final GlobalKey<ScaffoldState> scaffoldKey;
  @override
  Widget build(BuildContext context) {
     final audioProvider = Provider.of<MyAudio>(context);
    return Column(
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              !(audioProvider.playingverse == verse&&audioProvider.playingchapter==chapter)
                  ? IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () async {
                        await audioProvider.play(chapter,verse,scaffoldKey);
                      })
                  : IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () async {
                        await audioProvider.pause();
                      }),
              IconButton(
                  icon: Icon(Icons.stop),
                  onPressed: !(audioProvider.playingverse == verse&&audioProvider.playingchapter==chapter)
                      ? null
                      : () async {
                          await audioProvider.stop();
                        }),
            ],
          ),
          if (audioProvider.playingverse == verse&&audioProvider.playingchapter==chapter)
            StreamBuilder(
              builder: (ctx, s) {
                Duration _position = s.data;
                if(s.data==null||audioProvider.duration==null){
                  return Container();
                }
                if(s.data.inMilliseconds.toDouble()>=audioProvider.duration?.inMilliseconds?.toDouble()){
                 _position = audioProvider.duration;
                }
                return Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(_position.toString().split('.').first),
                         Text(audioProvider.duration.toString().split('.').first),
                    ],),
                    Slider(
                      value: _position?.inMilliseconds?.toDouble() ?? 0.0,
                      min: 0.0,
                      max: audioProvider.duration.inMilliseconds.toDouble(),
                      onChanged: (value)async{
                          await audioProvider.seek(value);
                      },
                    ),
                  ],
                );
              },
              stream: audioProvider.position,
            ),
      ]
    );
  }
}