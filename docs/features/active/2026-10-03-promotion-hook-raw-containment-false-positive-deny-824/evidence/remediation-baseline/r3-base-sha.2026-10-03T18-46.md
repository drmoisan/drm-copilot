# r3 P0-T3 base SHA and pre-edit state (issue #824)

Timestamp: 2026-10-03T18-46
Command: pwsh -NoProfile -File "SCRATCH/steps/r3-p0-t3.ps1" -Worktree "WORKTREE" (git branch --show-current; git rev-parse HEAD; git merge-base --is-ancestor CODE_HEAD HEAD; git diff --quiet CODE_HEAD HEAD -- .claude/hooks .claude/lib .codex extensions/drm-copilot/resources tests scripts .github; git merge-base --is-ancestor MERGE_BASE HEAD; pre-untracked list to SCRATCH/pre-untracked.txt; git status --porcelain --untracked-files=all over the edited directories; VERDICT)
EXIT_CODE: 0
Output Summary:
TS=2026-10-03T18-46
bug/promotion-hook-raw-containment-false-positive-deny-824
32e9153773f9bedbfe64dbd5e5bf8909038e59cb
CODE-HEAD-ANCESTOR-EXIT=0
CODE-HEAD-DIFF-EXIT=0
MERGE-BASE-ANCESTOR-EXIT=0
PRE-UNTRACKED-COUNT=0
STATUS-LINES=0

BASE_SHA: 32e9153773f9bedbfe64dbd5e5bf8909038e59cb
PRE-UNTRACKED list: empty (no paths).
The code under test equals CODE_HEAD (425772de97a84663d781d2bffeac4b8e4787787f); MERGE_BASE (f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5) is an ancestor; the edited directories are clean.
