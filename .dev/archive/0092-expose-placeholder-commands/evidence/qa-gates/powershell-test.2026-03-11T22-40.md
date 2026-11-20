Timestamp: 2026-03-11T22-40
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."
EXIT_CODE: 0
Output Summary:
- The PowerShell Pester suite completed successfully.
- Results: 222 passed, 0 failed, 7 skipped, 0 inconclusive, 0 not run.
- Coverage processing completed with `Covered 43.5% / 0%. 1,524 analyzed Commands in 16 Files.` and wrote the Koverage XML copy.

Key Output:
Starting discovery in 12 files.
Discovery found 229 tests in 232ms.
Tests completed in 4.64s
Tests Passed: 222, Failed: 0, Skipped: 7, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 43.5% / 0%. 1,524 analyzed Commands in 16 Files.
Wrote Koverage coverage copy: /workspaces/drm-copilot/././artifacts/pester/powershell-coverage.koverage.xml
