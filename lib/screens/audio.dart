import 'package:flutter/material.dart';

import '../widgets/audio.dart';
import '../providers/download.dart';

class AudioDownload extends StatefulWidget {
  @override
  _AudioDownloadState createState() => _AudioDownloadState();
}

class _AudioDownloadState extends State<AudioDownload> {
  Future<List<Audio>> _audio;
  @override
  void initState() {
    super.initState();
    _audio = Download.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio List'),
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: _audio,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              final List<Audio> audio = snapshot.data;
              return ListView.builder(
                itemBuilder: (context, index) {
                  return AudioList(
                    index: index,
                    chapter: audio[index].chapter,
                    isdownload: audio[index].download,
                  );
                },
                itemCount: 18,
              );
            }),
      ),
    );
  }
}
