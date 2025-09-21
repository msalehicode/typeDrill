<?php
require('dbStuff.php'); //holding database $dbAddress , $dbUsername , $dbPassword , $dbName

// Connect to your database
function connect_db()
{
    global $dbAddress, $dbUsername, $dbPassword, $dbName;

    // Create connection
    $conn = new mysqli($dbAddress, $dbUsername, $dbPassword, $dbName);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    return $conn;
}

if (isset($_GET['code']))
{
    // Retrieve the verification code from the URL parameter
    $verificationCode = $_GET['code'];

    // Connect to the database
    $conn = connect_db();

    // Check if the verification code exists in the database
    $stmt = $conn->prepare("SELECT id, is_verified FROM users WHERE verification_code = ?");
    $stmt->bind_param("s", $verificationCode);
    $stmt->execute();
    $stmt->store_result();

    // If the code exists, proceed with the verification
    if ($stmt->num_rows > 0)
    {
        $stmt->bind_result($userId, $isVerified);
        $stmt->fetch();

        // If the email is already verified
        if ($isVerified == 1)
        {
            echo "Your email is already verified.";
        }
        else
        {
            // Update the user's verification status to '1' (verified)
            $updateStmt = $conn->prepare("UPDATE users SET is_verified = 1, verification_code = null  WHERE verification_code = ?");
            $updateStmt->bind_param("s", $verificationCode);

            if ($updateStmt->execute())
            {
                echo "Your email has been successfully verified!";
            }
            else
            {
                echo "There was an error verifying your email. Please try again.";
            }
        }
    }
    else
    {
        echo "Invalid or expired verification code.";
    }

    // Close database connection
    $stmt->close();
    $conn->close();
}
else
{
    echo "No verification code provided.";
}
?>
