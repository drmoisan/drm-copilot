# r2 P7-T2 full hook-suite run (no coverage)

Timestamp: 2026-10-03T16-20
Command: pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' -Path @('tests/scripts/claude-hooks', 'tests/scripts/codex-hooks') -JUnitPath '$Scratch/r2-hook-suites.junit.xml' -ExpectFailed 0 -MinPassed 243; exit `$LASTEXITCODE" *> "$Scratch/r2-hook-suites.log"; $LASTEXITCODE; then Select-String over the log for TOTALS, FAILED:, CONTAINER-ERROR:, and EXPECTATION-MISMATCH lines (step script SCRATCH/steps/r2-p7-t2.ps1). Suite selection of the poshqc / PowerShell hook suites (Linux) job, run locally on Windows.
EXIT_CODE: 0
Output Summary:
- TOTALS passed=3688 failed=0 skipped=0 notrun=0 total=3688 (passed at least 243)
- EXPECTATION-MISMATCHES=0; no FAILED:, CONTAINER-ERROR:, or EXPECTATION-MISMATCH: line
- No PRE-EXISTING-FAILURE occurred.
- The run covers every pre-existing wrapper deny pin (AC-16), the cycle-0 Issue824 rows of the pr-author, validate-bash, preimplementation, and epic-merge suites (AC-17 to AC-21), the signature pins (AC-29), and the Addendum 2 rows (AC-34). AC-34 rows observed on PASSED lines: F824-1 applies lower line and branch thresholds stated in the root CLAUDE.md; F824-2 falls back to the default floors when the root CLAUDE.md states no figures; F824-3 applies a line-only figure and keeps the default branch floor.
