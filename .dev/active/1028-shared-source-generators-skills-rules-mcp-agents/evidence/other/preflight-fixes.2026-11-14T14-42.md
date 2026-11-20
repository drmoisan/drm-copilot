# Preflight Fixes — Issue 1028 (planning refresh, round 2)

Timestamp: 2026-11-14T14-42
Plan: docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/plan.2026-10-30T18-30.md
Command: atomic-executor delegation, DIRECTIVE: PREFLIGHT VALIDATION ONLY (single-pass, round 2); Python CLI scripts/dev_tools/validate_orchestration_artifacts.py plan
EXIT_CODE: 0
Output Summary: three trivial in-place fixes in task text; no task added, removed or reordered.

## Fixes

1. [P4-T2] | citation completeness (ledger rule) | The ledger parenthetical named only `.claude/rules/*.md` and `.github/instructions/*.instructions.md`. Entry 0011 and earlier entries also record revert blocks for Codex rule-skills that [P4-T3] writes (for example `.agents/skills/python/SKILL.md`, `.agents/skills/powershell/SKILL.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/orchestrator-state/SKILL.md`). The parenthetical now also names the Codex rule-skills `.agents/skills/<rule>/SKILL.md`. The `## Constraints` ledger rule already covered these files, so the assertion is unchanged.
2. `## Existing Test Disposition` (Process-reduction ledger bullet) | citation completeness | `extensions/drm-copilot/jest.config.cjs`, which [P2-T1] appends to, carries revert blocks of entries 0002 and 0003. The bullet's task list now names [P2-T1] for that file, matching the `## Constraints` rule that runs `ProcessReductionChain.Ledger.Tests.ps1` in the task check of every task that writes a recorded file.
3. `## Existing Test Disposition` (Updated, pytest bullet) | parity wording | The renamed `test_github_copilot_fixture_emits_no_agents_target_for_standing_guidance` now states its assertions (no `AGENTS.md` output key and no `Converted standing guidance` text), in parity with the Jest test it pairs with, so the spec condition "no `# Converted standing guidance` text" has a named pytest assertion.
