<?php
require_once '../config/database.php';

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Only POST method allowed', 405);
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
$requiredFields = ['librarian_id', 'user_data', 'books', 'is_new_user'];
foreach ($requiredFields as $field) {
    if (!isset($input[$field])) {
        sendError("Missing required field: $field");
    }
}

$librarianId = $input['librarian_id'];
$userData = $input['user_data'];
$books = $input['books'];
$isNewUser = $input['is_new_user'];
$certificatePath = $input['certificate_path'] ?? null;

// Validate librarian ID
if (!is_numeric($librarianId)) {
    sendError('Invalid librarian ID');
}

// Validate user data
if ($isNewUser) {
    if (empty($userData['name']) || empty($userData['mobile'])) {
        sendError('User name and mobile are required');
    }
    if (strlen($userData['mobile']) !== 10 || !ctype_digit($userData['mobile'])) {
        sendError('Invalid mobile number format');
    }
} else {
    if (empty($userData['u_id'])) {
        sendError('User ID is required for existing user');
    }
}

// Validate books
if (empty($books) || !is_array($books)) {
    sendError('At least one book is required');
}

foreach ($books as $book) {
    if (empty($book['title']) || empty($book['author']) || empty($book['genre']) || empty($book['isbn'])) {
        sendError('Book title, author, genre, and ISBN are required');
    }
    if (!isset($book['count']) || !is_numeric($book['count']) || $book['count'] <= 0) {
        sendError('Valid book count is required');
    }
}

try {
    // Database connection
    $database = new Database();
    $db = $database->getConnection();
    
    // Start transaction
    $db->beginTransaction();

    $userId = null;

    if ($isNewUser) {
        // Check if user with this mobile already exists
        $checkQuery = "SELECT u_id FROM users WHERE u_mobile = :mobile";
        $checkStmt = $db->prepare($checkQuery);
        $checkStmt->bindParam(':mobile', $userData['mobile']);
        $checkStmt->execute();
        
        if ($checkStmt->rowCount() > 0) {
            $db->rollBack();
            sendError('User with this mobile number already exists');
        }

        // Insert new user
        $userQuery = "INSERT INTO users (u_name, u_mobile, ul_id) VALUES (:name, :mobile, :librarian_id)";
        $userStmt = $db->prepare($userQuery);
        $userStmt->bindParam(':name', $userData['name']);
        $userStmt->bindParam(':mobile', $userData['mobile']);
        $userStmt->bindParam(':librarian_id', $librarianId);
        
        if (!$userStmt->execute()) {
            $db->rollBack();
            sendError('Failed to create user');
        }
        
        $userId = $db->lastInsertId();
    } else {
        // Validate existing user
        $userQuery = "SELECT u_id FROM users WHERE u_id = :user_id";
        $userStmt = $db->prepare($userQuery);
        $userStmt->bindParam(':user_id', $userData['u_id']);
        $userStmt->execute();
        
        if ($userStmt->rowCount() === 0) {
            $db->rollBack();
            sendError('User not found');
        }
        
        $userId = $userData['u_id'];
    }

    // Insert books
    $bookIds = [];
    $bookQuery = "INSERT INTO books (b_title, b_author, b_genre, b_isbn, b_count, b_donatedBy, bl_id) 
                  VALUES (:title, :author, :genre, :isbn, :count, :donated_by, :librarian_id)";
    $bookStmt = $db->prepare($bookQuery);

    foreach ($books as $book) {
        // Check if book with this ISBN already exists
        $isbnCheckQuery = "SELECT b_id FROM books WHERE b_isbn = :isbn";
        $isbnCheckStmt = $db->prepare($isbnCheckQuery);
        $isbnCheckStmt->bindParam(':isbn', $book['isbn']);
        $isbnCheckStmt->execute();
        
        if ($isbnCheckStmt->rowCount() > 0) {
            $db->rollBack();
            sendError('Book with ISBN ' . $book['isbn'] . ' already exists');
        }

        $bookStmt->bindParam(':title', $book['title']);
        $bookStmt->bindParam(':author', $book['author']);
        $bookStmt->bindParam(':genre', $book['genre']);
        $bookStmt->bindParam(':isbn', $book['isbn']);
        $bookStmt->bindParam(':count', $book['count']);
        $bookStmt->bindParam(':donated_by', $userId);
        $bookStmt->bindParam(':librarian_id', $librarianId);
        
        if (!$bookStmt->execute()) {
            $db->rollBack();
            sendError('Failed to add book: ' . $book['title']);
        }
        
        $bookIds[] = $db->lastInsertId();
    }

    // Insert certificate file record if provided
    if ($certificatePath) {
        $fileQuery = "INSERT INTO files (f_path, f_user_id, f_lib_id) VALUES (:path, :user_id, :librarian_id)";
        $fileStmt = $db->prepare($fileQuery);
        $fileStmt->bindParam(':path', $certificatePath);
        $fileStmt->bindParam(':user_id', $userId);
        $fileStmt->bindParam(':librarian_id', $librarianId);
        
        if (!$fileStmt->execute()) {
            $db->rollBack();
            sendError('Failed to save certificate record');
        }
    }

    // Commit transaction
    $db->commit();

    // Prepare response
    $response = [
        'user_id' => $userId,
        'book_ids' => $bookIds,
        'total_books' => count($books),
        'certificate_saved' => !empty($certificatePath)
    ];

    sendSuccess('Books added successfully', $response);

} catch(PDOException $exception) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendError('Database error: ' . $exception->getMessage(), 500);
} catch(Exception $exception) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendError('Server error: ' . $exception->getMessage(), 500);
}
?>
