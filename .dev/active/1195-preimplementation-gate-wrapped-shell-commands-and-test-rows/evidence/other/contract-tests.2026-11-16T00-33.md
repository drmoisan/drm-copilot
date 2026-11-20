# Mirror Contract Tests (P2-T4)

Timestamp: 2026-11-16T00-33
Command: (1) env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh with the python suite and tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_codex_and_agents_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py (SCRATCH/issue-1195-gate-py.sh); (2) env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check (SCRATCH/issue-1195-gen.sh); (3) sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Parity.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1
EXIT_CODE: 0
Output Summary:
- (1) push-down resource, pack-manifest completeness, and dependency-closure contracts: exit 0, 45 passed, 0 failed.
- (2) Codex generator --check: exit 0, no drift reported.
- (3) Pester: Invoke-PoshQCParallelTest exit code 0; merged JUnit 940 tests, 940 passed, 0 failed (classify, commands, and gate parity; legacy-codex-hook-contracts including the Codex gate 500-line row; hook-dependency-guard-completeness).
- Classify sibling: one SHA256 across the four copies; each gate bundle copy equals its source; the six brief copies share one SHA256 (AC-9, AC-11).
