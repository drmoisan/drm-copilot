# Task Check - [P1-T4] - Issue #1228

Timestamp: 2026-11-23T14-13
Kind: task check (not a gate; no coverage measured; not coverage evidence)

Changed files:
- .agents/skills/remediation-handoff-atomic-planner/SKILL.md (`## Plan Shape`: Phase 0 cites the orchestration's `Phase 0 baseline` artifact with static baselines only; the final phase runs one remediation gate in phase-gate form in coverage mode and records per-file coverage of the changed files before the self-review task)
- .agents/skills/test-execution-policy/SKILL.md (`### Scoped Pester runs`: names the unit stage of "a phase gate, a remediation gate, and a sync check"; merged files cover the selection only, so full-suite coverage comes from the `Phase 0 baseline` and the final QA loop; `-TestPath` and `fail-before proof` kept)
- .agents/skills/execution-environment/SKILL.md (`## Test Isolation Checks`: new bullet for the phase gate, remediation gate, and sync check (local gate); `## Contract Tests That Pin Mirrored Files`: the `test-cadence-wording.Tests.ps1` bullet names the issue #1228 sweep)
- the three byte copies under extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/

Selection and rule: contract tests that read these paths (task text of [P1-T4]). Window (b) excludes the copy comparisons, which fail until [P1-T5] regenerates the `.claude` copies.

Commands:
- Sweep check of the three sources for the ten PD5 tokens and the `test_brief_copies_carry_no_removed_run_tokens` tokens (`grep -i -F`): no match (exit 1 = no hit).
- Static: Markdown only; no formatter, linter, or type check applies.
- Pester: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1` - EXIT_CODE 0; 187 tests, 0 failed; 7 rows matching `SCOPED|HANDOFF` (`PGW-SCOPED-*`, `HANDOFF-*`) passed.
- pytest: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_single_pass_preflight_contracts.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` - EXIT_CODE 1; 79 passed, 1 failed. The single failure is `test_execution_environment_brief_contracts.py::test_brief_copies_are_byte_identical`, a window (b) copy comparison named in the plan (the `.claude` brief copy and its bundle are regenerated in [P1-T5]); every `.agents`-copy case passed.

Result: PASS (the only failure is the plan's window (b) exclusion).
