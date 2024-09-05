import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String? _membername;
  String? _email;
  String? _token;

  String? get membername => _membername;
  String? get email => _email;
  String? get token => _token;

  void setUser(String membername, String email, String token) {
    _membername = membername;
    _email = email;
    _token = token;
    notifyListeners();
  }

  void clearUser() {
    _membername = null;
    _email = null;
    _token = null;
    notifyListeners();
  }
}
