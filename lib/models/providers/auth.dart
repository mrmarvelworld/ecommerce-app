import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token = '';
  late DateTime? _expiryDate;
  late String _userId;
  late Timer? _authTimer;

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.https("identitytoolkit.googleapis.com",
        '/v1/accounts:$urlSegment', {'key': '<GOOGLE API KEY>'});
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      final dataStore = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate?.toIso8601String(),
      });
      dataStore.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  void logout() async {
    _token = '';
    _userId = '';
    _expiryDate = null;
    _cancelTimer();
    final dataStore = await SharedPreferences.getInstance();

    notifyListeners();
    dataStore.clear();
  }

  void _autoLogout() {
    if (_expiryDate != null) {
      final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
      _authTimer = Timer(
        Duration(seconds: timeToExpiry),
        logout,
      );
    }
  }

  Future<bool> tryAutoLogin() async {
    final dataStore = await SharedPreferences.getInstance();
    if (!dataStore.containsKey('userData')) {
      return false;
    }

    final extractedUserData =
        json.decode(dataStore.getString('userData') as String)
            as Map<String, dynamic>;

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      logout();
      return false;
    }

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;

    _autoLogout();
    notifyListeners();

    return true;
  }

  void _cancelTimer() {
    _authTimer?.cancel();
    _authTimer = null;
  }

  bool get isAuth {
    return _token != '';
  }

  String get token {
    return isAuth ? _token : '';
  }

  String get userId {
    return _userId;
  }
}
