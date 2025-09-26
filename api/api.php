<?php
// Enable error reporting
require('dbStuff.php'); //holding database $dbAddress , $dbUsername , $dbPassword , $dbName

header('Content-Type: application/json');

// Your API key (hardcoded or better: store in env/config)


// Folder where to save uploaded files
define('UPLOAD_DIR', __DIR__ . '/uploads');

// Ensure upload folder exists
if (!file_exists(UPLOAD_DIR))
{
    mkdir(UPLOAD_DIR, 0755, true);
}

function sendResponse($data, $statusCode = 200)
{
    // http_response_code($statusCode);
    echo json_encode($data);
    exit;
}

function connect_db()
{
      global $dbAddress, $dbUsername, $dbPassword, $dbName;
      $conn = new mysqli($dbAddress, $dbUsername, $dbPassword, $dbName);
      if ($conn->connect_error)
      {
        // sendResponse(['error' => 'internal error: database connection failed'], 401);
        sendResponse(['error' => 'Database connection failed: ' . $conn->connect_error], 401);

      }
      return $conn;
}

function checkSessionKey($sessionKey,$requestType)
{
    if($requestType=="signup" || $requestType=="signin")
      return true;

    return isSessionValid($sessionKey);
}

function isSessionValid($sessionKey)
{
  // Connect to the database to validate the session key
  $conn = connect_db();

  // Query the database for the session key and expiration date
  $stmt = $conn->prepare("SELECT sessionExpireDate FROM users WHERE sessionKey = ?");
  $stmt->bind_param("s", $sessionKey);
  $stmt->execute();
  $stmt->store_result();

  // Check if the session key exists in the database
  if ($stmt->num_rows > 0)
  {
      $stmt->bind_result($sessionExpireDate);
      $stmt->fetch();

      // Check if the session key is expired
      if (strtotime($sessionExpireDate) > time())
      {
          return true; // Session key is valid
      }
      else
      {
          // Session expired
          sendResponse(['error' => 'Session has expired, Please sign-in'], 200);
      }
  }
  else
  {
      // Session key doesn't exist in the database
      sendResponse(['error' => 'Invalid session, You must sign-in'], 200);
  }

  return false;
}

function signIn($username, $password)
{
    if ($username && $password)
    {
        $conn = connect_db();

        // Query to get the password and current session key (if any)
        $stmt = $conn->prepare("SELECT id, password, sessionKey, sessionExpireDate FROM users WHERE username = ?");
        $stmt->bind_param("s", $username);
        $stmt->execute();
        $stmt->store_result();

        if ($stmt->num_rows > 0)
        {
            $stmt->bind_result($userId, $dbPassword, $currentSessionKey, $currentSessionExpireDate);
            $stmt->fetch();

            // Verify the password
            if (password_verify($password, $dbPassword))
            {
                // Generate a new session key
                $generatedSessionKey = generateSessionKey($username);



                // Update the user's session key and session expiry date in the database
                $stmt = $conn->prepare("UPDATE users SET sessionKey = ?, sessionExpireDate = ? WHERE id = ?");
                $stmt->bind_param("ssi", $generatedSessionKey, getSessionExpireTime(), $userId);

                if ($stmt->execute())
                {
                    // Return the session key and expiry date in the response
                    sendResponse([
                        'sessionKey' => $generatedSessionKey
                        // 'sessionExpireDate' => getSessionExpireTime()
                    ], 200);
                }
                else
                {
                    sendResponse(['error' => 'Failed to save session key and expiration'], 500);
                }
            }
            else
            {
                sendResponse(['error' => 'Invalid username or password'], 401);
            }
        }
        else
        {
            sendResponse(['error' => 'Invalid username or password'], 401);
        }
    }
    else
    {
        sendResponse(['error' => 'You must fill username and password'], 401);
    }
}


function signUp($username, $password, $email)
{
    if ($username && $password && $email)
    {
        // Validate the email format
        if (!filter_var($email, FILTER_VALIDATE_EMAIL))
        {
            sendResponse(['error' => 'Invalid email format'], 400);
        }

        // Connect to the database
        $conn = connect_db();

        // Check if username already exists
        $stmt = $conn->prepare("SELECT id FROM users WHERE username = ?");
        $stmt->bind_param("s", $username);
        $stmt->execute();
        $stmt->store_result();

        if ($stmt->num_rows > 0)
        {
            sendResponse(['error' => 'Username is already taken'], 400);
        }

        // Check if email already exists
        $stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $stmt->store_result();

        if ($stmt->num_rows > 0)
        {
            sendResponse(['error' => 'Email is already taken'], 400);
        }

        // Hash the password
        $hashedPassword = password_hash($password, PASSWORD_BCRYPT);

        // Generate a session key
        $generatedSessionKey = generateSessionKey($username);


        // Generate a unique verification code
        if (function_exists('openssl_random_pseudo_bytes'))
        {
          $verificationCode = bin2hex(openssl_random_pseudo_bytes(16)); // 32 characters
        }
        else
        {
            // Fallback for older versions, use mt_rand() (less secure)
          $verificationCode = bin2hex(random_bytes_fallback(16)); // 32 characters
        }



        // Insert the new user into the database
        $stmt = $conn->prepare("INSERT INTO users (username, password, email, sessionKey, sessionExpireDate, verification_code, is_verified) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sssssss", $username, $hashedPassword, $email, $generatedSessionKey, getSessionExpireTime(), $verificationCode, $is_verified = 0);


        if ($stmt->execute())
        {
            sendVerificationEmail($email, $verificationCode);
            sendResponse(['sessionKey' => $generatedSessionKey], 200);
        }
        else
        {
            sendResponse(['error' => 'Failed to create user'], 200);
        }
    }
    else
    {
        sendResponse(['error' => 'Username, password, and email are required'], 400);
    }
}


function random_bytes_fallback($length)
{
    $bytes = '';
    for ($i = 0; $i < $length; $i++)
    {
        $bytes .= chr(mt_rand(0, 255));
    }
    return $bytes;
}

function getSessionExpireTime()
{
  // Set session expiry date (e.g., x days from current date)
  $sessionExpireTime = "+100 days";
  $timestamp = strtotime($sessionExpireTime);
  return date('Y-m-d H:i:s', $timestamp);
}

function sendVerificationEmail($email, $verificationCode)
{
    $subject = "Email Verification";
    $body = "Please verify your email by clicking the following link: \n";
    $body .= "http://typedrill.ir/typedrill/api2/verifyEmail.php?code=" . $verificationCode;

    $headers = "From: TypeDrill (No Reply) <no-reply@typedrill.ir>\r\n";
    $headers .= "Reply-To: support@typedrill.ir\r\n";
    $headers .= "Content-Type: text/plain; charset=UTF-8\r\n";

    mail($email, $subject, $body, $headers);
}

function signOut()
{
    // Connect to the database
    $conn = connect_db();

    // Query to remove the session key from the database
    $stmt = $conn->prepare("UPDATE users SET sessionKey = NULL, sessionExpireDate = NULL WHERE sessionKey = ?");
    $stmt->bind_param("s", $sessionKey);

    // Execute the query
    if ($stmt->execute())
    {
        // Return success response if session key was removed
        sendResponse(['message' => 'Successfully logged out'], 200);
    }
    else
    {
        // If there was an error while updating, return an error message
        sendResponse(['error' => 'Failed to log out'], 500);
    }

}


function generateSessionKey($username)
{
    $sessionKey = md5($username . time());
    return $sessionKey;
}

function getUserIdFromSession($sessionKey)
{
    // Connect to the database
    $conn = connect_db();

    // Query to get the user ID from the sessionKey
    $stmt = $conn->prepare("SELECT id FROM users WHERE sessionKey = ?");
    $stmt->bind_param("s", $sessionKey);
    $stmt->execute();
    $stmt->store_result();

    // Check if the sessionKey exists in the database
    if ($stmt->num_rows > 0)
    {
        // Fetch the user_id
        $stmt->bind_result($userId);
        $stmt->fetch();

        // Return the user_id
        return $userId;
    }
    else
    {
        // If the sessionKey is invalid, return an error or false
        sendResponse(['error' => 'Invalid session key'], 401);
        return false;
    }
}

function updateFileVisibility($fileId,$visibility,$sessionKey,$successResponseAllowed=true)
{
    if (!isset($fileId) || $fileId==null)
    {
        sendResponse(['error' => 'File ID is required']);
    }

    $userId = getUserIdFromSession($sessionKey);  // Get user ID from session

    // Check if the file exists and belongs to the user
    $conn = connect_db();
    $stmt = $conn->prepare("SELECT user_id FROM files WHERE id = ?");
    $stmt->bind_param("i", $fileId);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows === 0)
    {
        sendResponse(['error' => 'File not found']);
    }

    $stmt->bind_result($ownerId);
    $stmt->fetch();

    if ($ownerId !== $userId)
    {
        sendResponse(['error' => 'You are not the owner of this file']);
    }

    // Update file visibility
    $stmt = $conn->prepare("UPDATE files SET visibility = ? WHERE id = ?");
    $stmt->bind_param("si", $visibility, $fileId);
    if ($stmt->execute())
    {
        if($successResponseAllowed)
          sendResponse(['success' => 'File visibility updated']);
        else
          return true;
    }
    else
    {
        sendResponse(['error' => 'Failed to update file visibility']);
    }
    return false;
}


function removeFile($fileId,$sessionKey)
{
    if (!isset($fileId))
    {
        sendResponse(['error' => 'File ID is required']);
    }

    $userId = getUserIdFromSession($sessionKey);  // Get user ID from session

    // Check if the file exists and belongs to the user
    $conn = connect_db();
    $stmt = $conn->prepare("SELECT filename, user_id FROM files WHERE id = ?");
    $stmt->bind_param("i", $fileId);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows === 0)
    {
        sendResponse(['error' => 'File not found']);
    }

    $stmt->bind_result($filename, $ownerId);
    $stmt->fetch();

    if ($ownerId !== $userId)
    {
        sendResponse(['error' => 'You are not the owner of this file']);
    }

    // Delete the file from the server
    $filePath = UPLOAD_DIR . '/' . $filename;
    if (file_exists($filePath))
    {
        unlink($filePath);
    }

    // Remove the file from the database
    $stmt = $conn->prepare("DELETE FROM files WHERE id = ?");
    $stmt->bind_param("i", $fileId);
    if ($stmt->execute())
    {
        if($successResponseAllowed)
          sendResponse(['success' => 'File removed successfully']);
    }
    else
    {
        sendResponse(['error' => 'Failed to remove file']);
    }
}


function getDbListNew($visibilityType, $sessionKey)
{
    // Define admin user IDs as an array (not a constant)
    $adminIdList = [1, 2, 3];  // Replace with actual admin IDs

    // Get user ID from session
    $userId = getUserIdFromSession($sessionKey);

    // Connect to the database
    $conn = connect_db();

    // Prepare the base query for getting files with user details
    $query = "
        SELECT f.id, f.filename, f.file_path, f.visibility, f.user_id, u.username
        FROM files f
        JOIN users u ON f.user_id = u.id ";  // Assuming 'users' table has 'id' and 'username'

    // Filter based on visibility type
    switch ($visibilityType)
    {
        case 'my privates':
            $query .= "WHERE f.user_id = ? AND f.visibility = 'private'";
            break;
        case 'my publics':
            $query .= "WHERE f.user_id = ? AND f.visibility = 'public'";
            break;
        case 'all mine':
            $query .= "WHERE f.user_id = ?";
            break;
        case 'community':
            $query .= "WHERE f.visibility = 'public'";
            break;
        case 'officials':
            // Use implode() to correctly build the list of admin IDs
            $query .= "WHERE f.user_id IN (" . implode(",", $adminIdList) . ") AND f.visibility = 'public'";
            break;
        default:
            sendResponse(['error' => 'Invalid visibility type'], 400);
            return;
    }

    // Prepare the query statement
    $stmt = $conn->prepare($query);

    // Bind userId for private, public, or all mine queries
    if ($visibilityType !== 'community' && $visibilityType !== 'officials') {
        $stmt->bind_param("i", $userId);
    }

    // Check if prepare was successful
    if (!$stmt) {
        sendResponse(['error' => 'Failed to prepare statement'], 500);
        return;
    }

    // Execute the query
    $stmt->execute();
    $stmt->store_result();

    // Bind results
    $stmt->bind_result($fileId, $filename, $filePath, $visibility, $fileOwnerId, $username);
    $files = [];

    while ($stmt->fetch())
    {
        $baseUrl = 'http://' . $_SERVER['HTTP_HOST'] . dirname($_SERVER['PHP_SELF']) . '/uploads';
        $defaultIcon = "http://typedrill.ir/typedrill/api2/giu-intermediate.png";
        $files[] = [
            'd_id' => (string)$fileId,
            'd_name' => $filename,
            'd_url' => $baseUrl . '/' . rawurlencode($filename),
            'd_icon' => $defaultIcon,
            'd_visibility' => $visibility,
            'd_owner' => $username
        ];
    }

    // Send the response
    sendResponse($files);
}




function renameFile($fileId,$newFilename,$sessionKey,$successResponseAllowed=true)
{
    // Validate input parameters
    if (!isset($fileId) || !isset($newFilename) || $newFilename==null || $fileId==null)
    {
        sendResponse(['error' => 'File ID and new filename are required']);
    }

    $userId = getUserIdFromSession($sessionKey);  // Get user ID from session

    // Validate the file exists and belongs to the user
    $conn = connect_db();
    $stmt = $conn->prepare("SELECT filename, user_id, file_path FROM files WHERE id = ?");
    $stmt->bind_param("i", $fileId);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows === 0)
    {
        sendResponse(['error' => 'File not found']);
    }

    $stmt->bind_result($currentFilename, $ownerId, $filePath);
    $stmt->fetch();

    if ($ownerId !== $userId)
    {
        sendResponse(['error' => 'You are not the owner of this file']);
    }

    // Check if the new filename already exists
    $newFilePath = UPLOAD_DIR . '/' . $newFilename;
    if (file_exists($newFilePath))
    {
        sendResponse(['error' => 'A file with the new filename already exists']);
    }

    // Rename the file on the server
    if (rename($filePath, $newFilePath))
    {
        // Update the filename in the database
        $stmt = $conn->prepare("UPDATE files SET filename = ?, file_path = ? WHERE id = ?");
        $stmt->bind_param("ssi", $newFilename, $newFilePath, $fileId);
        if ($stmt->execute())
        {
            if($successResponseAllowed)
              sendResponse(['success' => 'File renamed successfully']);
            else
              return true;
        }
        else
        {
            // Rollback if database update fails
            rename($newFilePath, $filePath);  // Rename back to the original filename
            sendResponse(['error' => 'Failed to update database']);
        }
    }
    else
    {
        sendResponse(['error' => 'Failed to rename file on the server']);
    }
    return false;
}


// Handle GET requests
if ($_SERVER['REQUEST_METHOD'] === 'GET')
{
  $headers = getallheaders();
  $requestType = isset($_GET['request']) ? $_GET['request'] : null;
  $sessionKey = isset($_GET['sessionKey']) ? $_GET['sessionKey'] : null;
  $username = isset($_GET['username']) ? $_GET['username'] : null;
  $password = isset($_GET['password']) ? $_GET['password'] : null;
  $email = isset($_GET['email']) ? $_GET['email'] : null;


  //db file crud
  $fileId =  isset($_GET['fileId']) ? $_GET['fileId'] : null;
  $fileVisibilityStatus = isset($_GET['visibility']) ? $_GET['visibility'] : "private";
  $dbNewName = isset($_GET['newName']) ? $_GET['newName'] : null;


  //get db list
  //visiblitis can be : my privates   my publics   all mine   community   officials
  $getListVisibility = isset($_GET['getOnly']) ? $_GET['getOnly'] : "all-mine";

  if(isset($requestType))
  {
    if(checkSessionKey($sessionKey,$requestType))
    {
      switch ($requestType)
      {
        case 'pingSession':
        {
          sendResponse(["message" => "is valid"]);
        }break;

        case 'get-db-list': getDbListNew($getListVisibility,$sessionKey);
          break;

        case 'signin': signIn($username,$password);
          break;

        case 'signup': signUp($username,$password, $email);
          break;

        case 'signout': signOut();
          break;

        case 'update-visibility': updateFileVisibility($fileId,$fileVisibilityStatus,$sessionKey);
          break;

        case 'remove-db': removeFile($fileId,$sessionKey);
          break;

        case 'rename-db': renameFile($fileId,$dbNewName,$sessionKey);
          break;

        //update name and visibility
        case 'update-db':
        {
           $statusRename = renameFile($fileId,$dbNewName,$sessionKey,false);
           $statusVisibility = updateFileVisibility($fileId,$fileVisibilityStatus,$sessionKey,false);
           if($statusRename && $statusVisibility)
               sendResponse(["message" => "file updated successfully"]);

        }break;

        default:
          sendResponse(["error" => "invalid request"]);
          break;
      }
    }
  }
  else
  {
      sendResponse(['error' => 'you must set request'], 401);
  }
}




//--------------------------------------------------------------------------------- POST

// Function to handle file upload
function uploadFile($visibility, $sessionKey)
{
    // Check if the file is uploaded
    if (!isset($_FILES['file'])) {
        sendResponse(['error' => 'No file uploaded']);
    }

    $file = $_FILES['file'];

    // Debugging: Print the $_FILES array
    // print_r($file);
    // exit;

    // Check for upload error
    if ($file['error'] !== UPLOAD_ERR_OK) {
        sendResponse(['error' => 'File upload error code: ' . $file['error']]);
    }

    // Sanitize the filename to prevent directory traversal
    $filename = basename($file['name']);
    $fileExtension = pathinfo($filename, PATHINFO_EXTENSION);

    // If visibility is "false", add "pv_" prefix to the filename
    // if ($visibility === "false") {
    //     $filename = "pv_" . $filename;
    // }

    $visibility = $visibility=="false" ? "private":"public" ;

    // Ensure the upload directory exists and is writable
    if (!is_writable(UPLOAD_DIR)) {
        sendResponse(['error' => 'Upload directory is not writable']);
    }

    // Check if file already exists in the target directory and generate a new name if necessary
    $targetPath = UPLOAD_DIR . '/' . $filename;
    $fileIndex = 1;
    while (file_exists($targetPath)) {
        $filename = pathinfo($file['name'], PATHINFO_FILENAME) . '_' . time() . '.' . $fileExtension;
        $targetPath = UPLOAD_DIR . '/' . $filename;
        $fileIndex++;
    }

    // Move the uploaded file to the target directory
    if (!move_uploaded_file($file['tmp_name'], $targetPath)) {
        sendResponse(['error' => 'Failed to move uploaded file']);
    }

    // Get the user ID based on the session key
    $userId = getUserIdFromSession($sessionKey);  // Implement this function based on your session system

    // Insert file metadata into the database
    $conn = connect_db();
    $stmt = $conn->prepare("INSERT INTO files (user_id, filename, file_path, visibility) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("isss", $userId, $filename, $targetPath, $visibility);

    // Execute the query and return a success message if the file is uploaded successfully
    if ($stmt->execute()) {
        sendResponse(['message' => 'File uploaded successfully']);
    } else {
        sendResponse(['error' => 'Failed to insert file metadata']);
    }
}

// Handle POST requests
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $headers = getallheaders();
    $requestType = $headers['request'];
    $sessionKey = $headers['sessionKey'];
    $fileVisibilityStatus = isset($headers['status']) ? $headers['status'] : "private";

    // Check if the request type is valid
    if (isset($requestType)) {
        if (checkSessionKey($sessionKey, $requestType)) {
            switch ($requestType) {
                case 'upload-db':
                    uploadFile($fileVisibilityStatus, $sessionKey);
                    break;

                default:
                    sendResponse(['error' => "Invalid request mode"]);
                    break;
            }
        } else {
            sendResponse(['error' => 'Invalid session key']);
        }
    } else {
        sendResponse(['error' => 'You must set a request type']);
    }
}

// If method is not POST
sendResponse(['error' => 'Method not allowed']);

// Handle POST requests
if ($_SERVER['REQUEST_METHOD'] === 'POST')
{
  $headers = getallheaders();
  $requestType = $headers['request'];
  $sessionKey = $headers['sessionKey'];
  $fileVisibilityStatus = isset($headers['status']) ? $headers['status'] : "private";
  // $debugTXT = "stuff, reqtype=" . $requestType . "sesionKey=" .  $sessionKey . "status=" . $status;
    // sendResponse($debugTXT);

  if(isset($requestType))
  {
    if(checkSessionKey($sessionKey,$requestType))
    {
      switch ($requestType)
      {
          case 'upload-db':
          {
              uploadFile($fileVisibilityStatus,$sessionKey);
          }break;

          default:
            sendResponse(['error' => "invalid request"]);
            break;
      }
    }
  }
  else
  {
      sendResponse(['error' => 'you must set request']);
  }
}


// If method not allowed
sendResponse(['error' => 'Method not allowed']);
