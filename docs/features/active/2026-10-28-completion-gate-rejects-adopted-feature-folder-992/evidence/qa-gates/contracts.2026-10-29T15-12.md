# Contract, Schema, Architecture, and Integration Stages (P6-T7)

Timestamp: 2026-10-29T15-12
Command: poetry run pytest tests/scripts/dev_tools/<suite>.py -q -p no:cacheprovider --no-cov (per suite below); poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check; Invoke-Pester, one process, over the Pester suites below (SCRATCH launcher)
EXIT_CODE: 0
Output Summary: Every contract command exits 0 on the final tree (115 pytest cases, generator check clean, 1034 Pester cases). Architecture-boundary stage not applicable. Integration stage covered by the hook suite inside the P6-T6 full run.

| Command | EXIT_CODE | Result |
| --- | --- | --- |
| pytest `test_push_down_claude_resource_contracts.py` | 0 | 14 passed |
| pytest `test_push_down_codex_and_agents_resource_contracts.py` | 0 | 9 passed |
| pytest `test_push_down_claude_pack_manifest_completeness.py` | 0 | 2 passed |
| pytest `test_push_down_codex_and_agents_pack_manifest_completeness.py` | 0 | 2 passed |
| pytest `test_push_down_pack_manifest_dependency_closure.py` | 0 | 18 passed |
| pytest `test_parallel_issue_adoption_skill_contracts.py` | 0 | 16 passed |
| pytest `test_claude_rules_frontmatter.py` | 0 | 8 passed |
| pytest `test_codex_agent_wrapper_contracts.py` | 0 | 7 passed |
| pytest `test_codex_handoff_contract_parity.py` | 0 | 5 passed |
| pytest `test_parallel_orchestrator_surface_contracts.py` | 0 | 36 passed |
| `python -m scripts.dev_tools.generate_codex_agent_variants --check` | 0 | no drift |
| Pester `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` | 0 | 622 passed |
| Pester `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` | 0 | 6 passed |
| Pester `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | 0 | 6 passed |
| Pester `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (guard for the new hook suite) | 0 | 395 passed |
| Pester `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` (guard for the new suites) | 0 | 5 passed |

Architecture-boundary stage: not applicable. No `.dependency-cruiser.cjs` or other boundary configuration covers the touched surfaces (`scripts/dev_tools`, `extensions/drm-copilot/src/lib/validate`, `.claude/lib`, `.claude/hooks`); the new TypeScript module imports nothing, and the new Python and PowerShell modules import only standard-library or sibling modules.

Integration stage: the end-to-end hook suite `tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1` (dot-sourced hook, real routing dispatch seam replaced by a passing invoker, injected git invoker) runs inside the P6-T6 single-process run; see `evidence/qa-gates/ps-pester.*.md`.

Additional check: the whole Python test tree (`poetry run pytest -q -p no:cacheprovider --no-cov`) passed with 7429 passed, 6 skipped; no root TypeScript test (`tests/unit/*.test.ts`) references a changed file.
