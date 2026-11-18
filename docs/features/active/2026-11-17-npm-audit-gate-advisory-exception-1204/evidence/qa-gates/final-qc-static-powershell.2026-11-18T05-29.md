# Final-QC static artifact, PowerShell (P3-T1)

Timestamp: 2026-11-18T05-29
Command: (1) Invoke-PoshQCFormat -ScanFolders scripts/ci, tests/scripts/ci, tests/scripts/workflows (writes in place; success observation is the count of `Formatted:` log lines); (2) Invoke-PoshQCAnalyze over the same folders with scripts/powershell/PoshQC/settings/pssa.settings.psd1; helper under SCRATCH launched with `sh`. Type check: not applicable (PowerShell).
EXIT_CODE: 0
Output Summary:
- Step 1 format: exit 0; `Formatted:` lines = 0 and `Already formatted:` lines = 29, so the final format pass rewrote no file; `git status --porcelain` shows no modification after the pass (tracked tree equal to the Phase 2 commit).
- Step 2 lint: exit 0; `PSScriptAnalyzer passed: no findings`, finding count 0 (Phase 0 baseline count for scripts/ci and tests/scripts/ci was also 0), so zero findings attributable to the new files.
- Step 3 type check: not applicable.
- Earlier loop restarts in this plan (analyzer findings on the new module at P1-T1, coverage-driven edits at P1-T6, the summary-text fix after P2-T5) each re-ran format and analyze from the start; this artifact is the clean final pass.
