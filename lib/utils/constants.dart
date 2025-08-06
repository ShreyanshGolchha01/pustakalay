// API Constants for Backend Connection
class ApiConstants {
  // Backend URL - PHP Server
  static const String baseUrl = 'http://192.168.1.9/pustakalaya';
  
  // API Endpoints
  static const String loginEndpoint = '/p_login.php';
  static const String searchDonorEndpoint = '/search_donor.php';
  static const String addDonorEndpoint = '/add_donor.php';
  static const String searchBooksEndpoint = '/search_books.php';
  static const String addBookEndpoint = '/add_book.php';
  static const String uploadCertificateEndpoint = '/upload_certificate.php';
  static const String addDonationEndpoint = '/add_donation.php';
  static const String dashboardEndpoint = '/dashboard.php';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 30);
}
