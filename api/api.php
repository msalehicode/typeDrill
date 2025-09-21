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


function getDbList()
{
    $files = array_diff(scandir(UPLOAD_DIR), ['.', '..']);
    $baseUrl = 'http://' . $_SERVER['HTTP_HOST'] . dirname($_SERVER['PHP_SELF']) . '/uploads';
    $urls = [];

    foreach ($files as $file)
    {
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
        case 'pingSession':
        {
          sendResponse(["message" => "is valid"]);
        }break;

        case 'get-db-list': getDbList();
          break;

        case 'signin': signIn($username,$password);
          break;

        case 'signup': signUp($username,$password, $email);
          break;

        case 'signout': signOut();
          break;

        default:
          sendResponse("invalid request");
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
  $headers = getallheaders();
  $requestType = $headers['request'];
  $sessionKey = $headers['sessionKey'];
  $status = isset($headers['status']) ? $headers['status'] : "true";
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
                    if (!isset($_FILES['file']))
                    {
                        sendResponse(['error' => 'No file uploaded']);
                    }


                    $file = $_FILES['file'];

                    if ($file['error'] !== UPLOAD_ERR_OK)
                    {
                        sendResponse(['error' => 'File upload error code: ' . $file['error']]);
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
                        sendResponse(['error' => 'Failed to move uploaded file']);
                    }
                  }break;

                  default:
                  {
                    sendResponse(['error' => 'invalid request mode']);
                  }break;
          default:
            sendResponse("invalid request");
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
