// API Constants for Backend Connection
class ApiConstants {
  // Backend URL - PHP Server
  static const String baseUrl = 'http://192.168.1.9/pustakalaya';
  
  // API Endpoints
  static const String loginEndpoint = '/p_login.php';
  static const String searchUserEndpoint = '/p_search_user.php';
  static const String addBooksEndpoint = '/p_add_books.php';
  static const String uploadCertificateEndpoint = '/p_upload_certificate.php';
  static const String logoutEndpoint = '/p_logout.php';
  static const String usersEndpoint = '/p_users.php';
  static const String booksEndpoint = '/p_books.php';
  static const String donationsEndpoint = '/p_donations.php';
  static const String statsEndpoint = '/p_stats.php';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 30);
}
