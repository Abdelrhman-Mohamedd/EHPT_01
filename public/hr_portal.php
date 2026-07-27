<?php
$currentPage = 'hr';
include('header.php');
?>

<div class="page-header">
    <h1 class="page-title">HR Submission & Document Upload Portal</h1>
    <p class="page-subtitle">Submit updated resumes, certifications, or performance self-appraisals to Human Resources</p>
</div>

<div class="grid">
    <div class="card">
        <div class="card-title">Document Submission Form</div>
        <form action="upload_resume.php" method="POST" enctype="multipart/form-data">
            <div class="form-group">
                <label class="form-label" for="fullname">Employee Full Name</label>
                <input type="text" id="fullname" name="fullname" class="form-control" value="John Smith" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="empid">Employee ID</label>
                <input type="text" id="empid" name="empid" class="form-control" value="EMP-9402" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="doc_type">Submission Category</label>
                <select id="doc_type" name="doc_type" class="form-control">
                    <option value="resume">Updated Resume / CV</option>
                    <option value="cert">Professional Certification</option>
                    <option value="appraisal">Annual Self-Appraisal Form</option>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label" for="resume">Select File (PDF, DOCX, or Image)</label>
                <input type="file" id="resume" name="resume" class="form-control" required style="padding:0.5rem;">
            </div>

            <button type="submit" class="btn btn-primary" style="width:100%; margin-top:0.5rem;">
                Upload Submission &rarr;
            </button>
        </form>
    </div>

    <div class="card">
        <div class="card-title">Submission Instructions & Guidelines</div>
        <ul style="color:var(--text-muted); font-size:0.9rem; margin-left:1.2rem; line-height:1.7;">
            <li>All files uploaded will be assigned to your HR profile folder.</li>
            <li>Make sure your document filename matches standard corporate naming conventions (e.g. <code>John_Smith_Resume.pdf</code>).</li>
            <li>Files are saved to the internal server storage directory <code>/srv/labs/lab01/uploads/</code> for reviewer auditing.</li>
            <li>Maximum allowable file size per upload: 10MB.</li>
        </ul>

        <div class="alert alert-info" style="margin-top:1.5rem;">
            📌 <strong>Need assistance?</strong> Contact the HR operations team at <code>hr-portal@nexacorp.local</code>.
        </div>
    </div>
</div>

<?php include('footer.php'); ?>
