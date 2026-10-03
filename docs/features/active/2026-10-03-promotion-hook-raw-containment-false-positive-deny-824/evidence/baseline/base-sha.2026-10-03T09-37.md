# P0-T3 BASE_SHA and clean pre-edit state

Timestamp: 2026-10-03T09-37
Command: pwsh -NoProfile -File SCRATCH/steps/p0-t3.ps1 -Worktree WORKTREE (git branch --show-current; git rev-parse HEAD; git merge-base --is-ancestor 93725814 HEAD; git diff --name-only 93725814 HEAD -- <in-scope paths>; git status --porcelain --untracked-files=all -- <in-scope paths>)
EXIT_CODE: 0
Output Summary:
- Branch: bug/promotion-hook-raw-containment-false-positive-deny-824
- HEAD: 9e8fe7eb576a904ac22cab96faf8c5c12311833e
- BASE_SHA: 9e8fe7eb576a904ac22cab96faf8c5c12311833e
- Ancestry check (93725814 is ancestor of HEAD): 0
- git diff --name-only 93725814 HEAD over in-scope code paths: (empty)
- git status --porcelain over in-scope code paths: (empty)
- Result: PASS. 93725814 is the citation-snapshot commit, not BASE_SHA; the empty diff confirms planning-time citations describe the tree at BASE_SHA.
