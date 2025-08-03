import 'package:shared_preferences/shared_preferences.dart';

class CustomSharedPreferences {
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  Future<bool> logged() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("token")) {
      return true;
    } else {
      return false;
    }
  }
}
