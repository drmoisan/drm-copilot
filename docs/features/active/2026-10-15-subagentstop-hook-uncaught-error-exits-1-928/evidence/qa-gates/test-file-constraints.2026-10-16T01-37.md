# Test-File Constraints (issue #928)

Timestamp: 2026-10-16T01-37
Command: grep -c -F -e TestDrive -e New-TemporaryFile -e Start-Process -e GetTempPath -e "env:" tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1

Second command: grep -c -F "simulated unhandled error (issue #928)" tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 (EXIT_CODE 0)

Output Summary:
- Prohibited-construct count: 0 (grep exit 1, no match)
- Simulated-error token count: 2
- File length: 124 lines (`wc -l`); the Write tool accepted the file without a check-powershell-test-purity.ps1 denial.
