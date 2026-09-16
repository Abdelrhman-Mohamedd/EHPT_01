<?php
/**
 * download_report.php — Hardened report download endpoint
 * Serves allowlisted reports with proper headers.
 * Path traversal payloads trigger dynamic flag generation.
 */
require_once(__DIR__ . '/student_config.php');
require_once(__DIR__ . '/flag_engine.php');

$file = $_GET['file'] ?? 'report.pdf';

// Check for path traversal BEFORE any filesystem operations
if (detect_exploit('PATHTRAV', $file)) {
    header('Content-Type: text/plain; charset=utf-8');
    echo "=== Security Alert ==="  . "\n";
    echo "Path traversal attempt detected." . "\n";
    echo "Verification Token: " . generate_flag('PATHTRAV') . "\n";
    exit;
}

// Apply basename() as defense-in-depth
$safeName = basename($file);

// Allowlist of legitimate downloadable reports
$allowed_reports = ['report.pdf', 'q3_eval_2025.pdf'];

if (!in_array($safeName, $allowed_reports, true)) {
    http_response_code(404);
    header('Content-Type: text/plain');
    echo "Error: Document '" . htmlspecialchars($safeName) . "' not found.";
    exit;
}

// Resolve path and validate it stays under reports directory
$reportsDir = '/srv/labs/lab01/data/reports';
if (!is_dir($reportsDir)) {
    $reportsDir = __DIR__ . '/../data/reports';
}
$reportsDir = realpath($reportsDir);
$fullPath = realpath($reportsDir . '/' . $safeName);

if ($fullPath === false || !str_starts_with($fullPath, $reportsDir) || !is_file($fullPath)) {
    http_response_code(404);
    header('Content-Type: text/plain');
    echo "Error: Document not found at target path.";
    exit;
}

// Serve with proper headers
header('Content-Type: text/plain; charset=utf-8');
header('Content-Disposition: inline; filename="' . $safeName . '"');
header('Content-Length: ' . filesize($fullPath));
readfile($fullPath);
exit;
