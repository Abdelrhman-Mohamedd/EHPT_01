<?php
$currentPage = 'it';
include('header.php');

// Vulnerable Command Injection Implementation
$host = $_POST['host'] ?? '8.8.8.8';
?>

<div class="page-header">
    <h1 class="page-title">Network Diagnostics Execution</h1>
    <p class="page-subtitle">Executing ICMP ping diagnostic probe</p>
</div>

<div class="card">
    <div class="card-title">
        <span>Diagnostic Terminal Output</span>
        <span style="font-size:0.85rem; font-weight:normal; color:var(--accent-cyan); font-family:monospace;">
            Target Host: <?= htmlspecialchars($host) ?>
        </span>
    </div>

    <div class="terminal-box">
<?php
// Direct Command Injection Execution
$output = shell_exec("ping -c 4 " . $host);
echo htmlspecialchars($output ?: "No output returned or command executed silently.");
?>
    </div>

    <div style="margin-top:1.5rem;">
        <a href="it_tools.php" class="btn btn-secondary">&larr; Return to IT Tools</a>
    </div>
</div>

<?php include('footer.php'); ?>
