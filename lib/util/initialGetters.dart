import 'package:shared_preferences/shared_preferences.dart';

Future<double> getFont() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('fontSize') ?? 18.0;
  }

Future<int> getLang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lang') ?? 0;
  }