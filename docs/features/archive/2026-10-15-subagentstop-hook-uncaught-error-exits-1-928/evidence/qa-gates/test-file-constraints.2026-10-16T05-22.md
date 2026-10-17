# Test-File Constraints (remediation cycle 1, P1-T6)

Timestamp: 2026-10-16T05-22
Command: grep -c -F -e TestDrive -e New-TemporaryFile -e Start-Process -e GetTempPath -e "env:" tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Banned-token count: 0 (grep exits 1 when nothing matches)
- Command: wc -l tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 -> 159 (N_UNCAUGHT 134 + 25; at most 500)
