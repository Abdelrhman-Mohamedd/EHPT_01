<?php
$currentPage = 'documents';
include('header.php');

// Vulnerable Code Snippet (LFI):
$doc = $_GET['doc'] ?? 'welcome.txt';
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
                <a href="document_center.php?doc=welcome.txt" style="color:var(--text-main); text-decoration:none;">📄 welcome.txt</a>
            </li>
            <li class="doc-item">
                <a href="document_center.php?doc=policy.pdf" style="color:var(--text-main); text-decoration:none;">📄 policy.pdf</a>
            </li>
            <li class="doc-item">
                <a href="document_center.php?doc=security_guidelines.txt" style="color:var(--text-main); text-decoration:none;">📄 security_guidelines.txt</a>
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
// Vulnerable LFI Implementation - Document path resides outside web root in ../data/documents/
include("../data/documents/" . $doc);
?>
        </div>
    </div>
</div>

<?php include('footer.php'); ?>
