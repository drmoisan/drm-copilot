# Operator Approval: settings.json allow entry (Issue #890)

Timestamp: 2026-10-12T19-33
Source: delegation prompt from the parallel-orchestrator for run bug-burndown-2026-10-11 (cohort 0), relaying the operator's decision.

Approved change: add the allow entry `"Bash(bash .claude/lib/bash/mutate-parallel-run.sh*)"` to `permissions.allow` in `.claude/settings.json` and to its bundled copy `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` (plan Reference R6, task P1-T24 and P1-T25).

Precedent: #791 (PR #875), which added the `remove-parallel-item.sh` allow entry under the same approval pattern.

Scope limit: no other permission change beyond what the plan states is approved.

Recorded before P1-T24 runs.
