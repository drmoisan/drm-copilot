# Fail-Before Exception Dossier (P0-T5)

Timestamp: 2026-11-08T17-25
Issue: #1138

WhyFailingRunImpossible: The subagent spawn-depth limit cannot be reproduced from an isolated subagent: a reproduction needs an operator session that sets `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` and runs a nested chain, and branch hooks are not exercised by isolated subagents before merge. A run of the new Pester tests before the helper exists fails only on the missing helper file, which does not exercise the defect.

## Alternative Proof

- `research/research.2026-11-08T16-51.md`, section 1 (Claude Code platform behavior): Claude Code 2.1.219 and later allows nested subagents up to depth 3 by default, withholds the Agent tool at the depth limit, and `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` changes the limit.
- `research/research.2026-11-08T16-51.md`, section 3 (Failing condition): the epic and parallel chain places the per-feature `orchestrator` at depth 2, so an effective limit of 2 (configured value, an extra fork layer, or an older version) removes Agent from the orchestrators while the coordinator keeps it, which matches the reported stall.
- Absence of a guard before the change: no repository surface states or checks the depth assumption, and `blocked_reason: "spawn_agent_unavailable"` has no Claude-side producer (spec Root Cause Analysis).
- Pass-after proof: `tests/scripts/claude-hooks/epic-invocation-nesting-depth.Tests.ps1` (helper parse and caller/target matrix with the seam mocked) and `tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1` (wording contract over live and bundle copies), read from the final Pester gate.
