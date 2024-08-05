import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String? _username;
  String? _email;
  String? _token;

  String? get username => _username;
  String? get email => _email;
  String? get token => _token;

  void setUser(String username, String email, String token) {
    _username = username;
    _email = email;
    _token = token;
    notifyListeners();
  }

  void clearUser() {
    _username = null;
    _email = null;
    _token = null;
    notifyListeners();
  }
}
