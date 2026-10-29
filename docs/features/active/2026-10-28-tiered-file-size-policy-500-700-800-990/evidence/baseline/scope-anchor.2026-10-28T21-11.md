# Scope Anchor and Execution Route (issue #990)

Timestamp: 2026-10-28T21-11
Command: git merge-base origin/main HEAD; git rev-parse --abbrev-ref HEAD; read `route_id` / `path_selected` from artifacts/orchestration/orchestrator-state.json
EXIT_CODE: 0
Output Summary:
- MERGE_BASE: a7a928d59fd52610c1a627448c8fffac106b23c5 (merge base of origin/main and HEAD; HEAD is the merge commit of origin/main into this branch)
- Branch: feature/tiered-file-size-policy-500-700-800-990
- Route: `large` (`route_id` and `path_selected` both `large`; checkpoint not terminal). The batch-budget exemption (`Test-BatchBudgetLargePathRoute` in `.claude/hooks/enforce-batch-budget-route.ps1`) applies.
- Scope diffs use `origin/main...HEAD`.
