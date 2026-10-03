# r3 P0-T13 full Pester baseline with coverage (issue #824)

Timestamp: 2026-10-03T18-50
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path' *> "$Scratch/r3-pester-baseline.log"; $LASTEXITCODE (inside SCRATCH/steps/r3-p0-t13.ps1, run in the background; then Copy-Item artifacts/pester/powershell-coverage.xml to SCRATCH/r3-baseline-coverage.xml; JUnit totals and FAILED: lines from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary:
TS=2026-10-03T18-50
0
tests=6826 failures=0 errors=0
No FAILED: lines.
P0-T13 tests count: 6826.
BASELINE-PESTER-FAILURES: empty.
