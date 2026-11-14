Timestamp: 2026-11-08T13-35
Plan: docs/features/active/2026-11-08-epic-plan-cites-unshipped-wave-computation-script-1129/plan.2026-11-08T08-08.md

Fixes (task text only):

1. P1-T1: the path extraction now states a token boundary, so `.codex/scripts/launch-epic-child-wave.ps1` (cited by the Codex surfaces and listed in the Codex core.json) is read as one `.codex/` path and not as an unlisted `scripts/` path.
2. P2-T1: names `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, which discovers every `.claude/lib` `.psm1` from disk, and states the module conventions it enforces (strict-mode and error-preference lines, help-block sentence, size cap).
3. P5-T1: names `test_frozen_epic_surface_matches_pinned_baseline_digest` as affected by the agent `tools:` edit, with its re-pin in P5-T2.
