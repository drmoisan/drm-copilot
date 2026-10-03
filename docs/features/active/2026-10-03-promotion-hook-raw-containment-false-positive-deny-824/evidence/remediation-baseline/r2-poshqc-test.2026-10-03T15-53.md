# r2 P0-T13 full Pester baseline with coverage

Timestamp: 2026-10-03T15-53
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path' *> "$Scratch/r2-pester-baseline.log"; $LASTEXITCODE (step script SCRATCH/steps/r2-p0-t13.ps1; then Copy-Item artifacts/pester/powershell-coverage.xml to SCRATCH/r2-baseline-coverage.xml and the JUnit totals and FAILED lines from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary:
- Run exit code: 0
- tests=6753 failures=0 errors=0
- FAILED lines: none
- BASELINE-PESTER-FAILURES: empty
- The coverage XML was copied to SCRATCH/r2-baseline-coverage.xml for P0-T14.
