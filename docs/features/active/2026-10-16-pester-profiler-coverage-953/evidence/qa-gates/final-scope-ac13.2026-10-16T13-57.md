# Final QC: Scope AC-13 (P8-T16 / P6-T14, sharding path)

Timestamp: 2026-10-16T13-57
Command: sh "SCRATCH/issue-953-p8-t16-p6-t14.sh" — `git diff --name-only origin/main...HEAD`; `git status --porcelain`; `$mb = git merge-base origin/main HEAD`; for every `.github/workflows/*.yml`, the `on:` block of the worktree file compared with the block from `git show "${mb}:.github/workflows/<name>"`; lines 1-5 of `_poshqc.yml` compared with the merge-base text.
EXIT_CODE: 0

Output Summary:
- Merge base: 5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea.
- `git diff --name-only origin/main...HEAD`: 151 paths; `.github/workflows/ci.yml` listed 0 times. `git status --porcelain`: empty; ci.yml listed 0 times.
- `on:` blocks: all 14 workflow files identical to the merge-base text (ALL_ON_BLOCKS_IDENTICAL=True), including `_poshqc.yml` and `ci.yml`.
- `_poshqc.yml` lines 1-5 identical to the merge-base text.
- Result: PASS (AC-13).
