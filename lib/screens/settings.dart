import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/font.dart';
import '../providers/language.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Consumer<FontManager>(builder: (context, manager, _) {
                  return ExpansionTile(
                      title: Center(
                        child: ListTile(
                          title: const Text('Font Size'),
                          trailing: Text(manager.fontSize.round().toString()),
                        ),
                      ),
                      children: [
                        Slider(
                            value: manager.fontSize,
                            min: 5.0,
                            max: 25.0,
                            onChanged: (double val) async {
                              await manager.setFont(val);
                            }),
                      ]);
                }),
                Consumer<LanguageManager>(
                  builder: (context, manager,_) {
                    return ListTile(
                        title: const Text("Language"),
                        trailing: DropdownButton<int>(
                            value: manager.language,
                            items: [
                              DropdownMenuItem(
                                  child: const Text('Nepali'), value: 0),
                              DropdownMenuItem(
                                  child: const Text('English'), value: 1)
                            ],
                            onChanged: (val) async {
                              if (val != null) {
                                await manager.setLanguage(val);
                                // Navigator.of(context).pushNamedAndRemoveUntil(
                                //     '/', (Route<dynamic> route) => false);
                              }
                            }));
                  }
                ),
                InkWell(
                  child: ListTile(
                    title: const Text('Download Audios'),
                  ),
                  onTap: () => Navigator.of(context).pushNamed('/audio'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('/theme');
                  },
                  title: const Text('Change Theme'),
                ),
                ListTile(
                  onTap: () {
                   SharedPreferences.getInstance().then((prefs) {
                      prefs.remove("lang_preference").then((value) => print("removed"));
                   });
                  },
                  title: const Text('Change Font'),
                ),
              ],
            ),
         
    );
  }
}
