<?php
$currentPage = 'hr';
include('header.php');

$uploadDir = "/srv/labs/lab01/public/uploads/";
if (!is_dir($uploadDir)) {
    // Development/testing fallback
    $uploadDir = __DIR__ . "/uploads/";
    if (!is_dir($uploadDir)) {
        @mkdir($uploadDir, 0777, true);
    }
}
?>

<div class="page-header">
    <h1 class="page-title">HR Submission Status</h1>
    <p class="page-subtitle">Processing uploaded resume/certification file</p>
</div>

<div class="card">
    <div class="card-title">Upload Result</div>
    
<?php
// Vulnerable File Upload Implementation - Saves inside web root (public/uploads/)
if (isset($_FILES['resume']) && $_FILES['resume']['error'] === UPLOAD_ERR_OK) {
    $target = $uploadDir . basename($_FILES['resume']['name']);
    if (move_uploaded_file($_FILES['resume']['tmp_name'], $target)) {
        $filename = basename($_FILES['resume']['name']);
        echo "<div class='alert alert-success'>";
        echo "<strong>File Uploaded Successfully!</strong><br>";
        echo "Target destination: " . htmlspecialchars($target) . "<br>";
        echo "Web location: <a href='/uploads/" . htmlspecialchars($filename) . "' style='color:#fff; font-weight:bold;' target='_blank'>/uploads/" . htmlspecialchars($filename) . "</a>";
        echo "</div>";
    } else {
        echo "<div class='alert alert-info'>Error: Unable to save uploaded file to destination directory.</div>";
    }
} else {
    echo "<div class='alert alert-info'>Error: No file uploaded or upload error code: " . ($_FILES['resume']['error'] ?? 'NONE') . "</div>";
}
?>

    <a href="hr_portal.php" class="btn btn-secondary" style="margin-top:1rem;">&larr; Return to HR Portal</a>
</div>

<?php include('footer.php'); ?>
