<?php
$currentPage = 'it';
include('header.php');
?>

<div class="page-header">
    <h1 class="page-title">IT Infrastructure Diagnostics & Tools</h1>
    <p class="page-subtitle">Internal systems connectivity testing & automated environment configuration loader</p>
</div>

<div class="grid">
    <!-- Network Ping Tool (Command Injection Vulnerability) -->
    <div class="card">
        <div class="card-title">
            <span>📡 Network Ping Utility</span>
            <small style="color:var(--accent-emerald); font-size:0.8rem; font-weight:normal;">Direct ICMP</small>
        </div>
        <p style="color:var(--text-muted); font-size:0.85rem; margin-bottom:1.25rem;">
            Send ICMP Echo requests to verify connectivity to external gateways or internal lab subnets.
        </p>

        <form action="network_diagnostics.php" method="POST">
            <div class="form-group">
                <label class="form-label" for="host">Target IP / Hostname</label>
                <input type="text" id="host" name="host" class="form-control" value="8.8.8.8" placeholder="e.g. 192.168.1.1 or 8.8.8.8" required>
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%;">
                Run Ping Diagnostic &rarr;
            </button>
        </form>
    </div>

    <!-- Configuration Loader Tool (RFI Vulnerability) -->
    <div class="card">
        <div class="card-title">
            <span>⚙️ Remote Config Template Loader</span>
            <small style="color:var(--accent-cyan); font-size:0.8rem; font-weight:normal;">Dynamic Include</small>
        </div>
        <p style="color:var(--text-muted); font-size:0.85rem; margin-bottom:1.25rem;">
            Load pre-built network templates or remote operational profiles into the diagnostic viewer.
        </p>

        <form action="config_loader.php" method="GET">
            <div class="form-group">
                <label class="form-label" for="template">Template Name or Remote Profile Path</label>
                <input type="text" id="template" name="template" class="form-control" value="default" placeholder="e.g. default" required>
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%;">
                Load Config Template &rarr;
            </button>
        </form>
    </div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div class="card-title">
        <span>📋 System Diagnostics Log</span>
    </div>
    <div style="font-family:monospace; font-size:0.85rem; color:var(--text-muted); line-height:1.6;">
        [08:12:04] Pool lab01 initialized on socket /run/php-fpm/lab01.sock<br>
        [08:14:22] ping process executed by user lab01 (pid 4102)<br>
        [08:15:00] Template loader requested default.php - HTTP 200 OK
    </div>
</div>

<?php include('footer.php'); ?>
