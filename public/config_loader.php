<?php
$currentPage = 'it';
include('header.php');
require_once(__DIR__ . '/flag_engine.php');

$template = $_GET['template'] ?? 'default';

// Fixed allowlist: only known-safe local templates
$allowed_templates = [
    'default' => 'default.php',
];
?>

<div class="page-header">
    <h1 class="page-title">Configuration Template Loader</h1>
    <p class="page-subtitle">Load pre-configured IT environment templates</p>
</div>

<div class="card">
    <div class="card-title">
        <span>Template Output</span>
        <span style="font-size:0.85rem; font-weight:normal; color:var(--accent-cyan); font-family:monospace;">
            Param: ?template=<?= htmlspecialchars($template) ?>
        </span>
    </div>

    <div style="margin-top: 1rem;">
<?php
if (isset($allowed_templates[$template])) {
    // Legitimate template — safe local include
    $templateFile = __DIR__ . '/' . $allowed_templates[$template];
    if (file_exists($templateFile)) {
        include($templateFile);
    } else {
        echo '<div class="alert alert-info">Error: Template file not found on server.</div>';
    }
} elseif (detect_exploit('RFI', $template)) {
    // Remote URL detected — emit RFI flag
    echo '<div class="alert alert-info" style="background:rgba(185,28,28,0.15); border-color:#b91c1c;">';
    echo '<strong>⚠️ Remote Resource Blocked</strong><br>';
    echo 'Attempted remote template inclusion detected.<br>';
    echo 'Verification Token: ' . generate_flag('RFI');
    echo '</div>';
} elseif (detect_exploit('LFI', $template)) {
    // Local traversal attempt on template loader
    echo '<div class="alert alert-info" style="background:rgba(185,28,28,0.15); border-color:#b91c1c;">';
    echo '<strong>⚠️ Path Violation Detected</strong><br>';
    echo 'Verification Token: ' . generate_flag('LFI');
    echo '</div>';
} else {
    echo '<div class="alert alert-info">Error: Template \'' . htmlspecialchars($template) . '\' is not available. Use \'default\'.</div>';
}
?>
    </div>
</div>

<div style="margin-top: 1.5rem;">
    <a href="it_tools.php" class="btn btn-secondary">&larr; Back to IT Tools</a>
</div>

<?php include('footer.php'); ?>
