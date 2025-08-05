import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String name;
  final String mobileNumber;
  final DateTime createdAt;

  User({
    String? id,
    required this.name,
    required this.mobileNumber,
    DateTime? createdAt,
  }) : id = id ?? Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      mobileNumber: json['mobileNumber'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  factory User.fromApiJson(Map<String, dynamic> json) {
    return User(
      id: json['u_id'].toString(),
      name: json['u_name'],
      mobileNumber: json['u_mobile'],
      createdAt: DateTime.parse(json['u_createdat']),
    );
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String genre;
  final int count;

  Book({
    String? id,
    required this.title,
    required this.author,
    required this.genre,
    required this.count,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'count': count,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: (json['id'] ?? json['b_id'] ?? '').toString(),
      title: json['title'] ?? json['b_title'] ?? '',
      author: json['author'] ?? json['b_author'] ?? '',
      genre: json['genre'] ?? json['b_genre'] ?? '',
      count: int.tryParse((json['count'] ?? json['b_count'] ?? json['b_available_count'] ?? 0).toString()) ?? 0,
    );
  }
}

class Donation {
  final String id;
  final String userId;
  final List<Book> books;
  final String? certificateImagePath;
  final DateTime donationDate;

  Donation({
    String? id,
    required this.userId,
    required this.books,
    this.certificateImagePath,
    DateTime? donationDate,
  }) : id = id ?? Uuid().v4(),
       donationDate = donationDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'books': books.map((book) => book.toJson()).toList(),
      'certificateImagePath': certificateImagePath,
      'donationDate': donationDate.toIso8601String(),
    };
  }

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      userId: json['userId'],
      books: (json['books'] as List).map((book) => Book.fromJson(book)).toList(),
      certificateImagePath: json['certificateImagePath'],
      donationDate: DateTime.parse(json['donationDate']),
    );
  }
}

class LibraryStats {
  final int totalBooks;
  final int totalDonations;
  final int totalDonors;
  final int totalGenres;
  final int totalLibrarians;

  LibraryStats({
    required this.totalBooks,
    required this.totalDonations,
    required this.totalDonors,
    required this.totalGenres,
    required this.totalLibrarians,
  });
}
