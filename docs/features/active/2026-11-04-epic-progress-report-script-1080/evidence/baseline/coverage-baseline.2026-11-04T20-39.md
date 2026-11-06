# Coverage Baseline (Issue #1080, P0-T7)

Timestamp: 2026-11-04T20-39
Command: sh SCRATCH/issue-1080-cov.sh issue-1080-p0t7.log scripts/dev-tools/Get-EpicProgressReport.ps1,scripts/dev-tools/Get-EpicProgressReport.Logic.ps1,scripts/dev-tools/Invoke-ReleaseReconciliation.ps1
EXIT_CODE: 0

## Route

`SCRATCH/issue-1080-coverage.ps1` imports the branch-current module `scripts/powershell/PoshQC/PoshQC.psd1` and calls `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/dev-tools` with an `-InvokePester` seam that sets `TestResult.Enabled = $false`, `Run.Exit = $false`, and `Run.PassThru = $true` before calling Invoke-Pester. It then reads the JaCoCo file `artifacts/pester/powershell-coverage.xml` (package name plus source file name) and prints `COVERAGE <path> <percent>` for each named source (LINE counter, covered / (covered + missed)) or `COVERAGE-ABSENT <path>` for a source not in the XML.

The coverage population is derived by `Invoke-PoshQCTest` from `config/poshqc-coverage.json`, whose `roots` list contains `scripts` (along with `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.github/hooks`, `.codex/scripts`). No coverage-config edit is needed for files under `scripts/dev-tools`.

## Result

- Pester (seam): Tests=722 Passed=720 Failed=0 Skipped=2 NotRun=0
- Console: Covered 8% / 0%. 37,020 analyzed Commands in 271 Files.
- COVERAGE-ABSENT scripts/dev-tools/Get-EpicProgressReport.ps1
- COVERAGE-ABSENT scripts/dev-tools/Get-EpicProgressReport.Logic.ps1
- COVERAGE scripts/dev-tools/Invoke-ReleaseReconciliation.ps1 88.89 (covered=24 missed=3; uncovered lines are the entry-point block)

Output Summary: the route measures scripts/dev-tools per file (Invoke-ReleaseReconciliation.ps1 at 88.89% line coverage); the two new production files are COVERAGE-ABSENT because they do not exist yet; config/poshqc-coverage.json lists the root `scripts`.
