<?php
$currentPage = 'it';
include('header.php');
require_once(__DIR__ . '/flag_engine.php');

$host = $_POST['host'] ?? '8.8.8.8';
$output = '';
$flagOutput = '';

// --- Input validation and exploit detection ---
$isValidIp = (bool) preg_match('/^\d{1,3}(\.\d{1,3}){3}$/', $host);
$isValidHostname = (bool) preg_match('/^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$/', $host);
$isExploit = detect_exploit('CMDI', $host);

if ($isExploit) {
    $flagOutput = generate_flag('CMDI');
    $output = "⚠️ Command Injection Detected\n\n" .
              "The submitted host value contains shell metacharacters.\n" .
              "Verification Token: {$flagOutput}\n";
} elseif (!$isValidIp && !$isValidHostname) {
    $output = "Error: Invalid host format. Please enter a valid IPv4 address or hostname.";
} else {
    // Safe execution via proc_open array form — no shell is invoked
    $descriptors = [
        0 => ['pipe', 'r'],  // stdin
        1 => ['pipe', 'w'],  // stdout
        2 => ['pipe', 'w'],  // stderr
    ];

    $proc = proc_open(['ping', '-c', '4', $host], $descriptors, $pipes);

    if (is_resource($proc)) {
        fclose($pipes[0]); // close stdin

        // Apply 10-second timeout to prevent DoS
        stream_set_timeout($pipes[1], 10);
        $result = stream_get_contents($pipes[1]);
        $meta = stream_get_meta_data($pipes[1]);

        fclose($pipes[1]);
        fclose($pipes[2]);

        if ($meta['timed_out']) {
            proc_terminate($proc, 9);
            $output = "Error: Diagnostic timed out after 10 seconds.";
        } else {
            $output = $result ?: "No output returned.";
        }

        proc_close($proc);
    } else {
        $output = "Error: Unable to execute diagnostic command.";
    }
}
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
<?= htmlspecialchars($output) ?>
    </div>

    <div style="margin-top:1.5rem;">
        <a href="it_tools.php" class="btn btn-secondary">&larr; Return to IT Tools</a>
    </div>
</div>

<?php include('footer.php'); ?>
