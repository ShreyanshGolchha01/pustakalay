# Pustakalaya API Documentation

## Base URL
```
http://localhost/pustakalaya/backend/api/
```

## API Endpoints

### 1. Login Authentication
**Endpoint:** `login.php`  
**Method:** POST  
**Description:** Authenticate librarian/admin  

**Request Body:**
```json
{
    "email": "librarian@library.gov.in",
    "password": "password123"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "l_id": 1,
        "l_name": "Test Librarian",
        "l_email": "librarian@library.gov.in",
        "l_role": "librarian"
    }
}
```

### 2. Search Donor
**Endpoint:** `search_donor.php`  
**Method:** POST  
**Description:** Search for existing donor by mobile number  

**Request Body:**
```json
{
    "mobile": "9876543210"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Donor found",
    "data": {
        "u_id": 1,
        "u_name": "राम शर्मा",
        "u_mobile": "9876543210"
    }
}
```

### 3. Add New Donor
**Endpoint:** `add_donor.php`  
**Method:** POST  
**Description:** Add new donor to the system  

**Request Body:**
```json
{
    "name": "नया दानकर्ता",
    "mobile": "9876543213",
    "librarian_id": 1
}
```

**Response:**
```json
{
    "success": true,
    "message": "Donor added successfully",
    "data": {
        "donor_id": 4,
        "name": "नया दानकर्ता",
        "mobile": "9876543213"
    }
}
```

### 4. Search Books
**Endpoint:** `search_books.php`  
**Method:** GET  
**Description:** Search for books in the library  

**Query Parameters:**
- `search` (optional): Search term for title or author
- `librarian_id` (optional): Filter by librarian

**Example URL:**
```
search_books.php?search=गीता&librarian_id=1
```

**Response:**
```json
{
    "success": true,
    "message": "Books retrieved successfully",
    "data": [
        {
            "b_id": 1,
            "b_title": "गीता",
            "b_author": "व्यास",
            "b_genre": "धर्म",
            "b_count": 5
        }
    ]
}
```

### 5. Add New Book
**Endpoint:** `add_book.php`  
**Method:** POST  
**Description:** Add new book or update existing book count  

**Request Body:**
```json
{
    "title": "नई पुस्तक",
    "author": "नया लेखक",
    "genre": "साहित्य",
    "count": 2,
    "librarian_id": 1
}
```

**Response:**
```json
{
    "success": true,
    "message": "Book added successfully",
    "data": {
        "book_id": 6,
        "title": "नई पुस्तक",
        "author": "नया लेखक",
        "genre": "साहित्य",
        "count": 2
    }
}
```

### 6. Upload Certificate
**Endpoint:** `upload_certificate.php`  
**Method:** POST  
**Description:** Upload donation certificate image  

**Request (Multipart Form Data):**
- `certificate` (file): Image file (JPEG/PNG, max 5MB)
- `donor_id` (string): Donor ID
- `librarian_id` (string): Librarian ID

**Response:**
```json
{
    "success": true,
    "message": "Certificate uploaded successfully",
    "data": {
        "file_id": 1,
        "file_path": "cert_1_1641234567.jpg",
        "full_path": "../uploads/certificates/cert_1_1641234567.jpg"
    }
}
```

### 7. Add Donation
**Endpoint:** `add_donation.php`  
**Method:** POST  
**Description:** Record book donation with multiple books  

**Request Body:**
```json
{
    "donor_id": 1,
    "librarian_id": 1,
    "books": [
        {
            "book_id": 1,
            "count": 2
        },
        {
            "book_id": 2,
            "count": 1
        }
    ],
    "certificate_path": "cert_1_1641234567.jpg"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Donation recorded successfully",
    "data": {
        "donor_id": 1,
        "books_count": 2,
        "total_copies": 3
    }
}
```

### 8. Dashboard Statistics
**Endpoint:** `dashboard.php`  
**Method:** GET  
**Description:** Get dashboard statistics and recent donations  

**Query Parameters:**
- `librarian_id` (optional): Filter by librarian

**Example URL:**
```
dashboard.php?librarian_id=1
```

**Response:**
```json
{
    "success": true,
    "message": "Dashboard statistics retrieved successfully",
    "data": {
        "total_donors": 3,
        "total_books": 5,
        "total_copies": 16,
        "total_donations": 4,
        "total_donated_copies": 6,
        "recent_donations": [
            {
                "d_id": 4,
                "d_count": 2,
                "d_createdat": "2024-01-01 12:00:00",
                "u_name": "गीता पटेल",
                "u_mobile": "9876543212",
                "b_title": "गोदान",
                "b_author": "मुंशी प्रेमचंद"
            }
        ],
        "monthly_donations": [
            {
                "month": "2024-01",
                "donations_count": 4,
                "copies_count": 6
            }
        ]
    }
}
```

## Error Responses

All APIs return consistent error format:
```json
{
    "success": false,
    "message": "Error description"
}
```

## Database Schema Summary

### Tables:
1. **login** - Librarian/Admin authentication
2. **donors** - Book donors information  
3. **books** - Books catalog
4. **donations** - Donation records
5. **files** - Certificate file paths

### Key Features:
- Foreign key relationships maintained
- Automatic timestamps
- Transaction support for donations
- File upload handling
- Search functionality
- Dashboard statistics

## Usage Notes:
1. All endpoints return JSON responses
2. File uploads use multipart/form-data
3. Database transactions ensure data consistency
4. Proper error handling and validation
5. Support for Hindi/English text content
