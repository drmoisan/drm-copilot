# P0-T11 Baseline CI dispatch on BRANCH

Timestamp: 2026-10-02T03-40
Command: git rev-parse origin/bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741 (executor, after git fetch origin bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741). Push, dispatch, and run lookup performed by the orchestrator (DEV-3): git push origin bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741; date -u +%Y-%m-%dT%H:%M:%SZ; gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741; gh run list --workflow _shell-coverage.yml --branch bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741 --event workflow_dispatch --limit 1 --json databaseId,headSha,createdAt,status --jq '.[0]'
EXIT_CODE: 0
Output Summary:
- Deviation DEV-3: the executor tool set has no gh. The orchestrator pushed BASE_SHA and dispatched the baseline run; the facts below are as supplied by the orchestrator, except the remote-SHA check, which the executor ran.
- git push origin BRANCH (orchestrator): BASE_SHA df5eb303129a30289a7d81775fdadaa40631be63 already on the remote.
- git rev-parse origin/bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741 (executor, after fetch): exit=0; df5eb303129a30289a7d81775fdadaa40631be63, equal to BASE_SHA.
- DISPATCH_START: 2026-10-02T07:26:57Z (UTC).
- gh workflow run _shell-coverage.yml --ref BRANCH (orchestrator): exit=0.
- Run: https://github.com/drmoisan/drm-copilot/actions/runs/36978610292; BASELINE_RUN_ID = 36978610292; headSha df5eb303129a30289a7d81775fdadaa40631be63 (equal to BASE_SHA); status in_progress at the orchestrator's last check (07:3x UTC).
- Result: PASS for the P0-T11 acceptance conditions (remote SHA equals BASE_SHA; dispatch exit 0; BASELINE_RUN_ID recorded). The coverage readout is P0-T12 (segment 2).
