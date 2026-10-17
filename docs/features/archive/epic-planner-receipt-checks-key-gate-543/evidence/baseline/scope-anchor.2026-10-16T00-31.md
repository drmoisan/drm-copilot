# Scope Anchor (P0-T3)

Timestamp: 2026-10-16T00-31
Command: git rev-parse --abbrev-ref HEAD; git rev-parse main; git merge-base HEAD main; git status --porcelain (each run separately in the Bash tool from the worktree root)
EXIT_CODE: 0
Output Summary:
- git rev-parse --abbrev-ref HEAD: bug/epic-planner-receipt-checks-key-gate-543 (exit 0)
- git rev-parse main: adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99 (exit 0)
- git merge-base HEAD main: adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99 (exit 0)
MAIN_BASE_SHA: adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99
- Local main equals origin/main (adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99), so no origin/main substitution is needed; Anchor: main.
- git status --porcelain (exit 0), verbatim:
```
 M docs/features/active/epic-planner-receipt-checks-key-gate-543/plan.2026-10-15T07-42.md
?? docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/
```
- No path outside docs/features/active/epic-planner-receipt-checks-key-gate-543/ is listed (the two entries are the P0-T1/P0-T2 plan check-offs and evidence files). artifacts/orchestration is gitignored and does not appear.
