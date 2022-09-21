import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../.secrets/secrets.dart' as secrets; // file where sensitive information is stored
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token = '';
  DateTime _expiryDate = DateTime(0);
  String _userId = '';
  Timer _authTimer = Timer(const Duration(), () {});

  final _domain = secrets.domainAuth; //put firebase domain here
  final _apiKey = secrets.apiKey; //put API key here
  final _signupCommand = 'signUp';
  final _loginCommand = 'signInWithPassword';

  Future<void> _authenticate(String command, String email, String password) async {
    final url = Uri.parse('https://$_domain/v1/accounts:$command?key=$_apiKey');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = jsonDecode(response.body);
      if (kDebugMode) {
        print(responseData);
      }
      if (responseData['error'].toString().toLowerCase() != 'null') {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    return await _authenticate(_signupCommand, email, password);
  }

  Future<void> login(String email, String password) async {
    return await _authenticate(_loginCommand, email, password);
  }

  Future<bool> tryAutoLogin() async {
    const key = 'userData';
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(key)) return false;
    final extractedUserData = jsonDecode(prefs.getString(key)!);
    final expiryDate = DateTime.parse(extractedUserData['expiryDate'].toString());
    if (expiryDate.isBefore(DateTime.now())) return false;
    _token = extractedUserData['token'].toString();
    _userId = extractedUserData['userId'].toString();
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();

    return true;
  }

  void logout() async {
    _token = '';
    _userId = '';
    _expiryDate = DateTime(0);
    _authTimer.cancel();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer.isActive) _authTimer.cancel();
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), () => logout());
  }

  String get token {
    return _expiryDate != DateTime(0) && _expiryDate.isAfter(DateTime.now()) && _token.isNotEmpty
        ? _token
        : '';
  }

  bool get isAuth {
    return token.isNotEmpty;
  }

  String get userId {
    return _userId;
  }

}
