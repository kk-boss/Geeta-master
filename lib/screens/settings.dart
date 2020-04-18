import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<double> fontSize;
  Future<int> lang;
  double _value;
  int _val;
  @override
  void initState() {
    super.initState();
    fontSize = getFont();
    lang = getLang();
  }

  Future<double> getFont() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _value = prefs.getDouble('fontSize') ?? 18.0;
    return _value;
  }

  Future<int> getLang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _val = prefs.getInt('lang') ?? 0;
    return _val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder(
          future: Future.wait([fontSize, lang]),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ExpansionTile(
                    title: Center(
                      child: ListTile(
                        title: Text('Font Size'),
                        trailing: Text(_value.round().toString()),
                      ),
                    ),
                    children: [
                      Slider(
                          value: _value,
                          min: 5.0,
                          max: 25.0,
                          onChanged: (double val) async {
                            setState(() {
                              _value = val;
                            });
                          }),
                      RaisedButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs
                                .setDouble('fontSize', _value)
                                .then((res) {
                              res
                                  ? Scaffold.of(ctx).showSnackBar(SnackBar(
                                      content: const Text('Saved'),
                                    ))
                                  : Scaffold.of(ctx).showSnackBar(SnackBar(
                                      content: const Text('Failed'),
                                    ));
                            });
                          },
                          child: Text('Save')),
                    ]),
                Center(
                  child: ListTile(
                      title: Text("Language"),
                      trailing: DropdownButton<int>(
                          value: _val,
                          items: [
                            DropdownMenuItem(child: Text('Nepali'), value: 0),
                            DropdownMenuItem(child: Text('English'), value: 1)
                          ],
                          onChanged: (val) async {
                            if (val != null) {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setInt('lang', val);
                              setState(() {
                                Scaffold.of(ctx).showSnackBar(SnackBar(
                                    content:
                                        Text('Restart app to change effect')));
                                _val = val;
                              });
                            }
                          })),
                ),
                RaisedButton(
                  onPressed: () async {
                    var httpClient = http.Client();
                    var request = http.Request('GET',Uri.parse('https://firebasestorage.googleapis.com/v0/b/dart-kk.appspot.com/o/assets.zip?alt=media&token=a9399e39-0d0a-48dd-b242-a50a29c32b3d'));
                    var response = httpClient.send(request);
                    String dir = (await getApplicationDocumentsDirectory()).path;
                    List<List<int>> chunks = new List(); 
                    int downloaded = 0;
                    response.asStream().listen((http.StreamedResponse r){
                      r.stream.listen((List<int> chunk){
                        print('per: ${downloaded/r.contentLength * 100}');
                        chunks.add(chunk);
                        downloaded += chunk.length;
                      },
                      onDone: ()async{
                        print('per: ${downloaded/r.contentLength * 100}');
                        File file = new File('$dir/ok.zip');
                        final Uint8List bytes = Uint8List(r.contentLength);
                        int offset = 0;
                        for (List<int> chunk in chunks) {
                          bytes.setRange(offset, offset + chunk.length, chunk);
                          offset += chunk.length;
                        }
                        await file.writeAsBytes(bytes);
                        return;
                      });
                    });
                  },
                  child: Text('Download'),
                ),
              ],
            );
          }),
    );
  }
}
