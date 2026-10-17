# Canonical PowerShell Coverage Artifact Figures (P4-T2, RF-3)

Timestamp: 2026-09-30T02-23
Command: sh SCRATCH/run-ps.sh SCRATCH/coverage-xml-files.ps1 -CoverageXml artifacts/pester/powershell-coverage.xml -FileName WorktreeRunResolution.psm1,enforce-epic-merge-gate-resolution.ps1,enforce-epic-worktree-removal-gate-resolution.ps1; sh SCRATCH/run-ps.sh SCRATCH/junit-summary.ps1 -JUnitXml artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary:
- COVERAGE-XML-MTIME-UTC=2026-09-30T02:22:26Z (later than the P3-T6 commit 5e783d51 at 2026-09-30T02:12:21Z)
- XML-COVERAGE file=WorktreeRunResolution.psm1 Covered=149 Missed=0 LinePercent=100
- XML-COVERAGE file=enforce-epic-merge-gate-resolution.ps1 Covered=32 Missed=4 LinePercent=88.89
- XML-COVERAGE file=enforce-epic-worktree-removal-gate-resolution.ps1 Covered=22 Missed=1 LinePercent=95.65
- JUNIT TotalCount=5831 FailedCount=0; no JUNIT-FAILED lines.
- All three files are present and each is at least 85; the canonical artifact now carries the three files that CR-3 reported missing.
