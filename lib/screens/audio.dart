import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/audio.dart';
import '../providers/gita.dart';

class AudioDownload extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gita = Provider.of<Gita>(context);
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
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              if (gita.audio.isEmpty) {
                return CircularProgressIndicator();
              }
              return ListView.builder(
                itemBuilder: (context, index) {
                  return AudioList(
                    index: index,
                    chapter: gita.audio[index].id,
                    isdownload: gita.audio[index].download,
                  );
                },
                itemCount: 18,
              );
            },
          ),
        ),
      ),
    );
  }
}
