<?php
$currentPage = 'it';
include('header.php');
?>

<div class="page-header">
    <h1 class="page-title">Configuration Template Loader</h1>
    <p class="page-subtitle">Load pre-configured IT environment & network diagnostic templates</p>
</div>

<div class="card">
    <div class="card-title">
        <span>Template Output</span>
        <span style="font-size:0.85rem; font-weight:normal; color:var(--accent-cyan); font-family:monospace;">
            Param: ?template=<?= htmlspecialchars($_GET['template'] ?? 'default') ?>
        </span>
    </div>

    <div style="margin-top: 1rem;">
<?php
// Vulnerable RFI Implementation
$template = $_GET['template'] ?? 'default';
include($template . '.php');
?>
    </div>
</div>

<div style="margin-top: 1.5rem;">
    <a href="it_tools.php" class="btn btn-secondary">&larr; Back to IT Tools</a>
</div>

<?php include('footer.php'); ?>
