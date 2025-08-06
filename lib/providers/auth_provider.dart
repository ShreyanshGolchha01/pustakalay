import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _librarianEmail = '';
  String _librarianName = '';
  String _librarianId = '';

  bool get isLoggedIn => _isLoggedIn;
  String get librarianEmail => _librarianEmail;
  String get librarianName => _librarianName;
  String? get librarianId => _librarianId.isNotEmpty ? _librarianId : null;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _librarianEmail = prefs.getString('librarianEmail') ?? '';
    _librarianName = prefs.getString('librarianName') ?? '';
    _librarianId = prefs.getString('librarianId') ?? '';
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}';
      // print('Login URL: $url');
      // print('Email: $email');
      // print('Password length: ${password.length}');
      
      // API call to backend
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConstants.requestTimeout);

      // print('Response Status: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final userData = data['data']['user'];
          
          _isLoggedIn = true;
          _librarianEmail = userData['l_email'];
          _librarianName = userData['l_name'];
          _librarianId = userData['l_id'].toString();

          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('librarianEmail', _librarianEmail);
          await prefs.setString('librarianName', _librarianName);
          await prefs.setString('librarianId', _librarianId);

          notifyListeners();
          return true;
        } else {
          // print('Login failed: ${data['message']}');
          return false;
        }
      } else {
        // print('HTTP Error: ${response.statusCode}');
        // print('Error Body: ${response.body}');
        return false;
      }
      
    } catch (e) {
      // print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoggedIn = false;
      _librarianEmail = '';
      _librarianName = '';
      _librarianId = '';

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      notifyListeners();
    } catch (e) {
      // print('Logout error: $e');
    }
  }

  String getWelcomeMessage() {
    if (_librarianName.isNotEmpty) {
      return 'स्वागत है, $_librarianName';
    }
    return 'स्वागत है';
  }
}
