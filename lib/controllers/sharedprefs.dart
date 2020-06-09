import 'package:shared_preferences/shared_preferences.dart';

Future<double> getFont() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('fontSize') ?? 18.0;
}

Future<int> getLang() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('lang') ?? 0;
}

Future<void> setFont(double fontSize) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('fontSize', fontSize);
}

Future<void> setLang(int lang) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('lang', lang);
}

Future<void> setBookId(int id)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('book', id);
}
Future<void> setChapter(int chapter)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('chapter', chapter);
}
Future<List<int>> getSavedState()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return [prefs.getInt('book'),prefs.getInt('chapter')];
}
