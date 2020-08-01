import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MyAudio with ChangeNotifier {
  int playingverse;
  int playingchapter;
  Duration duration = Duration(seconds: 0);
  AudioPlaybackState audioPlaybackState = AudioPlaybackState.none;
  AudioPlayer audioPlayer = AudioPlayer();

  MyAudio({this.playingverse = 0, this.playingchapter = 0});
  Future<String> getPath() async {
    return (await getApplicationDocumentsDirectory()).path;
  }

  Future<void> play(
      int chapter, int verse, GlobalKey<ScaffoldState> scaffoldKey) async {
    String dir = await getPath();
    File file = File('$dir/audio/$chapter/${chapter}_$verse.mp3');
    if (file.existsSync()) {
      var _duration = await audioPlayer
          .setFilePath('$dir/audio/$chapter/${chapter}_$verse.mp3')
          .catchError((onError) async {
        return (await this.stop());
      });
      playingverse = verse;
      playingchapter = chapter;
      duration = _duration;
      notifyListeners();
      audioPlaybackState = AudioPlaybackState.playing;
      await audioPlayer.play().then((_) async {
        if (audioPlayer.playbackState == AudioPlaybackState.completed) {
          await this.play(chapter, verse + 1, scaffoldKey);
        }
      });
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Audio doesn\'t exist'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  Future<void> stop() async {
    playingverse = 0;
    playingchapter = 0;
    notifyListeners();
    await audioPlayer.stop();
    audioPlaybackState = AudioPlaybackState.stopped;
  }

  Future<void> pause() async {
    playingverse = 0;
    playingchapter = 0;
    notifyListeners();
    await audioPlayer.pause();
    audioPlaybackState = AudioPlaybackState.paused;
  }

  Future<void> seek(double value) async {
    await audioPlayer.seek(Duration(seconds: (value / 1000).round()));
  }

  Future<bool> disposeAudio() async {
    if (!(audioPlaybackState == AudioPlaybackState.none)) {
      await audioPlayer.dispose();
    }
    return true;
  }

  Stream<Duration> get position => audioPlayer.getPositionStream();
}
