# P3-T14 Scope check

Timestamp: 2026-10-09T20-27
Command: git diff --merge-base --name-only origin/main; then git status --porcelain
EXIT_CODE: 0
Output Summary: The union of both outputs contains exactly the three section 2 code paths, the promoted lifecycle record (the preparation path), and feature-folder paths. No path under extensions/drm-copilot/src/, no jest.config.cjs, and no wave-barrier production or test path appears. Evidence files under evidence/baseline and evidence/regression-testing and the four prior feature documents are tracked at this point; the evidence/qa-gates directory is untracked and listed by porcelain.

Non-feature-folder paths in the merge-base diff output (complete list):

```
docs/features/potential/promoted/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status.md
extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-merge-status.test.ts
scripts/dev_tools/validate_epic_orchestrator_state.py
tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py
```

Every other line of the merge-base diff output (28 paths, 32 lines in total) begins with the feature-folder prefix
docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/
(evidence/baseline/ 17 files, evidence/regression-testing/ 7 files, issue.md, plan.2026-10-08T13-57.md, research/research.2026-10-08T14-00.md, spec.md).

git status --porcelain output:

```
?? docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/
```
