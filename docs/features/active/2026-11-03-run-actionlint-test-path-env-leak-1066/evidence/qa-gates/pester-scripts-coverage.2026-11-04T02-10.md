# Final QA: tests/scripts Single Process with Coverage, CI Shape (P4-T4)

Timestamp: 2026-11-04T02-10
Command: pwsh -NoProfile -File SCRATCH/issue-1066-poshqc-run.ps1 -Root <worktree> -ScanFolders tests/scripts -TestResultPath RAW/final-scripts.xml -CoverageOutputPath RAW/final-scripts-coverage.xml; comparison by SCRATCH/issue-1066-ps-compare.ps1 (against SCRATCH/issue-1066-PS_base.json, base total 13910) and SCRATCH/issue-1066-coverage.ps1 (against RAW/baseline-scripts-coverage.xml)
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- Pester: Passed=13310 Failed=594 Skipped=10 NotRun=0 (exit 1 from the pre-existing Linux host failures of #1067; APPROVED P0-T7 baseline: Passed=13070 Failed=830 Skipped=10, FailedBlocks=7).
- RAW/final-scripts.xml loads as XML: 497 containers (496 baseline plus GUARD); profile sums tests=13914 failed=594 blocks=0 container=0.
- Every container other than GUARD is within its PS_base profile: holds (496 containers compared, 0 outside).
- GUARD container (RCR 3): tests=4 failed=0 blocks=0 container=0, holds.
- Total: 13914 = 13910 (APPROVED P0-T7) + G (4), equal.
- Line coverage (JaCoCo LINE counters, 265 files in both runs, same file set, no per-file total differs, no file's covered count lower):
  - Overall: 21376 of 23279 = 91.83% (baseline 21303 of 23279 = 91.51%), not lower.
  - `scripts/dev-tools/run-actionlint.ps1`: 4 of 50 = 8.00% (baseline 4 of 50 = 8.00%), not lower. The low figure is identical to the baseline; it is likely due to TARGET loading the functions through the AST helper `Import-ScriptFunction` rather than dot-sourcing the script (not verified further, and outside this change).
- Acceptance: met.
