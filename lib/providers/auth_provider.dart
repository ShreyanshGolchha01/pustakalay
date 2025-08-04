import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _librarianEmail = '';
  String _librarianName = '';

  bool get isLoggedIn => _isLoggedIn;
  String get librarianEmail => _librarianEmail;
  String get librarianName => _librarianName;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _librarianEmail = prefs.getString('librarianEmail') ?? '';
    _librarianName = prefs.getString('librarianName') ?? '';
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      // TODO: Replace with actual API call to backend
      // Example:
      // final response = await http.post(
      //   Uri.parse('${baseUrl}/api/auth/login'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'email': email, 'password': password}),
      // );
      
      // For now, simulate API delay
      await Future.delayed(Duration(seconds: 1));

      // TODO: Replace this with actual backend response validation
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   _isLoggedIn = true;
      //   _librarianEmail = data['email'];
      //   _librarianName = data['name'];
      
      // Temporary - remove when backend is connected
      _isLoggedIn = true;
      _librarianEmail = email.toLowerCase();
      _librarianName = 'लाइब्रेरियन';

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('librarianEmail', _librarianEmail);
      await prefs.setString('librarianName', _librarianName);

      notifyListeners();
      return true;
      
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoggedIn = false;
      _librarianEmail = '';
      _librarianName = '';

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  String getWelcomeMessage() {
    if (_librarianName.isNotEmpty) {
      return 'स्वागत है, $_librarianName';
    }
    return 'स्वागत है';
  }
}
