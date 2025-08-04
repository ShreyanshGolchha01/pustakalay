import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/app_models.dart';
import '../utils/constants.dart';

class LibraryProvider with ChangeNotifier {
  List<User> _users = [];
  List<Book> _books = [];
  List<Donation> _donations = [];
  
  List<User> get users => _users;
  List<Book> get books => _books;
  List<Donation> get donations => _donations;

  LibraryProvider() {
    // Initialize empty - ready for backend connection
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load users
      final usersJson = prefs.getString('users');
      if (usersJson != null) {
        final List<dynamic> usersList = jsonDecode(usersJson);
        _users = usersList.map((json) => User.fromJson(json)).toList();
      }

      // Load books
      final booksJson = prefs.getString('books');
      if (booksJson != null) {
        final List<dynamic> booksList = jsonDecode(booksJson);
        _books = booksList.map((json) => Book.fromJson(json)).toList();
      }

      // Load donations
      final donationsJson = prefs.getString('donations');
      if (donationsJson != null) {
        final List<dynamic> donationsList = jsonDecode(donationsJson);
        _donations = donationsList.map((json) => Donation.fromJson(json)).toList();
      }

      notifyListeners();
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save users
      await prefs.setString('users', 
        jsonEncode(_users.map((user) => user.toJson()).toList()));
      
      // Save books
      await prefs.setString('books', 
        jsonEncode(_books.map((book) => book.toJson()).toList()));
      
      // Save donations
      await prefs.setString('donations', 
        jsonEncode(_donations.map((donation) => donation.toJson()).toList()));
        
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  // User Management
  Future<User?> findUserByMobile(String mobileNumber) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.searchUserEndpoint}?mobile=$mobileNumber'),
        headers: ApiConstants.defaultHeaders,
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return User.fromApiJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error finding user: $e');
      return null;
    }
  }

  Future<void> addUser(User user) async {
    // TODO: Replace with actual API call
    // final response = await http.post(
    //   Uri.parse('${baseUrl}/api/users'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(user.toJson()),
    // );
    
    _users.add(user);
    await _saveData();
    notifyListeners();
  }

  // Book Management
  Future<void> addBooks(List<Book> newBooks) async {
    // TODO: Replace with actual API call
    // final response = await http.post(
    //   Uri.parse('${baseUrl}/api/books/bulk'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(newBooks.map((book) => book.toJson()).toList()),
    // );
    
    _books.addAll(newBooks);
    await _saveData();
    notifyListeners();
  }

  List<Book> searchBooks(String query) {
    if (query.isEmpty) return _books;
    
    return _books.where((book) =>
      book.title.toLowerCase().contains(query.toLowerCase()) ||
      book.author.toLowerCase().contains(query.toLowerCase()) ||
      book.genre.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<Book> filterBooksByGenre(String genre) {
    if (genre.isEmpty) return _books;
    return _books.where((book) => book.genre == genre).toList();
  }

  List<String> getUniqueGenres() {
    return _books.map((book) => book.genre).toSet().toList();
  }

  // Donation Management
  Future<bool> submitBookDonation({
    required bool isNewUser,
    required Map<String, dynamic> userData,
    required List<Book> books,
    String? certificatePath,
    required String librarianId,
  }) async {
    try {
      String? uploadedCertPath;
      
      // Upload certificate if provided
      if (certificatePath != null) {
        uploadedCertPath = await _uploadCertificate(File(certificatePath));
        if (uploadedCertPath == null) {
          print('Failed to upload certificate');
          return false;
        }
      }

      // Prepare request data
      final requestData = {
        'librarian_id': librarianId,
        'user_data': userData,
        'books': books.map((book) => {
          'title': book.title,
          'author': book.author,
          'genre': book.genre,
          'isbn': book.isbn,
          'count': book.count,
        }).toList(),
        'is_new_user': isNewUser,
        'certificate_path': uploadedCertPath,
      };

      // Submit to backend
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addBooksEndpoint}'),
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode(requestData),
      ).timeout(ApiConstants.requestTimeout);

      print('Submission response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Update local data
          _books.addAll(books);
          await _saveData();
          notifyListeners();
          return true;
        } else {
          print('Submission failed: ${data['message']}');
          return false;
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Submission error: $e');
      return false;
    }
  }

  Future<String?> _uploadCertificate(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadCertificateEndpoint}'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('certificate', imageFile.path),
      );
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        if (data['success'] == true) {
          return data['data']['file_path'];
        }
      }
    } catch (e) {
      print('Upload error: $e');
    }
    return null;
  }

  Future<void> addDonation(Donation donation) async {
    // Legacy method - keeping for compatibility
    _donations.add(donation);
    await _saveData();
    notifyListeners();
  }

  // Statistics
  LibraryStats getLibraryStats() {
    final totalBooks = _books.fold<int>(0, (sum, book) => sum + book.count);
    final totalDonations = _donations.length;
    final totalDonors = _users.length;
    final totalGenres = getUniqueGenres().length;
    final totalLibrarians = 3; // Static for demo

    return LibraryStats(
      totalBooks: totalBooks,
      totalDonations: totalDonations,
      totalDonors: totalDonors,
      totalGenres: totalGenres,
      totalLibrarians: totalLibrarians,
    );
  }

  List<Book> getRecentBooks({int limit = 4}) {
    // For demo, return first few books
    return _books.take(limit).toList();
  }

  User? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  List<Donation> getRecentDonations({int limit = 5}) {
    final sortedDonations = List<Donation>.from(_donations);
    sortedDonations.sort((a, b) => b.donationDate.compareTo(a.donationDate));
    return sortedDonations.take(limit).toList();
  }
}
