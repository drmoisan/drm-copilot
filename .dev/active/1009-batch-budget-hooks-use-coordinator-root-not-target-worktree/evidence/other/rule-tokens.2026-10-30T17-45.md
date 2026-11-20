# Orchestrator-State Rule Tokens (issue #1009)

Timestamp: 2026-10-30T17-45
Command: grep -n -F "Resolve-HookTargetWorktree" .claude/rules/orchestrator-state.md; grep -n "^## Enforcement" .claude/rules/orchestrator-state.md; poetry run python SCRATCH/issue-1009-section-tokens.py .claude/rules/orchestrator-state.md (fixed-string line searches of the working-tree file, not git grep)
EXIT_CODE: 0
Output Summary: the new `## Enforcement` bullet carries both literals on one line.

- `## Enforcement` heading: line 320.
- `Resolve-HookTargetWorktree`: exactly 1 matching line in the whole file, line 332, which is after the `## Enforcement` heading line.
- `coordinating session`: 1 matching line after the `## Enforcement` heading (line 332, the same bullet).
