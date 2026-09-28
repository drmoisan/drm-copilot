# Baseline Commit (P0-T11)

Timestamp: 2026-09-27T14-38
Command: git rev-parse HEAD ; git fetch origin main ; git merge-base HEAD origin/main ; git status --porcelain (four separate invocations, run from the repository root)
EXIT_CODE: 0
Output Summary: All four commands exited 0. HEAD is 395d0ee4a87ad0cd2cb7c1ed8ec0d2afcb7e2603. BASE_SHA (merge-base of HEAD and origin/main) is beae3f021674e64fa6662097fe48a332d8da62b8. Porcelain status shows only this feature's in-progress Phase 0 files (plan check-offs and the new evidence directory).

## Per-command results

| Command | EXIT_CODE | Output |
| --- | --- | --- |
| git rev-parse HEAD | 0 | 395d0ee4a87ad0cd2cb7c1ed8ec0d2afcb7e2603 |
| git fetch origin main | 0 | From https://github.com/drmoisan/drm-copilot; branch main -> FETCH_HEAD |
| git merge-base HEAD origin/main | 0 | beae3f021674e64fa6662097fe48a332d8da62b8 |
| git status --porcelain | 0 | see below |

HEAD: 395d0ee4a87ad0cd2cb7c1ed8ec0d2afcb7e2603
BASE_SHA: beae3f021674e64fa6662097fe48a332d8da62b8

## Porcelain status

```text
 M docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/plan.2026-09-27T12-16.md
?? docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/
```

The two entries are the Phase 0 plan check-offs and the Phase 0 evidence directory. No tracked file
outside the feature folder is modified. This status is the reference for the P0-T19 unchanged-status
acceptance.
