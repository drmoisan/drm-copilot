# Scope Anchor (Issue #1080, remediation cycle 1, P0-T2)

Timestamp: 2026-11-05T23-37
Command: sh SCRATCH/issue-1080-lines.sh (git fetch -q origin; MB = git merge-base origin/main HEAD; git status --porcelain; git diff --name-only MB HEAD filtered to paths outside docs/features/; @(Get-Content -LiteralPath <path>).Count per change-set file)
EXIT_CODE: 0

## Merge base

MB = 02fb8aada3b10aaf3ac6812e29400c2302a3b372 (merge base of origin/main and HEAD after fetch).

## Working tree

`git status --porcelain` printed nothing (empty).

## Diff outside docs/features/ (MB to HEAD)

- scripts/dev-tools/Get-EpicProgressReport.Logic.ps1
- scripts/dev-tools/Get-EpicProgressReport.ps1
- tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
- tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1

Exactly the four change-set files.

## Launchers (launcher contract)

| Launcher | Disposition |
|---|---|
| `SCRATCH/issue-1080-run.sh` | Recreated: the earlier copy delegated to a separate script file; the new copy carries its PowerShell program inside the `.sh` file, takes `<log> <seed or -1> <paths...>`, and prints `TOTAL`, the `SEED`/`ORDER` lines when shuffled, `FILE` lines, and `TEST` failure lines. |
| `SCRATCH/issue-1080-format-check.sh` | Recreated: the earlier copy took one comma-separated argument; the new copy takes `<files...>` and prints `FORMAT-DIFF-COUNT=<n>`. |
| `SCRATCH/issue-1080-pssa.sh` | Recreated: same argument change; prints `PSSA-FINDINGS=<n>`. |
| `SCRATCH/issue-1080-cov.sh` | Created (absent): imports `scripts/powershell/PoshQC/PoshQC.psd1`, calls `Invoke-PoshQCTest -ScanFolders tests/scripts/dev-tools` with an `-InvokePester` seam (JUnit and exit disabled, PassThru enabled), and prints `COVERAGE` and `MISSED` lines from `artifacts/pester/powershell-coverage.xml`. |

No `.ps1` file was written to SCRATCH in this cycle. One `.ps1` file left by the earlier cycle remains in SCRATCH and is not used by any recreated launcher.

## Physical line counts

| File | Lines |
|---|---|
| scripts/dev-tools/Get-EpicProgressReport.ps1 | 456 |
| scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 | 653 |
| tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 | 426 |
| tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 | 560 |

Output Summary: MB derived; worktree clean; the MB..HEAD diff outside docs/features/ is exactly the four change-set files; four launchers recreated or created to the contract with no .ps1 written to SCRATCH; line counts 456, 653, 426, 560.
