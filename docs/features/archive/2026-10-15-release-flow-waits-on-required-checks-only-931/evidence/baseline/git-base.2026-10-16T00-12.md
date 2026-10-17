# Git Baseline (Issue #931)

Timestamp: 2026-10-16T00-12
Command: git rev-parse HEAD; git merge-base HEAD origin/main; git status --porcelain
EXIT_CODE: 0
Output Summary: HEAD afb3226daedff5492c801314236cc4b731ce7972; BASE (merge-base with origin/main) adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99; porcelain lists only paths inside the feature folder.

## HEAD

Command: `git rev-parse HEAD`
Exit code: 0
Output: `afb3226daedff5492c801314236cc4b731ce7972`

## BASE

Command: `git merge-base HEAD origin/main`
Exit code: 0
Output: `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`

BASE = `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`

## Porcelain status

Command: `git status --porcelain`
Exit code: 0
Output:

```
 M docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/plan.2026-10-15T15-45.md
?? docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/evidence/
```

Both entries lie inside `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/` (plan check-offs and Phase 0 evidence written so far). No path outside the feature folder is listed.
