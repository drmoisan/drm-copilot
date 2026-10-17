# AC-09 Main Containment (P9-T15)

Timestamp: 2026-10-16T05-16

Run after the last Phase 8 commit (`e0e3d76136c2fd62db41c723f0d76159bf5bc689`).

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
5bc97774b8322e57abb94dfac3cd0a000a136c5b
```

## Gate 3

Command: git merge-base origin/main HEAD
EXIT_CODE: 0
Output:
```
de4f91294daa230cebc0df0434c6e2873001d927
```

Output Summary: `MAIN-MOVED-AFTER-NB4`. The merge-base (`de4f91294`, the `origin/main` merged by P8-T17) differs from the current `origin/main` (`5bc97774b`). After the P8-T17 merge, `main` gained further merges (PRs #949, #942, #951 and earlier, none from the #928 branch). The plan defines no merge step after P8-T17, so AC-09 requires `BRANCH-CONTAINS-MAIN: yes` and is not met by this record (see P9-T22 and P9-T27).
