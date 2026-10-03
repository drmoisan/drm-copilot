# r1 P0-T13 — full Pester baseline with coverage

Timestamp: 2026-10-03T12-43
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t13.ps1 -Worktree WORKTREE; step script runs `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path' *> "$Scratch/r1-pester-baseline.log"; $LASTEXITCODE`, then copies artifacts/pester/powershell-coverage.xml to SCRATCH/r1-baseline-coverage.xml and reads artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCTest child exit code: 0
- tests=6626 failures=0 errors=0
- No `FAILED:` line. BASELINE-PESTER-FAILURES = (empty).
- Coverage report copied to SCRATCH/r1-baseline-coverage.xml for P0-T14.
