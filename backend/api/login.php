<?php
require_once '../config/database.php';

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Only POST method allowed', 405);
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

// Validate input
if (!isset($input['email']) || !isset($input['password'])) {
    sendError('Email and password are required');
}

$email = trim($input['email']);
$password = trim($input['password']);

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    sendError('Invalid email format');
}

// Validate password length
if (strlen($password) < 1) {
    sendError('Password is required');
}

try {
    // Database connection
    $database = new Database();
    $db = $database->getConnection();

    // Check if user exists and is librarian
    $query = "SELECT l_id, l_name, l_email, l_password, l_mobile, l_role 
              FROM login 
              WHERE l_email = :email AND l_role = 'librarian'";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':email', $email);
    $stmt->execute();

    if ($stmt->rowCount() == 0) {
        sendError('Invalid credentials or user not found');
    }

    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    // Verify password (assuming plain text for now, should use password_hash in production)
    if ($password !== $user['l_password']) {
        sendError('Invalid credentials');
    }

    // Update last login time
    $updateQuery = "UPDATE login SET l_updatedAt = CURRENT_TIMESTAMP WHERE l_id = :id";
    $updateStmt = $db->prepare($updateQuery);
    $updateStmt->bindParam(':id', $user['l_id']);
    $updateStmt->execute();

    // Remove password from response
    unset($user['l_password']);

    // Send success response
    sendSuccess('Login successful', [
        'user' => $user,
        'token' => base64_encode($user['l_id'] . ':' . time()) // Simple token for now
    ]);

} catch(PDOException $exception) {
    sendError('Database error: ' . $exception->getMessage(), 500);
} catch(Exception $exception) {
    sendError('Server error: ' . $exception->getMessage(), 500);
}
?>
