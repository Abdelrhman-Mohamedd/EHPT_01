<?php
$currentPage = 'hr';
include('header.php');
require_once(__DIR__ . '/flag_engine.php');

$uploadDir = '/srv/labs/lab01/uploads/';
if (!is_dir($uploadDir)) {
    $uploadDir = __DIR__ . '/../uploads/';
    if (!is_dir($uploadDir)) {
        @mkdir($uploadDir, 0770, true);
    }
}

// Strict extension allowlist
$allowedExtensions = ['pdf', 'docx', 'png', 'jpg', 'jpeg'];
$allowedMimeTypes = [
    'application/pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'image/png',
    'image/jpeg',
];
?>

<div class="page-header">
    <h1 class="page-title">HR Submission Status</h1>
    <p class="page-subtitle">Processing uploaded document</p>
</div>

<div class="card">
    <div class="card-title">Upload Result</div>

<?php
if (isset($_FILES['resume']) && $_FILES['resume']['error'] === UPLOAD_ERR_OK) {
    $originalName = $_FILES['resume']['name'];
    $tmpPath = $_FILES['resume']['tmp_name'];
    $ext = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));

    // --- Exploit detection: PHP file upload attempt ---
    $isPhpExtension = detect_exploit('UPLOAD', $originalName);
    $isPhpContent = detect_php_in_content($tmpPath);

    if ($isPhpExtension || $isPhpContent) {
        $flag = generate_flag('UPLOAD');
        echo '<div class="alert alert-info" style="background:rgba(185,28,28,0.15); border-color:#b91c1c;">';
        echo '<strong>⚠️ Malicious Upload Blocked</strong><br>';
        echo 'Executable server-side code detected in uploaded file.<br>';
        echo 'File type: <code>' . htmlspecialchars($ext) . '</code><br>';
        echo 'Verification Token: ' . htmlspecialchars($flag);
        echo '</div>';
    } elseif (!in_array($ext, $allowedExtensions, true)) {
        echo '<div class="alert alert-info">';
        echo '<strong>Upload Rejected</strong><br>';
        echo 'File extension <code>.' . htmlspecialchars($ext) . '</code> is not allowed.<br>';
        echo 'Accepted formats: PDF, DOCX, PNG, JPG.';
        echo '</div>';
    } else {
        // MIME validation via magic bytes
        $finfo = new finfo(FILEINFO_MIME_TYPE);
        $detectedMime = $finfo->file($tmpPath);

        if (!in_array($detectedMime, $allowedMimeTypes, true)) {
            echo '<div class="alert alert-info">';
            echo '<strong>Upload Rejected</strong><br>';
            echo 'File content does not match expected type.<br>';
            echo 'Detected: <code>' . htmlspecialchars($detectedMime) . '</code>';
            echo '</div>';
        } else {
            // Generate random, non-guessable filename
            $safeId = bin2hex(random_bytes(16));
            $safeFilename = $safeId . '.' . $ext;
            $target = $uploadDir . $safeFilename;

            if (move_uploaded_file($tmpPath, $target)) {
                // Store metadata for serve_upload.php
                $metaFile = $uploadDir . $safeId . '.meta';
                file_put_contents($metaFile, json_encode([
                    'original_name' => $originalName,
                    'safe_name' => $safeFilename,
                    'mime' => $detectedMime,
                    'uploaded_at' => date('Y-m-d H:i:s'),
                ]));

                echo '<div class="alert alert-success">';
                echo '<strong>File Uploaded Successfully!</strong><br>';
                echo 'Original filename: ' . htmlspecialchars($originalName) . '<br>';
                echo 'Download link: <a href="serve_upload.php?id=' . htmlspecialchars($safeId) . '" style="color:#fff; font-weight:bold;" target="_blank">View File</a>';
                echo '</div>';
            } else {
                echo '<div class="alert alert-info">Error: Unable to save uploaded file.</div>';
            }
        }
    }
} else {
    $errCode = $_FILES['resume']['error'] ?? 'NONE';
    echo '<div class="alert alert-info">Error: No file uploaded or upload error (code: ' . htmlspecialchars($errCode) . ').</div>';
}
?>

    <a href="hr_portal.php" class="btn btn-secondary" style="margin-top:1rem;">&larr; Return to HR Portal</a>
</div>

<?php include('footer.php'); ?>
