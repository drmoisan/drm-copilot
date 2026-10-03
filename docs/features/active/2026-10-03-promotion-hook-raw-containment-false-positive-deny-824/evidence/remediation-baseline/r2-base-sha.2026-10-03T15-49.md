# r2 P0-T3 base SHA and pre-edit state

Timestamp: 2026-10-03T15-49
Command: pwsh -NoProfile -File "SCRATCH/steps/r2-p0-t3.ps1" -Worktree "WORKTREE" (git branch --show-current; git rev-parse HEAD; git merge-base --is-ancestor c7b78cd2 HEAD; git diff --quiet c7b78cd2 HEAD -- .claude/hooks .codex extensions/drm-copilot/resources tests scripts; pre-untracked list to SCRATCH/pre-untracked.txt; git status --porcelain --untracked-files=all over the edited directories; VERDICT)
EXIT_CODE: 0
BASE_SHA: bda1982bcb9048a22efe9ba124a2b53516e9e3c1
Output Summary:
- Branch: bug/promotion-hook-raw-containment-false-positive-deny-824
- HEAD (BASE_SHA): bda1982bcb9048a22efe9ba124a2b53516e9e3c1 (the caller reported HEAD bda1982b, which differs from the preflight tree 9dbceb3a only by the commit of the approved plan file; BASE_SHA is taken from this output)
- ANCESTOR-EXIT=0 (c7b78cd2 is an ancestor of HEAD)
- CYCLE1-CODE-DIFF-EXIT=0 (code under test equals the cycle-1 head c7b78cd2)
- PRE-UNTRACKED-COUNT=0 (PRE-UNTRACKED list is empty; no listed paths)
- STATUS-LINES=0 (every edited directory is clean before any edit)
- VERDICT passed; process exit 0.

Raw output:

```text
TS=2026-10-03T15-49
bug/promotion-hook-raw-containment-false-positive-deny-824
bda1982bcb9048a22efe9ba124a2b53516e9e3c1
ANCESTOR-EXIT=0
CYCLE1-CODE-DIFF-EXIT=0
PRE-UNTRACKED-COUNT=0
STATUS-LINES=0
```
