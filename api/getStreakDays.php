<?php
header('Content-Type: image/png');
header('Catch-Control: max-age=21600, s-maxage=21600, must-revalidate'); //every 6 hours

date_default_timezone_set('Asia/Tehran');

// --- Configuration ---
define('FONT_PATH', __DIR__ . '/JosefinSans-Regular.ttf');
define('ICON_PATH', __DIR__ . '/streak.png');
define('UPLOAD_DIR', __DIR__ . '/uploads/');
define('IMG_WIDTH', 400);
define('IMG_HEIGHT', 140);

// --- Entry Point ---
$params = getValidatedParams();
$pdo = connectToDatabase(UPLOAD_DIR . $params['filename']);
$streakCount = calculateStreak($pdo);
generateBadgeImage($params['username'], $streakCount, $params['theme']);

// --- Functions ---

function getValidatedParams() {
    $username = 'unknown';
    if (isset($_GET['username'])) {
        $usernameRaw = strtolower(trim($_GET['username']));
        // Allow letters, numbers, underscores, spaces and dashes only
        $username = preg_replace('/[^\w\s-]/', '', $usernameRaw);
        if ($username === '') {
            $username = 'unknown user';
        }
    }

    $filename = '';
    if (isset($_GET['file'])) {
        $filename = basename($_GET['file']);
    }

    $theme = 'dark';
    if (isset($_GET['theme'])) {
        $themeCandidate = strtolower($_GET['theme']);
        $allowedThemes = array('dark', 'light');
        if (in_array($themeCandidate, $allowedThemes)) {
            $theme = $themeCandidate;
        }
    }

    $filePath = UPLOAD_DIR . $filename;
    if (!file_exists($filePath)) {
        sendErrorImage('Database not found!');
    }

    return array(
        'username' => $username,
        'filename' => $filename,
        'theme' => $theme
    );
}

function connectToDatabase($dbPath) {
    try {
        $pdo = new PDO('sqlite:' . $dbPath);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $pdo;
    } catch (PDOException $e) {
        sendErrorImage('DB connection error');
    }
}

function calculateStreak($pdo) {
    $currentDate = new DateTime();
    $streakCount = 0;

    while (true) {
        $start = $currentDate->format('Y-m-d') . ' 00:00:00';
        $end = $currentDate->format('Y-m-d') . ' 23:59:59';

        $stmt = $pdo->prepare('SELECT COUNT(*) as count FROM trace_practices WHERE tp_date BETWEEN :start AND :end');
        $stmt->execute(array(':start' => $start, ':end' => $end));

        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ((int)$row['count'] > 0) {
            $streakCount++;
            $currentDate->modify('-1 day');
        } else {
            break;
        }
    }

    return $streakCount;
}

function generateBadgeImage($username, $streakCount, $theme) {
    $im = imagecreatetruecolor(IMG_WIDTH, IMG_HEIGHT);

    // Set colors based on theme
    if ($theme === 'light') {
        $bgColor = imagecolorallocate($im, 255, 255, 255);
        $textColor = imagecolorallocate($im, 0, 0, 0);
    } else {
        $bgColor = imagecolorallocate($im, 40, 44, 52);
        $textColor = imagecolorallocate($im, 255, 255, 255);
    }

    imagefill($im, 0, 0, $bgColor);

    // Load icon
    $iconHeight = 0;
    if (file_exists(ICON_PATH)) {
        $icon = imagecreatefrompng(ICON_PATH);
        imagealphablending($im, true);
        imagesavealpha($im, true);

        $iconWidth = imagesx($icon);
        $iconHeight = imagesy($icon);

        $iconX = (IMG_WIDTH - $iconWidth) / 2;
        $iconY = 10;
        imagecopy($im, $icon, $iconX, $iconY, 0, 0, $iconWidth, $iconHeight);
    }

    // Prepare text lines
    $lines = array(
        $username . '\'s Streak',
        $streakCount . ' day' . ($streakCount !== 1 ? 's' : '') . ' on TypeDrill'
    );

    $fontSize = 16;
    $lineHeight = 26;
    $startY = 10 + $iconHeight + 30;

    if (file_exists(FONT_PATH)) {
        foreach ($lines as $i => $line) {
            $bbox = imagettfbbox($fontSize, 0, FONT_PATH, $line);
            $textWidth = $bbox[2] - $bbox[0];
            $textX = (IMG_WIDTH - $textWidth) / 2;
            $textY = $startY + $i * $lineHeight;
            imagettftext($im, $fontSize, 0, $textX, $textY, $textColor, FONT_PATH, $line);
        }
    } else {
        $fallbackText = implode(' | ', $lines);
        $font = 5;
        $textWidth = imagefontwidth($font) * strlen($fallbackText);
        $textX = (IMG_WIDTH - $textWidth) / 2;
        $textY = $startY + 20;
        imagestring($im, $font, $textX, $textY, $fallbackText, $textColor);
    }

    imagepng($im);
    imagedestroy($im);
    exit;
}

function sendErrorImage($message) {
    $im = imagecreatetruecolor(400, 120);
    $bg = imagecolorallocate($im, 255, 0, 0);
    imagefill($im, 0, 0, $bg);
    $textColor = imagecolorallocate($im, 255, 255, 255);
    imagestring($im, 5, 10, 50, $message, $textColor);
    imagepng($im);
    imagedestroy($im);
    exit;
}
