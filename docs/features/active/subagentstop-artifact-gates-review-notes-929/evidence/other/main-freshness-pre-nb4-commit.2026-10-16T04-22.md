# Main Freshness Before the NB-4 Commit (P8-T15)

Timestamp: 2026-10-16T04-22

## Gate 1

Command: git fetch origin main
EXIT_CODE: 0
Output:
```
From https://github.com/drmoisan/drm-copilot
 * branch                main       -> FETCH_HEAD
```

## Gate 2

Command: git rev-parse origin/main
EXIT_CODE: 0
Output:
```
de4f91294daa230cebc0df0434c6e2873001d927
```

## Gate 3

Command: git merge-base origin/main HEAD
EXIT_CODE: 0
Output:
```
ba53ff5694a42e975d5d1db99b2b6ef505143e66
```

Output Summary:
- `MAIN-MOVED`: `git rev-parse origin/main` (`de4f91294daa230cebc0df0434c6e2873001d927`) differs from the P7-T1 `ORIGIN-MAIN-AT-PHASE-7` hash (`ba53ff5694a42e975d5d1db99b2b6ef505143e66`).
- `BRANCH-CONTAINS-MAIN: no` (the merge-base `ba53ff569` differs from `origin/main`).
- The new `origin/main` commits are the merge of PR #947 (`bug/hook-coverage-attribution-gaps-936`, issue #936); the #928 branch is still not merged. P8-T17 takes the follow-up branch after the NB-4 commit (AC-09 freshness record).
