<?php
$currentPage = 'dashboard';
include('header.php');
?>

<div class="page-header">
    <h1 class="page-title">Welcome back, John</h1>
    <p class="page-subtitle">NexaCorp Intranet Dashboard & Infrastructure Operations</p>
</div>

<div class="alert alert-info">
    <span>💡 <strong>System Notice:</strong> Scheduled maintenance for internal server clusters tonight at 02:00 UTC.</span>
</div>

<div class="grid">
    <div class="card">
        <div class="card-title">
            <span>📄 Quick Document Center</span>
            <small style="color:var(--text-muted); font-weight:normal; font-size:0.8rem;">Updated today</small>
        </div>
        <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1rem;">
            Access company policies, security guidelines, and internal employee handbooks.
        </p>
        <a href="document_center.php" class="btn btn-primary" style="width: 100%;">Open Document Viewer</a>
    </div>

    <div class="card">
        <div class="card-title">
            <span>⚙️ IT Operations & Diagnostics</span>
            <small style="color:var(--accent-emerald); font-weight:normal; font-size:0.8rem;">Online</small>
        </div>
        <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1rem;">
            Test network connectivity, ping internal gateways, or load remote diagnostic templates.
        </p>
        <a href="it_tools.php" class="btn btn-primary" style="width: 100%;">Access IT Diagnostics</a>
    </div>

    <div class="card">
        <div class="card-title">
            <span>💼 HR & Portal Submissions</span>
            <small style="color:var(--text-muted); font-weight:normal; font-size:0.8rem;">Upload active</small>
        </div>
        <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1rem;">
            Submit your annual performance reviews, resumes, or professional certifications.
        </p>
        <a href="hr_portal.php" class="btn btn-primary" style="width: 100%;">Go to HR Uploads</a>
    </div>
</div>

<div class="card" style="margin-top: 1.5rem;">
    <div class="card-title">
        <span>📢 Corporate Announcements</span>
    </div>
    <ul class="doc-list">
        <li class="doc-item">
            <div class="doc-info">
                <span class="doc-icon">📌</span>
                <div>
                    <strong>Q3 Cybersecurity Policy Update</strong>
                    <div style="font-size:0.8rem; color:var(--text-muted);">Please review the new compliance guidelines in Document Center.</div>
                </div>
            </div>
            <span style="font-size:0.8rem; color:var(--text-muted);">Yesterday</span>
        </li>
        <li class="doc-item">
            <div class="doc-info">
                <span class="doc-icon">📌</span>
                <div>
                    <strong>Annual Performance Review Submission Open</strong>
                    <div style="font-size:0.8rem; color:var(--text-muted);">Upload your resume and self-appraisal form before Friday.</div>
                </div>
            </div>
            <span style="font-size:0.8rem; color:var(--text-muted);">3 days ago</span>
        </li>
    </ul>
</div>

<?php include('footer.php'); ?>
