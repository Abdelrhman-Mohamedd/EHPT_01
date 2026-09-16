<?php
/**
 * flag_engine.php — Dynamic Flag Generation & Exploit Detection Engine
 *
 * Flags are derived deterministically in PHP memory from:
 *   hash('sha256', STUDENT_ID . '_' . VULN_TYPE . '_' . SECRET_SALT)[0:32]
 *
 * This matches the derivation in setup.sh (sha256sum) and
 * generate_student_flags.py (hashlib.sha256) so instructor verification
 * tools continue to work unchanged.
 *
 * NO flags are written to disk. The secret salt is read from
 * /etc/lab01.conf (root:lab01 640), accessible to PHP-FPM (user lab01).
 */

/**
 * Load the secret salt from the protected config file.
 *
 * @return string The secret salt
 */
function _lab01_load_salt(): string {
    static $cached = null;
    if ($cached !== null) {
        return $cached;
    }

    $saltFile = '/etc/lab01.conf';
    if (!file_exists($saltFile)) {
        // Development/testing fallback — check relative to project root
        $saltFile = __DIR__ . '/../.lab_salt';
    }
    if (file_exists($saltFile) && is_readable($saltFile)) {
        $cached = trim(file_get_contents($saltFile));
        return $cached;
    }

    // Last-resort default (should never be reached in production)
    $cached = 'EHPT01_SECRET_SALT_2026';
    return $cached;
}

/**
 * Generate a deterministic flag for the given vulnerability type.
 *
 * @param string $vuln_type One of: LFI, RFI, PATHTRAV, UPLOAD, CMDI
 * @return string The flag string, e.g. FLAG{5b03425554da4aede733fb9f1fcf83b7}
 */
function generate_flag(string $vuln_type): string {
    $salt = _lab01_load_salt();
    $studentId = $GLOBALS['STUDENT_ID'] ?? 'UNKNOWN';
    $seed = "{$studentId}_{$vuln_type}_{$salt}";
    $hash = substr(hash('sha256', $seed), 0, 32);
    return "FLAG{{$hash}}";
}

/**
 * Detect whether the user-supplied input contains an exploit payload
 * matching the given vulnerability type.
 *
 * @param string $vuln_type One of: LFI, RFI, PATHTRAV, UPLOAD, CMDI
 * @param string $input     The user-supplied input to inspect
 * @return bool True if a malicious payload pattern is detected
 */
function detect_exploit(string $vuln_type, string $input): bool {
    switch ($vuln_type) {
        case 'LFI':
            // Directory traversal sequences, PHP stream wrappers, null bytes
            return (
                strpos($input, '../') !== false ||
                strpos($input, '..\\') !== false ||
                stripos($input, 'php://') !== false ||
                stripos($input, 'file://') !== false ||
                stripos($input, 'data://') !== false ||
                stripos($input, 'expect://') !== false ||
                stripos($input, 'zip://') !== false ||
                strpos($input, "\0") !== false ||
                stripos($input, '%00') !== false ||
                stripos($input, '%2e%2e') !== false ||
                stripos($input, '..%2f') !== false ||
                stripos($input, '..%5c') !== false
            );

        case 'RFI':
            // Remote URL schemes
            return (
                (bool) preg_match('#^https?://#i', $input) ||
                (bool) preg_match('#^ftp://#i', $input) ||
                (bool) preg_match('#^//[a-zA-Z0-9]#', $input)
            );

        case 'PATHTRAV':
            // Directory traversal in file download context
            return (
                strpos($input, '../') !== false ||
                strpos($input, '..\\') !== false ||
                stripos($input, '%2e%2e') !== false ||
                stripos($input, '..%2f') !== false ||
                stripos($input, '..%5c') !== false ||
                stripos($input, '%2e%2e%2f') !== false
            );

        case 'UPLOAD':
            // Executable PHP extensions in the filename
            $ext = strtolower(pathinfo($input, PATHINFO_EXTENSION));
            return in_array($ext, [
                'php', 'phtml', 'phar', 'php3', 'php4', 'php5', 'php7', 'phps',
                'php-s', 'pht', 'pgif', 'shtml'
            ], true);

        case 'CMDI':
            // Shell metacharacters, command chaining, and substitution
            return (
                (bool) preg_match('/[;|&`\n\r]/', $input) ||
                strpos($input, '$(') !== false ||
                strpos($input, '${') !== false
            );

        default:
            return false;
    }
}

/**
 * Check if an uploaded file's content contains PHP code signatures.
 *
 * @param string $filePath Path to the uploaded temp file
 * @return bool True if PHP code patterns are found
 */
function detect_php_in_content(string $filePath): bool {
    if (!file_exists($filePath) || !is_readable($filePath)) {
        return false;
    }
    // Read first 8KB to check for PHP opening tags
    $content = file_get_contents($filePath, false, null, 0, 8192);
    return (
        strpos($content, '<?php') !== false ||
        strpos($content, '<?=') !== false ||
        strpos($content, '<? ') !== false ||
        strpos($content, "<?\\n") !== false
    );
}

