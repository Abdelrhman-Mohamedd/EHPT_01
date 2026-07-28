<?php
// Header component for NexaCorp Employee Portal
require_once(__DIR__ . '/student_config.php');

if (!isset($currentPage)) {
    $currentPage = 'dashboard';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NexaCorp Enterprise Portal (Lab01 - <?= htmlspecialchars($GLOBALS['STUDENT_ID']) ?>)</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <nav class="navbar">
        <a href="index.php" class="brand">
            <div class="brand-logo">N</div>
            <span>NexaCorp Portal</span>
        </a>
        <ul class="nav-links">
            <li class="nav-item"><a href="index.php" class="<?= $currentPage === 'dashboard' ? 'active' : '' ?>">Dashboard</a></li>
            <li class="nav-item"><a href="document_center.php" class="<?= $currentPage === 'documents' ? 'active' : '' ?>">Document Center</a></li>
            <li class="nav-item"><a href="hr_portal.php" class="<?= $currentPage === 'hr' ? 'active' : '' ?>">HR Portal</a></li>
            <li class="nav-item"><a href="it_tools.php" class="<?= $currentPage === 'it' ? 'active' : '' ?>">IT Tools</a></li>
            <li class="nav-item"><a href="profile.php" class="<?= $currentPage === 'profile' ? 'active' : '' ?>">My Profile</a></li>
        </ul>
        <div class="user-badge">
            <div class="avatar">ID</div>
            <div class="user-info">
                <div class="user-name"><?= htmlspecialchars($GLOBALS['STUDENT_ID']) ?></div>
                <div class="user-role">Lab01 Instance Boundary</div>
            </div>
        </div>
    </nav>
    <div class="container">
