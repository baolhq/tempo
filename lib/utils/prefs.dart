import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static Future<SharedPreferences> loadPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs;
  }
}
