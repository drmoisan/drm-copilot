# Git Anchor Baseline (P0-T9)

Timestamp: 2026-09-29T17-28
Command: git branch --show-current
EXIT_CODE: 0
Command: git fetch origin epic/push-down-payload-correctness-integration
EXIT_CODE: 0

Output Summary:
- Branch printed: bug/push-down-root-folders-divergence-exec-507
- Fetch: exit 0 (`epic/push-down-payload-correctness-integration -> FETCH_HEAD`)
- git rev-parse HEAD: 12db46245ba7683b5d6ccb676312a4b22a39b0ce
- git rev-parse origin/epic/push-down-payload-correctness-integration: 12db46245ba7683b5d6ccb676312a4b22a39b0ce
- Both SHAs are 40-character hex strings; HEAD equals the diff anchor (no commits yet on the branch).

Deviation (recorded): the plan's acceptance names the branch `bug/push-down-root-folders-divergence-507`. The executing session was directed by the epic orchestrator to run on `bug/push-down-root-folders-divergence-exec-507` (created from origin/epic/push-down-payload-correctness-integration). The branch identity is caller-directed; the diff anchor and scope checks are unaffected.
