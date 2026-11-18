# Task check - P1-T5

Timestamp: 2026-11-17T22-40
Changed files:
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json: adds `.claude/hooks/hook-release-allowance-context.ps1` and `.claude/hooks/enforce-orchestration-preimplementation-gate-release.ps1` beside the parallel-records preimplementation-gate entry.
- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json: adds `.codex/hooks/hook-release-allowance-context.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-release.ps1` beside the docs preimplementation-gate entry.
Selection rule: the contract tests that read the pack manifests and the bundle (named in the task acceptance), the Codex generator check, and the ledger chain suite that holds hunks in both core.json files.

Commands:
1. Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check (via SCRATCH/issue-1201-py-select.sh)
   EXIT_CODE: 0
   Output Summary: no output and no drift reported; no tracked file changed (porcelain status lists only the files of this change).
2. Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
   EXIT_CODE: 0
   Output Summary: 45 passed, 0 failed (the five test files unmodified).
3. Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1
   EXIT_CODE: 0
   Output Summary: 5 tests, 5 passed, 0 failed (unmodified).
