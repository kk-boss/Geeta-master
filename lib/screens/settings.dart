import 'package:flutter/material.dart';

import '../controllers/sharedprefs.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<double> _fontSize;
  Future<int> _lang;
  double _value;
  int _val;
  @override
  void initState() {
    super.initState();
    _fontSize = getFont().then((value) => _value=value);
    _lang = getLang().then((value) => _val = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text(
          'Settings',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder(
          future: Future.wait([_fontSize, _lang]),
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
                        title: const Text('Font Size'),
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
                            await setFont(_value).then((_) => {
                               Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false)
                            });
                          },
                          child: const Text('Save')),
                    ]),
                Center(
                  child: ListTile(
                      title: const Text("Language"),
                      trailing: DropdownButton<int>(
                          value: _val,
                          items: [
                            DropdownMenuItem(child: const Text('Nepali'), value: 0),
                            DropdownMenuItem(child: const Text('English'), value: 1)
                          ],
                          onChanged: (val) async {
                            if (val != null) {
                             await setLang(val);
                            Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
                            }
                          })),
                ),
                InkWell(
                  child: ListTile(
                    title: const Text('Download Audios'),
                  ),
                  onTap: ()=>Navigator.of(context).pushNamed('/audio'),
                ),
              ],
            );
          }),
    );
  }
}
