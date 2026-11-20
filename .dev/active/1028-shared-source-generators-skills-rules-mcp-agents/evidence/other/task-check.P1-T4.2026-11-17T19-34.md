# Task Check — [P1-T4]

Timestamp: 2026-11-17T19-34
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 tests/scripts/harness-generation/HarnessInstructions.Tests.ps1; env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py; sh SCRATCH/issue-1028-gen.sh instructions check
EXIT_CODE: 0
Output Summary: Pester selection: 156 tests passed, 0 failed, launcher exit 0. pytest selection: 158 passed. The instructions check exited 0 with no drift. Both changed files are LF (0 carriage returns). No format, lint or type check applies to Markdown.

Changed files: `AGENTS.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md` (byte copy), `CLAUDE.md`.
Selection rule: `## Test Cadence (Mandatory)`. A changed Markdown path selects the contract tests that read it. `test-cadence-wording.Tests.ps1` reads `AGENTS.md`, its bundle and `CLAUDE.md`. `ProcessReductionChain.Ledger.Tests.ps1` replays entry 0011 against `AGENTS.md`. `HarnessInstructions.Tests.ps1` is the check's own suite. The push-down suites that name `AGENTS.md` or compare the codex-and-agents bundle are also included. The feature-review coverage hook suites mock their `CLAUDE.md` reads (`## Existing Test Disposition`) and run at the [P1-T6] gate.
