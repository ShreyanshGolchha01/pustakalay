import 'dart:convert';
import 'dart:io';
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
        if (data['success'] == true) {
          return data;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Donor APIs
  Future<User?> searchDonor(String mobileNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.searchDonorEndpoint}'),
        headers: _headers,
        body: jsonEncode({
          'mobile': mobileNumber,
        }),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final donorData = data['data'];
          return User(
            id: donorData['u_id'].toString(),
            name: donorData['u_name'],
            mobileNumber: donorData['u_mobile'],
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> addDonor(String name, String mobile, String librarianId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addDonorEndpoint}'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'mobile': mobile,
          'librarian_id': librarianId,
        }),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          return data; // Return data even if success is false to get error message
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Book APIs
  Future<List<Book>?> searchBooks({String? query, String? librarianId}) async {
    try {
      // Remove librarian_id to get all books from all librarians (unified view)
      String url = '${ApiConstants.baseUrl}${ApiConstants.searchBooksEndpoint}?';
      if (query != null && query.isNotEmpty) {
        url += 'search=${Uri.encodeComponent(query)}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final booksData = data['data'] as List;
          
          final books = booksData.map((bookJson) {
            return Book(
              id: (bookJson['b_id'] ?? bookJson['id'] ?? '').toString(),
              title: bookJson['b_title'] ?? bookJson['title'] ?? '',
              author: bookJson['b_author'] ?? bookJson['author'] ?? '',
              genre: bookJson['b_genre'] ?? bookJson['genre'] ?? '',
              count: int.tryParse((bookJson['b_count'] ?? bookJson['count'] ?? 0).toString()) ?? 0,
            );
          }).toList();
          
          return books;
        } else {
          // API returned success=false
        }
      } else {
        // HTTP Error
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> addBook({
    required String title,
    required String author,
    required String genre,
    required int count,
    required String librarianId,
  }) async {
    try {
      final requestBody = {
        'title': title,
        'author': author,
        'genre': genre,
        'count': count,
        'librarian_id': librarianId,
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addBookEndpoint}'),
        headers: _headers,
        body: jsonEncode(requestBody),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          return data; // Return the response even if success is false so we can handle the error message
        }
      } else {
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Upload Certificate
  Future<Map<String, dynamic>?> uploadCertificate({
    required File certificateFile,
    required String donorId,
    required String librarianId,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadCertificateEndpoint}'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('certificate', certificateFile.path),
      );
      request.fields['donor_id'] = donorId;
      request.fields['librarian_id'] = librarianId;
      
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        
        if (data['success'] == true) {
          return data;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Donation APIs
  Future<Map<String, dynamic>?> addDonation({
    required String donorId,
    required String librarianId,
    required List<Map<String, dynamic>> books, // {book_id, count}
    String? certificatePath,
  }) async {
    try {
      final requestBody = {
        'donor_id': donorId,
        'librarian_id': librarianId,
        'books': books,
      };
      
      if (certificatePath != null) {
        requestBody['certificate_path'] = certificatePath;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addDonationEndpoint}'),
        headers: _headers,
        body: jsonEncode(requestBody),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          return data; // Return data even if success is false to get error message
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Dashboard Stats API
  Future<Map<String, dynamic>?> getDashboardStats({String? librarianId}) async {
    try {
      // Remove librarian_id to get unified stats for all users
      String url = '${ApiConstants.baseUrl}${ApiConstants.dashboardEndpoint}';

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
