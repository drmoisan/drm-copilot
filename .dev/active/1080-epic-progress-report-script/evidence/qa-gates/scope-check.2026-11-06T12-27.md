# QA Gate: Scope Check (Issue #1080, remediation cycle 2, P2-T8)

Timestamp: 2026-11-06T12-27
Command: sh SCRATCH/issue-1080-scope-r2.sh (git fetch -q origin; MB = git merge-base origin/main HEAD; git diff --name-only MB filtered to paths outside docs/features/; git status --porcelain; .py count in git diff --name-only MB; cycle-2 start = parent of the commit whose subject carries "(R2 P0-T1)"; git diff <cycle-2 start> HEAD -- <FEATURE>/issue.md; AC lines of git diff MB -- <FEATURE>/issue.md)
EXIT_CODE: 0

## Merge base

MB was derived as the merge base of `origin/main` and `HEAD` after `git fetch` (recorded by derivation). It equals the merge base used by the cycle-1 scope check.

## Files outside docs/features/

`git diff --name-only MB` (worktree against MB, so uncommitted tracked changes are included):

- scripts/dev-tools/Get-EpicProgressReport.Logic.ps1
- scripts/dev-tools/Get-EpicProgressReport.ps1
- tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1
- tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1

`git status --porcelain` printed nothing, so no untracked or unstaged path adds to the list. Exactly the four change-set files; `.py` files in the MB diff: `PY-FILES=0`.

Cycle-2 files outside docs/features/ (diff from the cycle-2 start): `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` and `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1`. `scripts/dev-tools/Get-EpicProgressReport.ps1` is edited by P2-T9, which runs after this check.

## issue.md acceptance criteria

- `git diff MB -- docs/features/active/2026-11-04-epic-progress-report-script-1080/issue.md` shows the file as added by this branch (it does not exist at MB). Its `## Acceptance Criteria` lines are AC1 to AC9, all `- [x]`.
- The cycle-2 start is the parent of the `(R2 P0-T1)` commit. `git diff <cycle-2 start> HEAD -- docs/features/active/2026-11-04-epic-progress-report-script-1080/issue.md` printed nothing: this cycle made no change to `issue.md`, including `## Acceptance Criteria`.

Output Summary: outside docs/features/ the MB diff plus porcelain status lists exactly the four change-set files and no .py file; the issue.md diff from the cycle-2 start to HEAD is empty, so AC1 to AC9 are unchanged and remain checked.
