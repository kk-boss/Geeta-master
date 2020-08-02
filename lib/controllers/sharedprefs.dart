import 'package:shared_preferences/shared_preferences.dart';

Future<void> setBookId(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('book', id);
}

Future<void> setChapter(int chapter) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('chapter', chapter);
}

Future<List<int>> getSavedState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return [prefs.getInt('book'), prefs.getInt('chapter')];
}

Future<void> setSavedState(int book, int chapter) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('book', book);
  await prefs.setInt('chapter', chapter);
}

Future<void> setTime(String time) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('time', time);
}

Future<String> getTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('time');
}
