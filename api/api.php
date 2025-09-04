<?php
header('Content-Type: application/json');

// Your API key (hardcoded or better: store in env/config)
define('API_KEY', 'YOUR_SECRET_API_KEY');

// Folder where to save uploaded files
define('UPLOAD_DIR', __DIR__ . '/uploads');

// Ensure upload folder exists
if (!file_exists(UPLOAD_DIR)) {
    mkdir(UPLOAD_DIR, 0755, true);
}

function sendResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode($data);
    exit;
}

// Check API key from header "X-API-KEY"
function checkApiKey() {
    $headers = getallheaders();
    if (!isset($headers['X-API-KEY']) || $headers['X-API-KEY'] !== API_KEY) {
        sendResponse(['error' => 'Unauthorized, invalid API key'], 401);
    }
}

// Handle GET request: return URLs list
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    checkApiKey();

    $files = array_diff(scandir(UPLOAD_DIR), ['.', '..']); // Get files, skip . and ..
    $baseUrl = 'http://' . $_SERVER['HTTP_HOST'] . dirname($_SERVER['PHP_SELF']) . '/uploads';

    $urls = [];

    foreach ($files as $file) {
        $urls[] = [
            'd_name' => $file,
            'd_url' => $baseUrl . '/' . rawurlencode($file),
            'd_icon' => ""
        ];
    }

    sendResponse($urls);
}

// Handle POST request: upload file
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    checkApiKey();

    if (!isset($_FILES['file'])) {
        sendResponse(['error' => 'No file uploaded'], 400);
    }

    // Read additional form field 'status'
    $status = isset($_POST['status']) ? $_POST['status'] : 'undefined';

    $file = $_FILES['file'];

    if ($file['error'] !== UPLOAD_ERR_OK) {
        sendResponse(['error' => 'File upload error code: ' . $file['error']], 400);
    }

    // Sanitize filename to prevent directory traversal etc.
    $filename = basename($file['name']);


    // If status is "false" (string), add prefix "pv_"
    if ($status === "false") {
        $filename = "pv_" . $filename;
    }


    $targetPath = UPLOAD_DIR . '/' . $filename;

    // Move uploaded file
    if (move_uploaded_file($file['tmp_name'], $targetPath)) {
        sendResponse(['success' => true, 'message' => 'File uploaded', 'path' => $targetPath]);
    } else {
        sendResponse(['error' => 'Failed to move uploaded file'], 500);
    }
}

// If method not allowed
sendResponse(['error' => 'Method not allowed'], 405);
