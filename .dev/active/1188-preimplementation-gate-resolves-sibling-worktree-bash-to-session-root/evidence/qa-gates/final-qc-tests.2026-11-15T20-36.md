# Final QC tests, remediation cycle 2, P1-T4

Timestamp: 2026-11-15T20-36
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1 tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1 tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1
EXIT_CODE: 0
Output Summary: Pester 416 tests, 0 failures, 0 errors. Baseline comparison (P0-T1): the ledger replay file passed 5 of 5 before the change; no new failing test.

Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_bash_command_shape_surfaces.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
EXIT_CODE: 0
Output Summary: 66 passed, 0 failed. Baseline comparison (P0-T1): the two baseline files passed 35 of 35 before the change; they now hold 43 cases (35 plus the eight new literal-path cases) and all pass, with the two push-down contract files adding the remaining 23.

Coverage: not applicable. The change edits Markdown guidance and adds rows to one existing Python test, so no production file is in scope; the CI shards run the full suites.
