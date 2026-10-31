# Baseline — Mirror Contract Tests

Timestamp: 2026-10-31T15-11
Command: sh SCRATCH/issue-1013-contracts.sh p0t9 (pytest over the brief's contract modules; `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`; branch-current Pester over the two claude-runtime suites)
EXIT_CODE: 0
Output Summary: pytest 184 passed, 0 failed; generator check exit 0 (no drift); Pester JUnit tests=678 failures=0.

| Test | Result |
|---|---|
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | pass |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | pass |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | pass |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` | pass |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | pass |
| `scripts/dev_tools/generate_codex_agent_variants.py --check` | pass (exit 0) |
| `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py` | pass |
| `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py` | pass |
| `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` | pass |
| `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` (consumes `PINNED_FROZEN_SURFACE_HASHES` of `parallel_orchestrator_surface_expectations.py`) | pass |
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | pass |
| `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | pass |
| `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py` | pass |
| `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | pass |
| `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` | pass |
