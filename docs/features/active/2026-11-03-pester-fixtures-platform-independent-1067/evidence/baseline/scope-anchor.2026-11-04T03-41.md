# Scope Anchor (P0-T2)

Timestamp: 2026-11-04T03-41
Command: git merge-base origin/main HEAD; git diff --name-only MB HEAD; git status --porcelain
EXIT_CODE: 0
Output Summary:
- MB = 930486d46c8e6712df2638eb432da4491e1aa51f (equal to origin/main at the time of the run).
- `git diff --name-only MB HEAD` lists 9 paths, all under `docs/features/`: the feature folder files (two linux-pester-baseline artifacts, preflight-fixes record, issue.md, plan, research, spec.md, user-story.md) and `docs/features/potential/promoted/2026-11-03-pester-fixtures-platform-independent.md`.
- `git status --porcelain` lists the untracked P0-T1 artifact `evidence/baseline/phase0-instructions-read.2026-11-04T03-41.md` and the plan file itself (modified only by the P0-T1 check-off). No non-docs path is changed.
- No production or test file differs from MB, so the greatest `evidence/baseline/linux-pester-baseline.*.md` (2026-11-04T03-19: 925 tests, 827 passed, 89 failed, 9 skipped) remains valid as the Pester count baseline for the two trees.
