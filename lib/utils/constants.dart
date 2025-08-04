// API Constants for Backend Connection
class ApiConstants {
  // Backend URL - PHP Server
  static const String baseUrl = 'http://localhost/pustakalaya';
  
  // API Endpoints
  static const String loginEndpoint = '/api/login.php';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String usersEndpoint = '/api/users';
  static const String booksEndpoint = '/api/books';
  static const String donationsEndpoint = '/api/donations';
  static const String statsEndpoint = '/api/stats';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 30);
}
