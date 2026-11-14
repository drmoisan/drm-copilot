# Preflight Fixes — Issue #1093

Timestamp: 2026-11-06T23-47
Plan: docs/features/active/2026-11-06-epic-progress-report-skill-1093/plan.2026-11-06T17-53.md
Command: mcp__drm-copilot__validate_orchestration_artifacts (artifact_type plan); poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>
EXIT_CODE: 0
Output Summary: three trivial task-text fixes applied in place; no task added, removed or reordered; both plan validators pass after the fixes.

## Fixes

1. [P1-T1] | validator-blind defect (stale path in a moved file) | The relocated Logic suite's first-line header comment names `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`, and P1-T1 said "No other edit", so the P6-T10 acceptance (a `git grep` outside `docs/features/` for that string returns zero matches) could not be met. The task text now also changes the path in each relocated suite's first-line header comment to the `CANON` path. The assertion in P6-T10 is unchanged.
2. [P2-T4] | stale heading anchor | The research heading is `#### Reproduction of the pairing example from recorded samples (hand-computed)`; the citation now carries the `(hand-computed)` suffix.
3. [P5-T2] | imprecise anchor | Sorted position of `.claude/skills/epic-progress-report/...` in `core.json` is after the `epic-plan` entry and before the `epic-run` entry, not directly after `epic-orchestrate`; the task text now names both neighbors. No test asserts the order.
