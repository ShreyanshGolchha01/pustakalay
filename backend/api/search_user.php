<?php
require_once '../config/database.php';

// Only allow GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Only GET method allowed', 405);
}

// Get mobile number from query parameter
$mobile = isset($_GET['mobile']) ? trim($_GET['mobile']) : '';

// Validate mobile number
if (empty($mobile)) {
    sendError('Mobile number is required');
}

if (strlen($mobile) !== 10 || !ctype_digit($mobile)) {
    sendError('Invalid mobile number format');
}

try {
    // Database connection
    $database = new Database();
    $db = $database->getConnection();

    // Search user by mobile number
    $query = "SELECT u_id, u_name, u_mobile, u_createdat 
              FROM users 
              WHERE u_mobile = :mobile";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':mobile', $mobile);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        sendSuccess('User found', $user);
    } else {
        sendError('User not found with this mobile number', 404);
    }

} catch(PDOException $exception) {
    sendError('Database error: ' . $exception->getMessage(), 500);
} catch(Exception $exception) {
    sendError('Server error: ' . $exception->getMessage(), 500);
}
?>
