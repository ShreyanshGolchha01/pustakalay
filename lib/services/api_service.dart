import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/app_models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Authentication token (if using JWT)
  String? _authToken;
  
  void setAuthToken(String? token) {
    _authToken = token;
  }
  
  Map<String, String> get _headers {
    final headers = Map<String, String>.from(ApiConstants.defaultHeaders);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Authentication APIs
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token']; // If your backend returns a token
        return data;
      }
      return null;
    } catch (e) {
      print('Login API Error: $e');
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logoutEndpoint}'),
        headers: _headers,
      ).timeout(ApiConstants.requestTimeout);

      _authToken = null;
      return response.statusCode == 200;
    } catch (e) {
      print('Logout API Error: $e');
      _authToken = null;
      return true; // Consider logout successful even if API fails
    }
  }

  // User APIs
  Future<bool> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersEndpoint}'),
        headers: _headers,
        body: jsonEncode(user.toJson()),
      ).timeout(ApiConstants.requestTimeout);

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Create User API Error: $e');
      return false;
    }
  }

  Future<List<User>?> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersEndpoint}'),
        headers: _headers,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Get Users API Error: $e');
      return null;
    }
  }

  Future<User?> findUserByMobile(String mobileNumber) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersEndpoint}/mobile/$mobileNumber'),
        headers: _headers,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Find User API Error: $e');
      return null;
    }
  }

  // Book APIs
  Future<bool> createBooks(List<Book> books) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.booksEndpoint}/bulk'),
        headers: _headers,
        body: jsonEncode(books.map((book) => book.toJson()).toList()),
      ).timeout(ApiConstants.requestTimeout);

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Create Books API Error: $e');
      return false;
    }
  }

  Future<List<Book>?> getBooks() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.booksEndpoint}'),
        headers: _headers,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Book.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Get Books API Error: $e');
      return null;
    }
  }

  Future<List<Book>?> searchBooks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.booksEndpoint}/search?q=$query'),
        headers: _headers,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Book.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Search Books API Error: $e');
      return null;
    }
  }

  // Donation APIs
  Future<bool> createDonation(Donation donation) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.donationsEndpoint}'),
        headers: _headers,
        body: jsonEncode(donation.toJson()),
      ).timeout(ApiConstants.requestTimeout);

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Create Donation API Error: $e');
      return false;
    }
  }

  Future<List<Donation>?> getDonations() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.donationsEndpoint}'),
        headers: _headers,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Donation.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Get Donations API Error: $e');
      return null;
    }
  }

  // Stats API
  Future<LibraryStats?> getLibraryStats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.statsEndpoint}'),
        headers: _headers,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LibraryStats(
          totalBooks: data['totalBooks'] ?? 0,
          totalDonations: data['totalDonations'] ?? 0,
          totalDonors: data['totalDonors'] ?? 0,
          totalGenres: data['totalGenres'] ?? 0,
          totalLibrarians: data['totalLibrarians'] ?? 0,
        );
      }
      return null;
    } catch (e) {
      print('Get Stats API Error: $e');
      return null;
    }
  }
}
