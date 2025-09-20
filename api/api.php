<?php
define('DB_SERVERNAME', 'localhost');
define('DB_USERNAME', 'username');
define('DB_PASSWORD', 'password');
define('DB_NAME', 'databaseName');
define('SESSION_EXPIRE_TIME', '+100 days');

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
      $conn = new mysqli(DB_SERVERNAME, DB_USERNAME, DB_PASSWORD, DB_NAME);
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
            sendResponse(['error' => 'Session key has expired'], 401);
        }
    }
    else
    {
        // Session key doesn't exist in the database
        sendResponse(['error' => 'Invalid session key'], 401);
    }

    return false; // Return false if anything goes wrong
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

                // Set session expiry date (e.g., x days from current date)
                $sessionExpireDate = date('Y-m-d H:i:s', strtotime(SESSION_EXPIRE_TIME));

                // Update the user's session key and session expiry date in the database
                $stmt = $conn->prepare("UPDATE users SET sessionKey = ?, sessionExpireDate = ? WHERE id = ?");
                $stmt->bind_param("ssi", $generatedSessionKey, $sessionExpireDate, $userId);

                if ($stmt->execute())
                {
                    // Return the session key and expiry date in the response
                    sendResponse([
                        'sessionKey' => $generatedSessionKey,
                        'sessionExpireDate' => $sessionExpireDate
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

        // Set session expiry date (x days from current date)
        $sessionExpireDate = date('Y-m-d H:i:s', strtotime(SESSION_EXPIRE_TIME));

        // Insert the new user into the database
        $stmt = $conn->prepare("INSERT INTO users (username, password, email, sessionKey, sessionExpireDate) VALUES (?, ?, ?, ?, ?)");
        $stmt->bind_param("sssss", $username, $hashedPassword, $email, $generatedSessionKey, $sessionExpireDate);

        if ($stmt->execute())
        {
            sendResponse(['sessionKey' => $generatedSessionKey], 200);
        }
        else
        {
            sendResponse(['error' => 'Failed to create user'], 500);
        }
    }
    else
    {
        sendResponse(['error' => 'Username, password, and email are required'], 400);
    }
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


function getDbList()
{
    $files = array_diff(scandir(UPLOAD_DIR), ['.', '..']);
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

// Handle GET requests
if ($_SERVER['REQUEST_METHOD'] === 'GET')
{
  $headers = getallheaders();
  $requestType = isset($_GET['request']) ? $_GET['request'] : null;
  $sessionKey = isset($_GET['sessionKey']) ? $_GET['sessionKey'] : null;
  $username = isset($_GET['username']) ? $_GET['username'] : null;
  $password = isset($_GET['password']) ? $_GET['password'] : null;
  $email = isset($_GET['email']) ? $_GET['email'] : null;
  if(isset($requestType))
  {
    if(checkSessionKey($sessionKey,$requestType))
    {
      switch ($requestType)
      {
        case 'get-db-list': getDbList();
          break;

        case 'signin': signIn($username,$password);
          break;

        case 'signup': signUp($username,$password, $email);
          break;

        case 'signout': signOut();
          break;
      }
    }
  }
  else
  {
      sendResponse(['error' => 'you must set request'], 401);
  }
}

// Handle POST requests
if ($_SERVER['REQUEST_METHOD'] === 'POST')
{
  // For POST, check form data or JSON body
  $requestData = json_decode(file_get_contents('php://input'), true);
  $requestType = isset($requestData['request']) ? $requestData['request'] : (isset($_POST['request']) ? $_POST['request'] : null);
  $sessionKey = isset($requestData['sessionKey']) ? $requestData['sessionKey'] : (isset($_POST['sessionKey']) ? $_POST['sessionKey'] : null);
  $status = isset($requestData['status']) ? $requestData['status'] : (isset($_POST['status']) ? $_POST['status'] : null);


  if(isset($requestType))
  {
    if(checkSessionKey($sessionKey,$requestType))
    {
      switch ($requestType)
      {
                case 'upload-db':
                {
                    if (!isset($_FILES['file']))
                    {
                        sendResponse(['error' => 'No file uploaded'], 400);
                    }


                    $file = $_FILES['file'];

                    if ($file['error'] !== UPLOAD_ERR_OK)
                    {
                        sendResponse(['error' => 'File upload error code: ' . $file['error']], 400);
                    }

                    // Sanitize filename to prevent directory traversal etc.
                    $filename = basename($file['name']);


                    // If status is "false" (string), add prefix "pv_"
                    if ($status === "false")
                    {
                        $filename = "pv_" . $filename;
                    }


                    $targetPath = UPLOAD_DIR . '/' . $filename;

                    // Move uploaded file
                    if (move_uploaded_file($file['tmp_name'], $targetPath))
                    {
                        sendResponse(['success' => true, 'message' => 'File uploaded', 'path' => $targetPath]);
                    }
                    else
                    {
                        sendResponse(['error' => 'Failed to move uploaded file'], 500);
                    }
                  }break;

                  default:
                  {
                    sendResponse(['error' => 'invalid request mode'], 401);
                  }break;

      }
    }
  }
  else
  {
      sendResponse(['error' => 'you must set request'], 401);
  }
}

// If method not allowed
sendResponse(['error' => 'Method not allowed'], 405);
