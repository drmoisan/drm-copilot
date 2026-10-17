# r3 Final Full Pester Run with Coverage (P5-T3)

Timestamp: 2026-10-16T22-25
Command: FULL_RUN(final) through the Tool route in the background (SCRATCH/issue-953-r3-p5-t3.sh): export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; New-Item -ItemType Directory -Force -Path artifacts/pester | Out-Null; $start = [datetime]::UtcNow; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r3-final-poshqc.log'); $exit = $LASTEXITCODE; ...; Copy-Item artifacts/pester/powershell-coverage.xml (Join-Path $S 'issue-953-r3-final-coverage.xml') -Force; Copy-Item artifacts/pester/pester-junit.xml (Join-Path $S 'issue-953-r3-final-junit.xml') -Force; exit $exit'; reduction (validity, JRP, token checks, CRP) in SCRATCH/issue-953-r3-p5-t3-2.sh.
EXIT_CODE: 0
Output Summary:
- Printed: EXIT_CODE=0 SECONDS=1025 START_UTC=2026-10-16T22:07:46.1422365Z
- FULL_RUN validity: (a) VALID_A=True; (b) exactly 1 `Code coverage population: source=config` line; (c) no -ScanFolders and no -SettingsPath. Run valid.
- JRP: JUNIT_TESTS=10787 JUNIT_FAILURES=0 JUNIT_ERRORS=0 (AC-07: zero failed tests); R3_BASELINE_JUNIT_TESTS 10784 + 3 = 10787.
- Token checks: 48 tokens (18 R3_SHARD_OLD_TOKENS, 3 R3_NEW_TOKENS, 4 GUARD_TOKENS, 23 CYCLE2_TOKENS), each hits=1 PASS; TOKEN_FAILURES=0.
- FULL_RUN wall seconds: 1025
- CRP: LINE_COVERED=17136 LINE_MISSED=1471 LINE_TOTAL=18607 LINE_PERCENT=92.09 SOURCEFILE_COUNT=208 (aggregate count 1, anchor count 1, no prefix mismatch, no duplicate key, cross-check True); threshold PASS.
- MOD_KEY (scripts/powershell/poshqc/poshqc.shard.psm1): covered=95 missed=0
- Result: PASS.

R3_FINAL_JUNIT_TESTS: 10787
