# PowerShell Pester Baseline (issue #1006)

Timestamp: 2026-10-31T08-22
Task: P0-T7
Command: sh SCRATCH/issue-1006-pester-full.sh baseline (PowerShell 7 imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts, single process, coverage on)
EXIT_CODE: 0
Output Summary:
- Run started before any PowerShell production file was edited; tests completed in 894.95s.
- JUnit (`artifacts/pester/pester-junit.xml`, copied to SCRATCH): tests 13518, failures 0, errors 0, skipped 10.
- Pre-existing failing tests: none.
- Overall Pester command coverage: 92.74% over 34,069 analyzed commands in 256 files.
- Per-file line coverage from `artifacts/pester/powershell-coverage.xml` (JaCoCo LINE counters):
  - `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`: 100.00% (33/33)
  - `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`: 100.00% (80/80)
  - `.claude/lib/blast-radius/BlastRadiusNormalization.psm1`: 100.00% (51/51)
  - `.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1`: 100.00% (102/102)
  - `.claude/lib/blast-radius/BlastRadius.psm1`: 100.00% (107/107)
- Note: the run was launched before the two new test files existed, so neither is part of this baseline. Phase 3 PowerShell edits began after every suite that imports the blast-radius modules had finished (only the `codex-scripts`, `copilot-hooks`, `dev_tools`, `dev-tools`, `powershell`, and `workflows` folders remained, and none of them imports those modules). The line totals above match the pre-change files.
