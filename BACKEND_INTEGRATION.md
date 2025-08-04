# 🎯 Backend Integration Guide

आपका Flutter app अब backend connection के लिए तैयार है! सभी mock data हटा दिया गया है।

## 🛠️ What's Ready for Backend

### 1. **Clean Providers**
- `AuthProvider`: Demo credentials removed, API-ready comments added
- `LibraryProvider`: Mock data removed, API placeholder comments added

### 2. **API Service Layer**
- `lib/services/api_service.dart`: Complete API service class
- `lib/utils/constants.dart`: API endpoints और configuration

### 3. **Database Schema**
पहले बताया गया complete database schema ready है।

## 🔧 Backend Connection Steps

### Step 1: Update API Base URL
```dart
// lib/utils/constants.dart में update करें
static const String baseUrl = 'YOUR_BACKEND_URL'; // e.g., 'https://api.pustakalaya.com'
```

### Step 2: Provider Methods को API से Connect करें

#### Auth Provider:
```dart
// lib/providers/auth_provider.dart
Future<bool> login(String email, String password) async {
  final apiService = ApiService();
  final result = await apiService.login(email, password);
  
  if (result != null) {
    _isLoggedIn = true;
    _librarianEmail = result['email'];
    _librarianName = result['name'];
    // Save to SharedPreferences...
    return true;
  }
  return false;
}
```

#### Library Provider:
```dart
// lib/providers/library_provider.dart में uncomment करें
Future<void> addUser(User user) async {
  final apiService = ApiService();
  final success = await apiService.createUser(user);
  
  if (success) {
    _users.add(user);
    notifyListeners();
  }
}
```

### Step 3: Data Loading Methods Add करें

```dart
// Library Provider में add करें
Future<void> loadBooksFromAPI() async {
  final apiService = ApiService();
  final books = await apiService.getBooks();
  
  if (books != null) {
    _books = books;
    notifyListeners();
  }
}

Future<void> loadUsersFromAPI() async {
  final apiService = ApiService();
  final users = await apiService.getUsers();
  
  if (users != null) {
    _users = users;
    notifyListeners();
  }
}
```

## 📋 Required Backend Endpoints

### Authentication
- `POST /api/auth/login` - Login
- `POST /api/auth/logout` - Logout

### Users
- `GET /api/users` - Get all users
- `POST /api/users` - Create new user
- `GET /api/users/mobile/{mobile}` - Find user by mobile

### Books
- `GET /api/books` - Get all books
- `POST /api/books/bulk` - Create multiple books
- `GET /api/books/search?q={query}` - Search books

### Donations
- `GET /api/donations` - Get all donations
- `POST /api/donations` - Create donation

### Stats
- `GET /api/stats` - Get dashboard statistics

## 🔐 Authentication

यदि आपका backend JWT tokens use करता है:

```dart
// Login के बाद token save करें
final apiService = ApiService();
await apiService.login(email, password);
// Token automatically ApiService में save हो जाएगा
```

## 📱 File Upload (Certificate Images)

Certificate images के लिए multipart upload add करना होगा:

```dart
Future<String?> uploadCertificateImage(File imageFile) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/api/upload/certificate'),
    );
    
    request.files.add(
      await http.MultipartFile.fromPath('certificate', imageFile.path),
    );
    
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);
      return data['filePath']; // Backend से returned file path
    }
  } catch (e) {
    print('Upload error: $e');
  }
  return null;
}
```

## ✅ Testing Without Backend

अभी के लिए temporary mode में app run होगा:
- Login: कोई भी email/password accept करेगा
- Data: Local storage में save होगा
- सब functionality काम करेगी

## 🚀 Production Ready Features

- Error handling ✅
- Loading states ✅  
- API timeout ✅
- Token management ✅
- Local storage fallback ✅

Backend ready होने पर बस API calls uncomment करके base URL update करना है!
