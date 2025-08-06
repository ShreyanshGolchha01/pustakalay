import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../models/app_models.dart';
import '../services/api_service.dart';

class LibraryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<User> _users = [];
  List<Book> _books = [];
  List<Donation> _donations = [];
  
  List<User> get users => _users;
  List<Book> get books => _books;
  List<Donation> get donations => _donations;

  LibraryProvider() {
    // Initialize empty - ready for backend connection
    _loadData();
    _loadBooksFromAPI(); // Load books from backend on startup
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
      // print('Error loading data: $e');
    }
  }

  // Load books from API
  Future<void> _loadBooksFromAPI() async {
    try {
      // print('=== LOADING BOOKS FROM API ===');
      final apiBooks = await _apiService.searchBooks();
      if (apiBooks != null && apiBooks.isNotEmpty) {
        // print('Loaded ${apiBooks.length} books from API');
        _books = apiBooks;
        await _saveData(); // Save to local storage
        notifyListeners();
      } else {
        // print('No books loaded from API');
      }
    } catch (e) {
      // print('Error loading books from API: $e');
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
      // print('Error saving data: $e');
    }
  }

  // User Management
  Future<User?> findUserByMobile(String mobileNumber) async {
    try {
      return await _apiService.searchDonor(mobileNumber);
    } catch (e) {
      // print('Error finding user: $e');
      return null;
    }
  }

  Future<bool> addUser(User user, String librarianId) async {
    try {
      final result = await _apiService.addDonor(
        user.name,
        user.mobileNumber,
        librarianId,
      );
      
      if (result != null && result['success'] == true) {
        _users.add(user);
        await _saveData();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      // print('Error adding user: $e');
      return false;
    }
  }

  // Book Management
  Future<List<Book>?> searchBooks(String query, {String? librarianId}) async {
    try {
      return await _apiService.searchBooks(query: query, librarianId: librarianId);
    } catch (e) {
      // print('Error searching books: $e');
      return null;
    }
  }

  // Local search method for UI (synchronous)
  List<Book> searchBooksLocal(String query) {
    if (query.isEmpty) return _books;
    
    return _books.where((book) =>
      book.title.toLowerCase().contains(query.toLowerCase()) ||
      book.author.toLowerCase().contains(query.toLowerCase()) ||
      book.genre.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<bool> addBook({
    required String title,
    required String author,
    required String genre,
    required int count,
    required String librarianId,
  }) async {
    try {
      // print('=== ADDING BOOK ===');
      // print('Title: $title, Author: $author, Genre: $genre, Count: $count');
      
      final result = await _apiService.addBook(
        title: title,
        author: author,
        genre: genre,
        count: count,
        librarianId: librarianId,
      );
      
      // print('Add book result: $result');
      
      if (result != null && result['success'] == true) {
        // Refresh books from API to get the latest data
        await _loadBooksFromAPI();
        return true;
      } else {
        // print('Failed to add book - API returned: $result');
      }
      return false;
    } catch (e) {
      // print('Error adding book: $e');
      return false;
    }
  }

  List<Book> filterBooksByGenre(String genre) {
    if (genre.isEmpty) return _books;
    return _books.where((book) => book.genre == genre).toList();
  }

  List<String> getUniqueGenres() {
    return _books.map((book) => book.genre).toSet().toList();
  }

  // Certificate Management
  Future<String?> uploadCertificate({
    required File certificateFile,
    required String donorId,
    required String librarianId,
  }) async {
    try {
      final result = await _apiService.uploadCertificate(
        certificateFile: certificateFile,
        donorId: donorId,
        librarianId: librarianId,
      );
      
      if (result != null && result['success'] == true) {
        return result['file_path'];
      }
      return null;
    } catch (e) {
      // print('Error uploading certificate: $e');
      return null;
    }
  }

  // Donation Management
  Future<bool> submitBookDonation({
    required String donorId,
    required String librarianId,
    required List<Map<String, dynamic>> books, // {book_id, count}
    String? certificatePath,
  }) async {
    try {
      final result = await _apiService.addDonation(
        donorId: donorId,
        librarianId: librarianId,
        books: books,
        certificatePath: certificatePath,
      );
      
      if (result != null && result['success'] == true) {
        await _loadBooksFromAPI(); // Refresh books with updated counts
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      // print('Error submitting donation: $e');
      return false;
    }
  }

  Future<void> addDonation(Donation donation) async {
    // Legacy method - keeping for compatibility
    _donations.add(donation);
    await _saveData();
    notifyListeners();
  }

  // Dashboard Statistics
  Future<Map<String, dynamic>?> getDashboardStats({String? librarianId}) async {
    try {
      return await _apiService.getDashboardStats(librarianId: librarianId);
    } catch (e) {
      // print('Error getting dashboard stats: $e');
      return null;
    }
  }

  // Local Statistics (for offline fallback)
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

  // Refresh books from API
  Future<void> refreshBooksFromAPI() async {
    await _loadBooksFromAPI();
  }

  // Refresh all data from API
  Future<void> refreshAllData() async {
    await _loadBooksFromAPI();
    // Add other refresh methods here when needed
  }
}
