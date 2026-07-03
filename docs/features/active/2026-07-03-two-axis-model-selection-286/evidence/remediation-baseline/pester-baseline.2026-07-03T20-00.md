# Pester Structural-Guard Baseline (Pre-Fix) — Issue #286 (CI-1)

- Timestamp: 2026-07-03T20-00
- Command: `mcp__drm-copilot__run_poshqc_test` over `tests/scripts/claude-runtime`
- EXIT_CODE: 1

## Output Summary

The Pester run exited with code 1 (failure), confirming the pre-fix baseline. The failing case is `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` — "requires .claude/skills/orchestrate/SKILL.md to avoid context fork and orchestrator agent routing". The guard asserts `Expected regular expression 'context:\s*fork' to not match`, but the P7 Model Selection documentation introduced the literal `context: fork` sequence in the fork caveat at `.claude/skills/orchestrate/SKILL.md:86` (and the epic-orchestrate mirror). This is the CI-1 Blocking finding under remediation. Expected outcome after the Phase 1 rewording fix: this case passes.
