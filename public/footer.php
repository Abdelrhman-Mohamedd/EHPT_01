    </div> <!-- .container -->
    <footer>
        <p>&copy; <?= date('Y') ?> NexaCorp Internal Systems. All rights reserved. | Enterprise Portal v2.4.1</p>
        <p style="font-size:0.75rem; color:var(--text-muted); margin-top:0.3rem;">
            Assigned Student VM: <strong style="color:var(--accent-cyan);"><?= htmlspecialchars($GLOBALS['STUDENT_ID']) ?></strong> | Build Timestamp: <?= htmlspecialchars($GLOBALS['BUILD_TIME']) ?>
        </p>
    </footer>
</body>
</html>
