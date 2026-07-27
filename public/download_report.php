<?php
// download_report.php - Path Traversal Vulnerability
$file = $_GET['file'] ?? 'report.pdf';
$path = "/srv/labs/lab01/public/reports/" . $file;

if (!file_exists($path)) {
    // Development/testing fallback if environment is running locally before deployment to /srv/labs/lab01/public
    $path = __DIR__ . "/reports/" . $file;
}

if (file_exists($path)) {
    header('Content-Type: text/plain');
    header('Content-Disposition: inline; filename="' . basename($file) . '"');
    readfile($path);
    exit;
} else {
    http_response_code(404);
    echo "Error: Document " . htmlspecialchars($file) . " not found at target path.";
}
?>
