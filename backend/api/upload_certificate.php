<?php
require_once '../config/database.php';

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Only POST method allowed', 405);
}

// Check if file was uploaded
if (!isset($_FILES['certificate']) || $_FILES['certificate']['error'] !== UPLOAD_ERR_OK) {
    sendError('No file uploaded or upload error');
}

$file = $_FILES['certificate'];

// Validate file type (only images)
$allowedTypes = ['image/jpeg', 'image/jpg', 'image/png'];
if (!in_array($file['type'], $allowedTypes)) {
    sendError('Only JPEG and PNG images are allowed');
}

// Validate file size (max 5MB)
$maxSize = 5 * 1024 * 1024; // 5MB
if ($file['size'] > $maxSize) {
    sendError('File size too large. Maximum 5MB allowed');
}

try {
    // Create uploads directory if it doesn't exist
    $uploadDir = '../uploads/certificates/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0755, true);
    }

    // Generate unique filename
    $fileExtension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $fileName = 'cert_' . uniqid() . '_' . time() . '.' . $fileExtension;
    $filePath = $uploadDir . $fileName;

    // Move uploaded file
    if (move_uploaded_file($file['tmp_name'], $filePath)) {
        // Return the relative path that will be stored in database
        $relativePath = 'uploads/certificates/' . $fileName;
        
        sendSuccess('File uploaded successfully', [
            'file_path' => $relativePath,
            'file_name' => $fileName
        ]);
    } else {
        sendError('Failed to save uploaded file');
    }

} catch(Exception $exception) {
    sendError('Upload error: ' . $exception->getMessage(), 500);
}
?>
