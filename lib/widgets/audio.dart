import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:http/http.dart' as http;

import '../providers/download.dart';

class AudioList extends StatefulWidget {
  AudioList({Key key, this.index, this.isdownload, this.chapter})
      : super(key: key);
  final int index;
  final int isdownload;
  final int chapter;
  @override
  _AudioListState createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {
    static const List<String> uri = [
    'https://firebasestorage.googleapis.com/v0/b/shreemad-bhagvad-gita.appspot.com/o/1.zip?alt=media&token=ded8ffa3-197a-4aea-9320-61adac2e7322',
    'https://firebasestorage.googleapis.com/v0/b/shreemad-bhagvad-gita.appspot.com/o/2.zip?alt=media&token=b7d6ce7a-55f9-4bc7-871e-41fd4e01ec9f',
    'https://firebasestorage.googleapis.com/v0/b/shreemad-bhagvad-gita.appspot.com/o/3.zip?alt=media&token=0f2a3dbc-f78e-4128-94f9-54f90992646c',
    'https://firebasestorage.googleapis.com/v0/b/shreemad-bhagvad-gita.appspot.com/o/4.zip?alt=media&token=b43ce962-6419-4bb8-ba1a-96ddcc7d200c',
    'https://firebasestorage.googleapis.com/v0/b/shreemad-bhagvad-gita.appspot.com/o/5.zip?alt=media&token=3917eada-1fdf-403a-a68f-15b21044c464',
  ];
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
    final destPath = Directory('$dir/audio/');
    print(destPath);
    try {
      FlutterArchive.unzip(zipFile: file, destinationDir: destPath).then((_) {
        Download.updateAudio(widget.chapter, true);
        file.deleteSync(recursive: true);
        setState(() {
          _download = 3;
        });
      });
    } catch (e) {
      print(e);
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
                    onPressed: () async {
                      String dir =
                          (await getApplicationDocumentsDirectory()).path;
                      File folder = File('$dir/audio/${widget.index + 1}');
                      folder.delete(recursive: true).then((fileSystemEntity) {
                        Download.updateAudio(widget.chapter, false);
                        setState(() {
                          _isdownload = 0;
                        });
                      }).catchError((onError) {
                        print('error');
                      });
                    }),
              _isdownload == 0
                  ? IconButton(
                      icon: Icon(Icons.file_download),
                      onPressed: widget.index < uri.length
                          ? () async {
                              setState(() {
                                _download = 1;
                              });
                              await download(uri[widget.index]);
                            }
                          : null)
                  : IconButton(icon: Icon(Icons.check), onPressed: () {}),
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
            Text('Extracting.. Please wait..'),
            CircularProgressIndicator(),
          ],
        );
        break;
      case 3:
        return RaisedButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
            },
            child: Text('Reload App'));
        break;
      default:
        return Container();
    }
  }
}
