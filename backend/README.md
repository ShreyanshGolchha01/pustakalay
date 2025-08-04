# 🏛️ Pustakalaya - PHP Backend

Government Library Management System - PHP Backend API

## 🚀 Quick Setup

### 1. **Copy to XAMPP/WAMP**
```bash
# Copy entire backend folder to htdocs
C:\xampp\htdocs\pustakalaya\
```

### 2. **Database Setup**
```sql
-- Create database
CREATE DATABASE pustakalaya;

-- Import schema
mysql -u root -p pustakalaya < database_schema.sql
```

### 3. **Test Backend**
- Open: `http://localhost/pustakalaya/`
- Should show backend status page

## 🔐 Login API

**Endpoint:** `POST /api/login.php`

**Request:**
```json
{
  "email": "ram@library.gov.in",
  "password": "admin123"
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "l_id": "1",
      "l_name": "राम शर्मा",
      "l_email": "ram@library.gov.in",
      "l_mobile": "9876543210",
      "l_role": "librarian"
    },
    "token": "base64_encoded_token"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

## 🧪 Test Credentials

| Name | Email | Password | Role |
|------|-------|----------|------|
| राम शर्मा | ram@library.gov.in | admin123 | librarian |
| श्याम गुप्ता | shyam@library.gov.in | lib123 | librarian |
| गीता वर्मा | geeta@library.gov.in | pass123 | librarian |

## 📂 Backend Structure

```
backend/
├── config/
│   └── database.php          # Database connection & helpers
├── api/
│   └── login.php            # Login authentication API
├── database_schema.sql      # Complete database schema
├── index.html              # Backend status page
└── README.md               # This file
```

## 🔧 CURL Testing

```bash
# Test login API
curl -X POST http://localhost/pustakalaya/api/login.php \
-H "Content-Type: application/json" \
-d '{"email":"ram@library.gov.in","password":"admin123"}'
```

## 🔐 Security Features

- ✅ CORS headers configured
- ✅ JSON input validation
- ✅ Email format validation
- ✅ Role-based access (librarian only)
- ✅ Database prepared statements
- ✅ Error handling

## 📱 Flutter Integration

Flutter app automatically connects to:
- **Base URL:** `http://localhost/pustakalaya`
- **Login Endpoint:** `/api/login.php`

## 🛠️ Next APIs to Implement

1. Users Management (`/api/users.php`)
2. Books Management (`/api/books.php`)
3. Donations Management (`/api/donations.php`)
4. Dashboard Stats (`/api/stats.php`)
5. File Upload (`/api/upload.php`)

## 📊 Database Tables

- `login` - Librarian authentication
- `users` - Library members/donors
- `books` - Book inventory
- `donations` - Donation records
- `donation_books` - Books per donation

## 🏃‍♂️ Development Mode

For development, ensure XAMPP/WAMP is running:
- Apache Server ✅
- MySQL Database ✅

Backend will be accessible at: `http://localhost/pustakalaya/`
