<?php
$currentPage = 'documents';
include('header.php');
require_once(__DIR__ . '/flag_engine.php');

$doc = $_GET['doc'] ?? 'welcome';

// Fixed allowlist: request keys → real filenames
$allowed = [
    'welcome'    => 'welcome.txt',
    'policy'     => 'policy.pdf',
    'guidelines' => 'security_guidelines.txt',
];

$baseDir = '/srv/labs/lab01/data/documents';
if (!is_dir($baseDir)) {
    $baseDir = __DIR__ . '/../data/documents';
}
$baseDir = realpath($baseDir);
?>

<div class="page-header">
    <h1 class="page-title">Document Center</h1>
    <p class="page-subtitle">Browse and inspect official internal corporate documentation</p>
</div>

<div class="grid" style="grid-template-columns: 300px 1fr;">
    <div class="card">
        <div class="card-title">Available Files</div>
        <ul class="doc-list">
            <li class="doc-item">
                <a href="document_center.php?doc=welcome" style="color:var(--text-main); text-decoration:none;">📄 Employee Onboarding Guide</a>
            </li>
            <li class="doc-item">
                <a href="document_center.php?doc=policy" style="color:var(--text-main); text-decoration:none;">📄 Corporate Use Policy</a>
            </li>
            <li class="doc-item">
                <a href="document_center.php?doc=guidelines" style="color:var(--text-main); text-decoration:none;">📄 Security Guidelines</a>
            </li>
        </ul>
    </div>

    <div class="card">
        <div class="card-title">
            <span>Document Preview</span>
            <span style="font-size:0.85rem; font-weight:normal; color:var(--accent-cyan); font-family:monospace;">
                Param: ?doc=<?= htmlspecialchars($doc) ?>
            </span>
        </div>
        <div style="background: rgba(15, 23, 42, 0.8); border:1px solid var(--border-color); border-radius:var(--radius-sm); padding: 1.25rem; font-family: monospace; white-space: pre-wrap; color: #e2e8f0; min-height: 250px;">
<?php
if (isset($allowed[$doc])) {
    // Legitimate request — serve via readfile (never include/eval)
    $filePath = $baseDir . '/' . $allowed[$doc];
    $resolved = realpath($filePath);
    if ($resolved !== false && str_starts_with($resolved, $baseDir) && is_file($resolved)) {
        echo htmlspecialchars(file_get_contents($resolved));
    } else {
        echo "Error: Document not found on server.";
    }
} elseif (detect_exploit('LFI', $doc)) {
    // Exploit payload detected — emit flag
    echo "⚠️ Security Violation Detected\n\n";
    echo "The requested document path has triggered a security alert.\n";
    echo "Verification Token: " . generate_flag('LFI') . "\n";
} else {
    echo "Error: Document '" . htmlspecialchars($doc) . "' is not available.\nPlease select a document from the sidebar.";
}
?>
        </div>
    </div>
</div>

<?php include('footer.php'); ?>
