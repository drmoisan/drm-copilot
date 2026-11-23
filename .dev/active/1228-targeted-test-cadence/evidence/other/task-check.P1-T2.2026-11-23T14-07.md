# Task Check - [P1-T2] - Issue #1228

Timestamp: 2026-11-23T14-07
Kind: task check (not a gate; no coverage measured; not coverage evidence)

Changed files:
- scripts/harness-generation/sources/rules/general-code-change.md (R1 in `## Mandatory Toolchain Loop`, `## Bugfix Workflow (all languages, defects only)`, and `## 8. After Making Changes`; sentence "At a phase gate, stage 5 runs the union of the test selections of the phase's tasks." added to the `## Mandatory Toolchain Loop` paragraph)
- scripts/harness-generation/sources/rules/python.md (R1 x2), powershell.md (x1), typescript.md (x1), csharp.md (x2), shell.md (x1) (`## Toolchain`)
- AGENTS.md (R1 in `## Mandatory Toolchain Loop`)
- extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md (byte copy; `cmp` reports identical)

Selection and rule: contract tests that read the changed paths (task text of [P1-T2]). Excluded under window (b): the generated-output comparisons (`HarnessGeneration.RepoGate.Tests.ps1`, the push-down resource contracts, `test_brief_copies_are_byte_identical`, the Codex wrapper and handoff parity tests, and the Codex generator `--check`), first required in [P1-T5]. Excluded under window (a): `ProcessReductionChain.Ledger.Tests.ps1`.

Commands:
- Sweep check of the seven edited files for the ten PD5 cadence sweep tokens (`grep -i -F` with each token): no match (exit 1 = no hit).
- Static: Markdown only; no formatter, linter, or type check applies.
- Pester: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` - EXIT_CODE 0; 130 tests, 0 failed; rows `TCW-POLICY-AGENTS-MD`, `TCW-POLICY-AGENTS-MD-BUNDLE`, and `TCW-BUNDLE-AGENTS-MD` passed. Two attempts before the pass exited 75 (queue timeout).
- pytest: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py` - EXIT_CODE 0; 105 passed. Two attempts exited 75 (queue timeout).

Result: PASS.
