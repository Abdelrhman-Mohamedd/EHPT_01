<?php
/**
 * serve_upload.php — Secure file download endpoint
 * Streams uploaded files from /srv/labs/lab01/uploads/ (outside webroot).
 * Never executes PHP — always serves as binary stream.
 */
require_once(__DIR__ . '/student_config.php');

$id = $_GET['id'] ?? '';

// Validate ID format: must be exactly 32 hex characters
if (!preg_match('/^[a-f0-9]{32}$/', $id)) {
    http_response_code(400);
    header('Content-Type: text/plain');
    echo 'Error: Invalid file identifier.';
    exit;
}

$uploadDir = '/srv/labs/lab01/uploads/';
if (!is_dir($uploadDir)) {
    $uploadDir = __DIR__ . '/../uploads/';
}

// Read metadata
$metaFile = $uploadDir . $id . '.meta';
if (!file_exists($metaFile)) {
    http_response_code(404);
    header('Content-Type: text/plain');
    echo 'Error: File not found.';
    exit;
}

$meta = json_decode(file_get_contents($metaFile), true);
if (!$meta || empty($meta['safe_name']) || empty($meta['mime'])) {
    http_response_code(500);
    header('Content-Type: text/plain');
    echo 'Error: Invalid file metadata.';
    exit;
}

$filePath = $uploadDir . $meta['safe_name'];
$resolved = realpath($filePath);
$resolvedDir = realpath($uploadDir);

if ($resolved === false || !str_starts_with($resolved, $resolvedDir) || !is_file($resolved)) {
    http_response_code(404);
    header('Content-Type: text/plain');
    echo 'Error: File not found on disk.';
    exit;
}

// Stream file — never execute
header('Content-Type: ' . $meta['mime']);
header('Content-Disposition: inline; filename="' . basename($meta['original_name']) . '"');
header('Content-Length: ' . filesize($resolved));
header('X-Content-Type-Options: nosniff');
readfile($resolved);
exit;
