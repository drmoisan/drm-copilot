# Test-File Constraints (issue #928), rerun after the test-file correction

Timestamp: 2026-10-16T01-51
Command: grep -c -F -e TestDrive -e New-TemporaryFile -e Start-Process -e GetTempPath -e "env:" tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1

Second command: grep -c -F "simulated unhandled error (issue #928)" tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 (EXIT_CODE 0)

Output Summary:
- Prohibited-construct count: 0 (grep exit 1, no match)
- Simulated-error token count: 2
- File length: 132 lines (`wc -l`); the Edit tool accepted the change without a check-powershell-test-purity.ps1 denial.
- Reason for rerun: the first P1-T3 run showed that the epic-state isolation discovery guard (`enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, AC-4) required baseline null mocks for nine read seams in the new suite's loaded-source closure. The outermost `BeforeAll` now registers them with `Register-EpicStateBaselineMock`, in the form used by `hook-dependency-failure.Claude.Tests.ps1`.
