# Contract Baseline (P0-T6)

Timestamp: 2026-10-29T14-20
Command: poetry run pytest tests/scripts/dev_tools/<suite>.py -q -p no:cacheprovider --no-cov (per suite below); poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check; Invoke-Pester (branch-current, one process) over the two Pester suites below
EXIT_CODE: 0

| Command | EXIT_CODE | Result |
| --- | --- | --- |
| pytest `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 0 | 14 passed |
| pytest `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | 0 | 9 passed |
| pytest `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | 0 | 2 passed |
| pytest `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` | 0 | 2 passed |
| pytest `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | 0 | 18 passed |
| pytest `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` | 0 | 16 passed |
| pytest `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` | 0 | 8 passed |
| `python -m scripts.dev_tools.generate_codex_agent_variants --check` | 0 | no drift |
| Pester `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` | 0 | 622 passed, 0 failed |
| Pester `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` | 0 | 6 passed, 0 failed |

Output Summary: All ten contract checks pass at baseline (69 pytest cases, 628 Pester cases, generator check clean).
