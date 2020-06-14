import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager with ChangeNotifier {
    int _language;
  final _kLangPreference = "lang_preference";

  LanguageManager(){
    _loadLanguage();
  }
  void _loadLanguage(){
    SharedPreferences.getInstance().then((prefs){
      int preferredLang = prefs.getInt(_kLangPreference)??0;
      _language = preferredLang;
      notifyListeners();
    });
  }
  
  int get language{
    if(_language == null){
      _language = 0;
    }
    return _language;
  }
  Future<void> setLanguage(int lang)async{
    _language = lang;
    notifyListeners();
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(_kLangPreference,lang);
  }

}