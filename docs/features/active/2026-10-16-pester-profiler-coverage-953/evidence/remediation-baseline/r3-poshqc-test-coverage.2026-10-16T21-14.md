# r3 Full Pester Baseline with Coverage (P0-T20)

Timestamp: 2026-10-16T21-14
Command: FULL_RUN(baseline) through the Tool route in the background (SCRATCH/issue-953-r3-p0-t20.sh): export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; New-Item -ItemType Directory -Force -Path artifacts/pester | Out-Null; $start = [datetime]::UtcNow; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r3-baseline-poshqc.log'); $exit = $LASTEXITCODE; $end = [datetime]::UtcNow; "EXIT_CODE=$exit SECONDS=... START_UTC=..."; Copy-Item artifacts/pester/powershell-coverage.xml (Join-Path $S 'issue-953-r3-baseline-coverage.xml') -Force; Copy-Item artifacts/pester/pester-junit.xml (Join-Path $S 'issue-953-r3-baseline-junit.xml') -Force; exit $exit'; reduction with JRP and CRP in SCRATCH/issue-953-r3-p0-t20-2.sh.
EXIT_CODE: 0
Output Summary:
- Printed: EXIT_CODE=0 SECONDS=1040 START_UTC=2026-10-16T20:56:28.0396924Z
- FULL_RUN validity: (a) VALID_A=True (coverage and JUnit written after START_UTC); (b) exactly 1 `Code coverage population: source=config` line in the log; (c) no -ScanFolders and no -SettingsPath argument. Run valid.
- JRP: JUNIT_TESTS=10784 JUNIT_FAILURES=0 JUNIT_ERRORS=0 (no failed testcase).
- FULL_RUN wall seconds: 1040
- CRP: LINE_COVERED=17123 LINE_MISSED=1471 LINE_TOTAL=18594 LINE_PERCENT=92.09 SOURCEFILE_COUNT=208 (aggregate counter count 1, anchor count 1, no prefix mismatch, no duplicate key, per-file cross-check True); threshold (step 7) PASS.
- MOD_KEY (scripts/powershell/poshqc/poshqc.shard.psm1): covered=82 missed=0
- Result: PASS.

R3_BASELINE_JUNIT_TESTS: 10784
