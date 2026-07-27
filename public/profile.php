<?php
$currentPage = 'profile';
include('header.php');
?>

<div class="page-header">
    <h1 class="page-title">Employee Profile</h1>
    <p class="page-subtitle">Manage account details, view performance appraisals & download official reports</p>
</div>

<div class="grid">
    <div class="card">
        <div class="card-title">User Account Info</div>
        <div style="display:flex; align-items:center; gap:1.25rem; margin-bottom:1.5rem;">
            <div class="avatar" style="width:64px; height:64px; font-size:1.5rem;">JS</div>
            <div>
                <h3 style="font-size:1.2rem; color:#fff;">John Smith</h3>
                <p style="color:var(--text-muted); font-size:0.85rem;">Senior Systems Analyst — Infrastructure & Security</p>
                <p style="color:var(--accent-emerald); font-size:0.8rem; margin-top:0.25rem;">● Active Employee (ID: EMP-9402)</p>
            </div>
        </div>

        <div style="border-top:1px solid var(--border-color); padding-top:1rem; display:flex; flex-direction:column; gap:0.75rem; font-size:0.9rem;">
            <div><strong style="color:var(--text-muted);">Email:</strong> j.smith@nexacorp.local</div>
            <div><strong style="color:var(--text-muted);">Department:</strong> Information Technology</div>
            <div><strong style="color:var(--text-muted);">Location:</strong> Building B, Office 304</div>
            <div><strong style="color:var(--text-muted);">Security Clearance:</strong> Level 2 (Standard Internal)</div>
        </div>
    </div>

    <div class="card">
        <div class="card-title">Performance Reports & Appraisals</div>
        <p style="color:var(--text-muted); font-size:0.9rem; margin-bottom:1.25rem;">
            Official HR evaluation records and periodic performance reports available for download.
        </p>

        <ul class="doc-list">
            <li class="doc-item">
                <div class="doc-info">
                    <span class="doc-icon">📊</span>
                    <div>
                        <strong>Annual Evaluation Report (2025/2026)</strong>
                        <div style="font-size:0.8rem; color:var(--text-muted);">Format: PDF/Text</div>
                    </div>
                </div>
                <a href="download_report.php?file=report.pdf" class="btn btn-secondary" style="padding:0.4rem 0.8rem; font-size:0.8rem;">
                    Download Report
                </a>
            </li>
            <li class="doc-item">
                <div class="doc-info">
                    <span class="doc-icon">📊</span>
                    <div>
                        <strong>Q3 Performance Summary</strong>
                        <div style="font-size:0.8rem; color:var(--text-muted);">Format: PDF/Text</div>
                    </div>
                </div>
                <a href="download_report.php?file=q3_eval_2025.pdf" class="btn btn-secondary" style="padding:0.4rem 0.8rem; font-size:0.8rem;">
                    Download Report
                </a>
            </li>
        </ul>
    </div>
</div>

<?php include('footer.php'); ?>
