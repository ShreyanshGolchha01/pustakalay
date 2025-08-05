<?php
require_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if file was uploaded
    if (!isset($_FILES['certificate']) || $_FILES['certificate']['error'] !== UPLOAD_ERR_OK) {
        sendResponse(false, 'No file uploaded or upload error');
    }
    
    $file = $_FILES['certificate'];
    $donor_id = isset($_POST['donor_id']) ? $_POST['donor_id'] : null;
    $librarian_id = isset($_POST['librarian_id']) ? $_POST['librarian_id'] : null;
    
    if (!$donor_id || !$librarian_id) {
        sendResponse(false, 'Donor ID and Librarian ID are required');
    }
    
    // Validate file type
    $allowedTypes = ['image/jpeg', 'image/jpg', 'image/png'];
    if (!in_array($file['type'], $allowedTypes)) {
        sendResponse(false, 'Only JPEG and PNG files are allowed');
    }
    
    // Validate file size (max 5MB)
    if ($file['size'] > 5 * 1024 * 1024) {
        sendResponse(false, 'File size too large. Maximum 5MB allowed');
    }
    
    try {
        // Create upload directory if it doesn't exist
        $uploadDir = '../uploads/certificates/';
        if (!file_exists($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }
        
        // Generate unique filename
        $fileExtension = pathinfo($file['name'], PATHINFO_EXTENSION);
        $fileName = 'cert_' . $donor_id . '_' . time() . '.' . $fileExtension;
        $filePath = $uploadDir . $fileName;
        
        // Move uploaded file
        if (move_uploaded_file($file['tmp_name'], $filePath)) {
            // Save file record in database
            $query = "INSERT INTO files (f_path, f_user_id, f_lib_id) VALUES (:path, :user_id, :lib_id)";
            $stmt = $db->prepare($query);
            $stmt->bindParam(':path', $fileName); // Store relative path
            $stmt->bindParam(':user_id', $donor_id);
            $stmt->bindParam(':lib_id', $librarian_id);
            
            if ($stmt->execute()) {
                $file_id = $db->lastInsertId();
                sendResponse(true, 'Certificate uploaded successfully', [
                    'file_id' => $file_id,
                    'filename' => $fileName,
                    'file_path' => $fileName,
                    'full_path' => $filePath
                ]);
            } else {
                // Delete uploaded file if database insert fails
                unlink($filePath);
                sendResponse(false, 'Failed to save file record');
            }
        } else {
            sendResponse(false, 'Failed to upload file');
        }
        
    } catch (Exception $e) {
        sendResponse(false, 'Error uploading certificate: ' . $e->getMessage());
    }
} else {
    sendResponse(false, 'Only POST method allowed');
}
?>
