# Pustakalaya - Library Management System
## पुस्तकालय - लाइब्रेरी प्रबंधन प्रणाली

A professional Flutter application designed for government libraries to manage book donations and track library statistics.

## Features / विशेषताएं

### 🔐 Authentication / प्रमाणीकरण
- Secure librarian login with email and password
- Session management for persistent login
- Professional splash screen with government branding

### 📊 Dashboard / डैशबोर्ड
- Real-time library statistics display
- Total books, donations, donors, and genre counts
- Welcome message with librarian name
- Quick action buttons for common tasks

### 📚 Book Management / पुस्तक प्रबंधन
- View all donated books with search functionality
- Filter books by genre categories
- Book details including title, author, genre, and count
- Responsive card-based layout

### 👤 User Management / उपयोगकर्ता प्रबंधन
- Add new donors or search existing donors by mobile number
- Store donor information (name and mobile number)
- User profile management

### 📖 Book Donation Process / पुस्तक दान प्रक्रिया
1. Select new or existing user
2. Enter user details (for new users)
3. Add multiple books with details:
   - Title (शीर्षक)
   - Author (लेखक)
   - Genre (विषय श्रेणी)
   - Count (प्रतियों की संख्या)
4. Upload certificate photo
5. Submit donation

### 🖼️ Certificate Upload / प्रमाणपत्र अपलोड
- Photo capture or gallery selection
- Image preview before submission
- Secure storage of certificate images

## Design Features / डिज़ाइन विशेषताएं

### 🎨 Blue Gradient Theme
- Professional government-appropriate color scheme
- Blue gradient backgrounds (Dark Blue → Light Blue)
- Consistent Material Design implementation

### 📱 Responsive Design
- Optimized for various screen sizes
- Touch-friendly interface elements
- Smooth animations and transitions

### 🌐 Bilingual Support
- Hindi and English text labels
- Cultural appropriate design elements
- Government of India branding

## Technical Stack / तकनीकी स्टैक

- **Framework**: Flutter 3.8+
- **State Management**: Provider pattern
- **Local Storage**: SharedPreferences
- **Image Handling**: image_picker
- **UI Components**: Material Design 3

## Demo Credentials / डेमो क्रेडेंशियल्स

### Librarian Accounts:
1. **Email**: librarian@govt.in  
   **Password**: library123  
   **Name**: राज कुमार शर्मा

2. **Email**: admin@pustakalaya.gov.in  
   **Password**: admin123  
   **Name**: सुनीता वर्मा

3. **Email**: library.officer@india.gov.in  
   **Password**: officer123  
   **Name**: अमित सिंह

## Installation / स्थापना

### Prerequisites / आवश्यकताएं
- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Setup Steps / सेटअप चरण

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the application**:
   ```bash
   flutter run
   ```

## Project Structure / परियोजना संरचना

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── app_models.dart      # Data models
├── providers/
│   ├── auth_provider.dart   # Authentication logic
│   └── library_provider.dart # Library data management
├── screens/
│   ├── login_screen.dart    # Login interface
│   ├── dashboard_screen.dart # Main dashboard
│   ├── books_list_screen.dart # Books listing
│   └── add_book_screen.dart # Book donation form
└── utils/
    └── app_theme.dart       # App theming
```

---

**Developed for Government of India Libraries**  
**भारत सरकार की लाइब्रेरीज़ के लिए विकसित**

© 2025 Pustakalaya Library Management System
