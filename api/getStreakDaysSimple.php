<?php
// Set your default timezone (optional but recommended)
date_default_timezone_set('UTC');

// Get the filename from GET (e.g., script.php?file=example.db)
$filename = isset($_GET['file']) ? basename($_GET['file']) : '';

// Validate the file name (optional, uncomment if needed)
// if (empty($filename) || !preg_match('/^[\w,\s-]+\.sqlite$/', $filename)) {
//     die("Invalid or missing file name.");
// }

// Define the path
$dbPath = __DIR__ . '/uploads/' . $filename;

// Check if the file exists
if (!file_exists($dbPath)) {
    die("file not found.");
}

// --- Connect to SQLite ---
try {
    $pdo = new PDO("sqlite:" . $dbPath);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}

// Calculate day streaks
// --- Initialize current date ---
$currentDate = new DateTime();
$streakCount = 0;

while (true) {
    // Format start and end of the current day
    $startOfDay = $currentDate->format('Y-m-d') . " 00:00:00";
    $endOfDay = $currentDate->format('Y-m-d') . " 23:59:59";

    // Prepare and execute the query using fixed table name and date params
    $stmt = $pdo->prepare("
        SELECT COUNT(*) as count
        FROM trace_practices
        WHERE tp_date BETWEEN :start AND :end
    ");
    $stmt->execute([
        ':start' => $startOfDay,
        ':end' => $endOfDay
    ]);

    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $count = (int) $row['count'];

    if ($count > 0) {
        // Practiced on this day, increment streak
        $streakCount++;
        // Move to previous day
        $currentDate->modify('-1 day');
    } else {
        // No practice — streak broken
        break;
    }
}

// --- Output result ---
echo "Consecutive practice streak: $streakCount day(s)";
