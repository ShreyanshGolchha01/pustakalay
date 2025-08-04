import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_models.dart';

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
  User? findUserByMobile(String mobileNumber) {
    try {
      return _users.firstWhere((user) => user.mobileNumber == mobileNumber);
    } catch (e) {
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
  Future<void> addDonation(Donation donation) async {
    // TODO: Replace with actual API call
    // final response = await http.post(
    //   Uri.parse('${baseUrl}/api/donations'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(donation.toJson()),
    // );
    
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
