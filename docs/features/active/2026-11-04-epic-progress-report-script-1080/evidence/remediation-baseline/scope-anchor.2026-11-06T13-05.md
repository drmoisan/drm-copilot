# Scope Anchor — Issue 1080 remediation cycle 3

Timestamp: 2026-11-06T13-05
Task: P0-T2
Command: sh SCRATCH/issue-1080-lines.sh (fetches origin; derives MB = git merge-base origin/main HEAD; prints git status --porcelain; prints git diff --name-only MB HEAD outside docs/features/; counts physical lines with @(Get-Content -LiteralPath <path>).Count)
EXIT_CODE: 0
Output Summary: Tree clean; diff outside docs/features/ is exactly the four change-set files; line counts 475 / 670 / 455 / 651 as expected; eight launchers reused unchanged.

## Merge base

- MB: `02fb8aada3b10aaf3ac6812e29400c2302a3b372` (merge base of `origin/main` and `HEAD`)
- Cycle-3 start (parent of the P0-T1 commit): `deee4394b0e859ef3c2781d053e3417bc27ddf71`

## git status --porcelain

Empty.

## git diff --name-only MB HEAD (outside docs/features/)

- `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`
- `scripts/dev-tools/Get-EpicProgressReport.ps1`
- `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1`
- `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`

## Launchers

Reused unchanged (all eight present under SCRATCH): `issue-1080-run.sh`, `issue-1080-cov.sh`, `issue-1080-format-check.sh`, `issue-1080-pssa.sh`, `issue-1080-lines.sh`, `issue-1080-scope.sh`, `issue-1080-commit.sh`, `issue-1080-kickoff-sweep.sh`. None recreated; no `.ps1` file written to SCRATCH.

## Physical line counts

| File | Lines | Expected |
|---|---|---|
| `scripts/dev-tools/Get-EpicProgressReport.ps1` | 475 | 475 |
| `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | 670 | 670 |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | 455 | 455 |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` | 651 | 651 |

## P2-T7 comparison reference

Lexicographically greatest `evidence/regression-testing/isolation-fresh-tests-scripts.*.md`: `isolation-fresh-tests-scripts.2026-11-06T12-26.md`.
