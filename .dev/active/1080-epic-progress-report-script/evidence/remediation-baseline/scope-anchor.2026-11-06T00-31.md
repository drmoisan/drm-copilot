# Scope Anchor - Remediation Cycle 2 (Issue 1080)

Timestamp: 2026-11-06T00-31
Command: sh SCRATCH/issue-1080-lines.sh (physical line counts with @(Get-Content -LiteralPath <path>).Count, git fetch, MB = git merge-base origin/main HEAD, git status --porcelain, git diff --name-only MB HEAD outside docs/features/)
EXIT_CODE: 0
Output Summary: MB derived; diff outside docs/features/ is exactly the four change-set files; porcelain lists only the P0-T1 plan check-off; logic file at 661 lines as expected.

## MB

`MB` was derived as the merge base of `origin/main` and `HEAD` after `git fetch` (recorded by derivation, not by identifier).

## git status --porcelain

The only entry is ` M docs/features/active/2026-11-04-epic-progress-report-script-1080/remediation-plan.2026-11-06T00-11.md`, which is the `[P0-T1]` check-off written after the P0-T1 commit was verified. It is committed with this task. No source or test file is modified or untracked.

## git diff --name-only MB HEAD, outside docs/features/

```
scripts/dev-tools/Get-EpicProgressReport.Logic.ps1
scripts/dev-tools/Get-EpicProgressReport.ps1
tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1
```

Exactly the four change-set files.

## Launchers

| Launcher | Disposition |
|---|---|
| `SCRATCH/issue-1080-run.sh` | reused (cycle-1 contract: `TOTAL`, `FILE`, `TEST` lines) |
| `SCRATCH/issue-1080-cov.sh` | reused (`COVERAGE`, `MISSED` lines) |
| `SCRATCH/issue-1080-format-check.sh` | reused (`FORMAT-DIFF-COUNT=`) |
| `SCRATCH/issue-1080-pssa.sh` | reused (`PSSA-FINDINGS=`) |
| `SCRATCH/issue-1080-lines.sh` | reused |
| `SCRATCH/issue-1080-scope.sh` | reused |
| `SCRATCH/issue-1080-commit.sh` | reused |
| `SCRATCH/issue-1080-kickoff-sweep.sh` | created in this task to the plan's launcher contract |

No `.ps1` file was written to SCRATCH in this cycle. Each launcher carries its PowerShell program inside the `.sh` file. (One `.ps1` file from the original delivery run predates cycle 1 and is not used by any cycle-2 launcher.)

## Physical line counts

| File | Lines |
|---|---|
| `scripts/dev-tools/Get-EpicProgressReport.ps1` | 474 |
| `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | 661 (expected 661) |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | 455 |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` | 601 |

## P2-T7 comparison reference

Lexicographically greatest existing `evidence/regression-testing/isolation-fresh-tests-scripts.*.md`: `isolation-fresh-tests-scripts.2026-11-06T00-01.md`.
