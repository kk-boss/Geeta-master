import 'package:flutter/material.dart';
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

  Future<void> setChapter(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('chapter$id', 1);
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
                              Scaffold.of(ctx).showSnackBar(SnackBar(
                                      content: const Text('Saved'),
                                    ));
                              Navigator.of(context).pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
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
                // TextField(
                //  textInputAction: TextInputAction.done,
                //  onSubmitted: (txt){
                //    print(txt);
                //  },
                // ),
                InkWell(
                  child: ListTile(
                    title: Text('Download Audios'),
                  ),
                  onTap: ()=>Navigator.of(context).pushNamed('/audio'),
                ),
              ],
            );
          }),
    );
  }
}
