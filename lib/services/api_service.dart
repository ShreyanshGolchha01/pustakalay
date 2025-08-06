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
      print('Login API Error: $e');
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
      print('Search Donor API Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> addDonor(String name, String mobile, String librarianId) async {
    try {
      print('=== ADD DONOR API ===');
      print('URL: ${ApiConstants.baseUrl}${ApiConstants.addDonorEndpoint}');
      print('Request body: ${jsonEncode({
        'name': name,
        'mobile': mobile,
        'librarian_id': librarianId,
      })}');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addDonorEndpoint}'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'mobile': mobile,
          'librarian_id': librarianId,
        }),
      ).timeout(ApiConstants.requestTimeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed response data: $data');
        if (data['success'] == true) {
          return data;
        } else {
          print('API returned success=false: ${data['message']}');
          return data; // Return data even if success is false to get error message
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Add Donor API Error: $e');
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

      print('=== SEARCH BOOKS API (UNIFIED) ===');
      print('URL: $url');
      print('Headers: $_headers');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(ApiConstants.requestTimeout);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final booksData = data['data'] as List;
          print('Books found: ${booksData.length}');
          
          final books = booksData.map((bookJson) {
            print('Processing book: $bookJson');
            return Book(
              id: (bookJson['b_id'] ?? bookJson['id'] ?? '').toString(),
              title: bookJson['b_title'] ?? bookJson['title'] ?? '',
              author: bookJson['b_author'] ?? bookJson['author'] ?? '',
              genre: bookJson['b_genre'] ?? bookJson['genre'] ?? '',
              count: int.tryParse((bookJson['b_count'] ?? bookJson['count'] ?? 0).toString()) ?? 0,
            );
          }).toList();
          
          print('Parsed books: ${books.length}');
          return books;
        } else {
          print('API returned success=false: ${data['message']}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Error Response: ${response.body}');
      }
      return null;
    } catch (e) {
      print('Search Books API Error: $e');
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

      print('=== ADD BOOK API ===');
      print('URL: ${ApiConstants.baseUrl}${ApiConstants.addBookEndpoint}');
      print('Headers: $_headers');
      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addBookEndpoint}'),
        headers: _headers,
        body: jsonEncode(requestBody),
      ).timeout(ApiConstants.requestTimeout);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed response data: $data');
        if (data['success'] == true) {
          print('Book added successfully');
          print('Response data: ${data['data']}');
          print('Book ID from response: ${data['data']?['b_id'] ?? data['b_id']}');
          return data;
        } else {
          print('API returned success=false: ${data['message']}');
          return data; // Return the response even if success is false so we can handle the error message
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Error Response: ${response.body}');
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Add Book API Error: $e');
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
      print('=== UPLOAD CERTIFICATE API ===');
      print('File path: ${certificateFile.path}');
      print('Donor ID: $donorId');
      print('Librarian ID: $librarianId');
      print('URL: ${ApiConstants.baseUrl}${ApiConstants.uploadCertificateEndpoint}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadCertificateEndpoint}'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('certificate', certificateFile.path),
      );
      request.fields['donor_id'] = donorId;
      request.fields['librarian_id'] = librarianId;
      
      print('Request fields: ${request.fields}');
      print('Request files: ${request.files.length}');
      
      final response = await request.send();
      print('Upload response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        print('Upload response data: $responseData');
        
        final data = jsonDecode(responseData);
        print('Parsed upload data: $data');
        
        if (data['success'] == true) {
          print('Certificate uploaded successfully');
          print('Response data structure: ${data['data']}');
          return data;
        } else {
          print('Upload failed: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        final responseData = await response.stream.bytesToString();
        print('Error response: $responseData');
      }
      return null;
    } catch (e) {
      print('Upload Certificate API Error: $e');
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

      print('=== ADD DONATION API ===');
      print('URL: ${ApiConstants.baseUrl}${ApiConstants.addDonationEndpoint}');
      print('Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addDonationEndpoint}'),
        headers: _headers,
        body: jsonEncode(requestBody),
      ).timeout(ApiConstants.requestTimeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed response data: $data');
        if (data['success'] == true) {
          return data;
        } else {
          print('API returned success=false: ${data['message']}');
          return data; // Return data even if success is false to get error message
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Add Donation API Error: $e');
      return null;
    }
  }

  // Dashboard Stats API
  Future<Map<String, dynamic>?> getDashboardStats({String? librarianId}) async {
    try {
      // Remove librarian_id to get unified stats for all users
      String url = '${ApiConstants.baseUrl}${ApiConstants.dashboardEndpoint}';

      print('=== DASHBOARD STATS API (UNIFIED) ===');
      print('URL: $url');
      print('Headers: $_headers');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(ApiConstants.requestTimeout);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed Response: $data');
        if (data['success'] == true) {
          print('Dashboard stats data keys: ${data['data']?.keys}');
          print('total_donors value: ${data['data']?['total_donors']}');
          print('total_donations value: ${data['data']?['total_donations']}');
          print('total_books value: ${data['data']?['total_books']}');
          print('total_copies value: ${data['data']?['total_copies']}');
          return data['data'];
        } else {
          print('API returned success=false: ${data['message']}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      print('Dashboard Stats API Error: $e');
      return null;
    }
  }
}
