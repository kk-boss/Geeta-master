import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../widgets/audio.dart';
import '../providers/gita.dart';
import '../util/strings.dart';

Future<List<dynamic>> getDropAudioUris() async {
  print('called');
  const url =
      'https://shreemad-bhagvad-gita.firebaseio.com/audioUrl/audioDropbox.json';
  final res = await http.get(url);
  final response = json.decode(res.body) as Map<String, dynamic>;
  final audioUris = response['-MEChw5WrcCPdwyleIgO'] as List<dynamic>;
  return audioUris;
}

Future<List<dynamic>> getOneAudioUris() async {
  const url =
      'https://shreemad-bhagvad-gita.firebaseio.com/audioUrl/audioOneDrive.json';
  final res = await http.get(url);
  final response = json.decode(res.body) as Map<String, dynamic>;
  final audioUris = response['-MECiJlQz6cqg0Ssoqz5'] as List<dynamic>;
  return audioUris;
}

class AudioDownload extends StatefulWidget {
  @override
  _AudioDownloadState createState() => _AudioDownloadState();
}

class _AudioDownloadState extends State<AudioDownload> {
  int server = 1;
  Future<List<dynamic>> _uriFuture = getOneAudioUris();
  List<String> _uriLocal = audioUrisOnedrive;
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
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Audio List'),
          actions: [
            FlatButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (ctxx) {
                    return Container(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 4,
                          itemBuilder: (ctx, index) {
                            return ListTile(
                              title: Text('Server ${index + 1}'),
                              onTap: () {
                                switch (index) {
                                  case 0:
                                    _uriLocal = audioUrisOnedrive;
                                    break;
                                  case 1:
                                    _uriLocal = audioUrisDropBox;
                                    break;
                                  case 2:
                                    _uriFuture = getOneAudioUris();
                                    break;
                                  case 3:
                                    _uriFuture = getDropAudioUris();
                                    break;
                                }
                                setState(() {
                                  server = index + 1;
                                });
                                Navigator.of(ctxx).pop();
                              },
                            );
                          },
                        ));
                  },
                );
              },
              child: Text('Server $server'),
            ),
          ],
        ),
        body: SafeArea(
          child: getPreferredWidget(server, gita),
        ),
      ),
    );
  }

  Widget getPreferredWidget(int server, Gita gita) {
    if (server == 1 || server == 2) {
      return Builder(
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
                audioUrl: _uriLocal[index],
              );
            },
            itemCount: 18,
          );
        },
      );
    } else {
      return FutureBuilder<List<dynamic>>(
        future: _uriFuture,
        builder: (context, snapshot) {
          if (gita.audio.isEmpty || !snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              return AudioList(
                index: index,
                chapter: gita.audio[index].id,
                isdownload: gita.audio[index].download,
                audioUrl: snapshot.data[index + 1],
              );
            },
            itemCount: 18,
          );
        },
      );
    }
  }
}
