import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class AudioTest extends StatelessWidget {
  final audio = AssetsAudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed: (){
          audio.open(Audio('assets/audios/1_1.mp3'));
          audio.playOrPause();
        },
        child: Text('Play'),
      ),
    );
  }
}
