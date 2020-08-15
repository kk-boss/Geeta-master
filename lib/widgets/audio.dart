import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/gita.dart';

class AudioList extends StatefulWidget {
  const AudioList(
      {Key key, this.index, this.isdownload, this.chapter, this.audioUrl})
      : super(key: key);
  final int index;
  final int isdownload;
  final int chapter;
  final String audioUrl;
  @override
  _AudioListState createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {
  int _isdownload;
  int _download = 0;
  double _ptr = 0.0;
  @override
  void initState() {
    super.initState();
    _isdownload = widget.isdownload;
  }

  Future<void> download(String url) async {
    var httpClient = http.Client();
    var request = http.Request('GET', Uri.parse(url));
    var response = httpClient.send(request).catchError((onError) {
      print('error');
    });
    String dir = (await getApplicationDocumentsDirectory()).path;
    List<List<int>> chunks = new List();
    int downloaded = 0;
    response.asStream().listen((http.StreamedResponse r) {
      r.stream.listen(
        (List<int> chunk) {
          chunks.add(chunk);
          downloaded += chunk.length;
          setState(() {
            _ptr = downloaded / r.contentLength * 100;
          });
        },
        onDone: () async {
          File file = new File('$dir/1.zip');
          final Uint8List bytes = Uint8List(r.contentLength);
          int offset = 0;
          for (List<int> chunk in chunks) {
            bytes.setRange(offset, offset + chunk.length, chunk);
            offset += chunk.length;
          }
          await file.writeAsBytes(bytes).then((downloadedFile) async {
            setState(() {
              _download = 2;
            });
            await unZip(downloadedFile, dir);
          });
        },
        cancelOnError: true,
      );
    });
  }

  Future<void> unZip(File file, String dir) async {
    final bytes = file.readAsBytesSync();
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final filename = file.name;
        print(file.isFile);
        if (file.isFile) {
          final data = file.content as List<int>;
          File('$dir/audio/' + filename)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('$dir/audio/' + filename)..create(recursive: true);
        }
      }
      await Provider.of<Gita>(context, listen: false)
          .updateAudio(widget.chapter, true);
      file.deleteSync(recursive: true);
      setState(() {
        _download = 0;
        _isdownload = 1;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('An error occured'),
            content: Text(
                'Could not complete download. Please try again by changing server.'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
      setState(() {
        _isdownload = widget.isdownload;
        _download = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Chapter ${widget.index + 1}',
              style: TextStyle(fontSize: 18),
            ),
          ),
          test(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (_isdownload == 1)
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Are you sure?'),
                            content: Text(
                                'Audios of chapter ${widget.index + 1} will be deleted.'),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () async {
                                    String dir =
                                        (await getApplicationDocumentsDirectory())
                                            .path;
                                    File folder =
                                        File('$dir/audio/${widget.index + 1}');
                                    folder
                                        .delete(recursive: true)
                                        .then((fileSystemEntity) {
                                      Provider.of<Gita>(context, listen: false)
                                          .updateAudio(widget.chapter, false);
                                      setState(() {
                                        _isdownload = 0;
                                      });
                                    }).catchError((onError) {
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                        content: const Text('An error occured'),
                                      ));
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Yes')),
                              FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('No')),
                            ],
                          );
                        },
                      );
                    }),
              if (_isdownload == 0)
                IconButton(
                    icon: Icon(Icons.file_download),
                    onPressed: () async {
                      var connection =
                          await (Connectivity().checkConnectivity());
                      if (connection == ConnectivityResult.none) {
                        Scaffold.of(context).hideCurrentSnackBar();
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: const Text('No internet connection'),
                        ));
                        return;
                      }
                      setState(() {
                        _download = 1;
                        _isdownload = 2;
                      });
                      await download(widget.audioUrl);
                    })
            ],
          ),
        ],
      ),
    );
  }

  Widget test() {
    switch (_download) {
      case 1:
        return Row(
          children: <Widget>[
            AbsorbPointer(
              child: Slider(
                value: _ptr,
                onChanged: (_) {},
                min: 0,
                max: 100,
                label: '50',
              ),
            ),
            Text(_ptr.toStringAsFixed(0) + '%'),
          ],
        );
        break;
      case 2:
        return Row(
          children: <Widget>[
            CircularProgressIndicator(),
          ],
        );
        break;
      default:
        return Container();
    }
  }
}
