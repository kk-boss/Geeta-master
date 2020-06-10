import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

import '../widgets/audio.dart';
import '../providers/download.dart';
import '../util/strings.dart';

class AudioDownload extends StatefulWidget {
  @override
  _AudioDownloadState createState() => _AudioDownloadState();
}

class _AudioDownloadState extends State<AudioDownload> {
  Future<List<Audio>> _audio;
  InterstitialAd _interstitialAd;
  @override
  void initState() {
    super.initState();
    _audio = Download.getData();
    _interstitialAd = createInterstitialAd();
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: interId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Are you sure to exit?'),
              content: const Text(
                'Ongoing downloads will be stopped',
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text(
                      'Exit',
                    )),
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text(
                      'Stay',
                    )),
              ],
            );
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Audio List'),
          actions: <Widget>[
            FlatButton(
              onPressed: () async {
                await _interstitialAd.load();
                await _interstitialAd.show();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: const Text('Reload App'),
            ),
          ],
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
      ),
    );
  }
}
