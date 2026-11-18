# Preflight Fixes — Issue 1028 (confirming preflight after the gate re-plan)

Timestamp: 2026-11-17T17-48
Plan: docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/plan.2026-10-30T18-30.md

## Fixes

- PREFLIGHT-FIX: `## Existing Test Disposition` (Epic skill bullet, [P3-T3]) | missing asserting-test disposition (citation completion; assertion unchanged) | added `test_skill_bundle_contract_repo.py` `test_ci_gate_parser_skills_invoke_bundled_parser` as unchanged. It reads `.claude/skills/epic-orchestrate/SKILL.md` and asserts that the skill invokes the bundled CI gate parser. A search of `tests/` for `epic-orchestrate` found it, and it was not listed.
- PREFLIGHT-FIX: `## Existing Test Disposition` (Epic skill bullet, [P3-T3]) | missing asserting-test disposition (citation completion; assertion unchanged) | added `tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1` as unchanged. It reads `.claude/skills/epic-orchestrate/SKILL.md` as a coordinator skill file. The blanket claude-runtime clause of the generated-surfaces bullet already covered it, and it is now named explicitly beside the other epic-skill suites.
