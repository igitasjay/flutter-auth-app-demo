import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseProvider extends ChangeNotifier {
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();

  String _token = '';
  final String _userId = '';

  String get token => _token;
  String get userId => _userId;

  void saveToken(String token) async {
    SharedPreferences value = await _pref;

    value.setString('token', token);
  }

  void saveUserId(String id) async {
    SharedPreferences value = await _pref;

    value.setString('id', id);
  }

  Future<String> getToken() async {
    SharedPreferences value = await _pref;
    if (value.containsKey('token')) {
      String data = value.getString('token')!;
      _token = data;
      notifyListeners();
      return data;
    } else {
      _token = '';
      notifyListeners();
      return '';
    }
  }

  void logOut(BuildContext context) async {
    final value = await _pref;
    value.clear();
    // PageNavigator(context: context).nextPageOnly(
    //   page: const LoginOrRegister(),
    // );
  }
}
