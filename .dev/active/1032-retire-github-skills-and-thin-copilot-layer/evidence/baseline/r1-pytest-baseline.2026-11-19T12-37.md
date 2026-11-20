# R1 Pytest Phase 0 Baseline ([P0-T3])

Plan: remediation-plan.2026-11-19T12-09.md
Timestamp: 2026-11-19T12-37
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:SCRATCH/pytest-r1-baseline.json --junitxml=SCRATCH/pytest-r1-baseline.xml -q; summary through sh SCRATCH/issue-1032-r1-run.sh issue-1032-r1-pyjunit.ps1
EXIT_CODE: 0
Output Summary: one `pytest -n auto` GATE-RUN on the merged head (integration and golden lanes excluded by the launcher): 17102 passed, 0 failed, 6 skipped in 172.41s (one earlier attempt exited 75, queue timeout, re-run after the holder finished). Failing tests: none. Repository-wide coverage (JSON report totals): line 98.00% (35359/36079), branch 95.46% (13091/13714). `scripts/dev_tools/agentic_sync.py`: line 98.02% (99/101), branch 94.12% (32/34), missing lines 209 and 364.

## Named Modules (from the JUnit report)

| Module | Tests | Failures |
| --- | --- | --- |
| `test_agentic_sync` | 5 | 0 |
| `test_agentic_sync_artifacts` | 7 | 0 |
| `test_push_down_copilot_customizations` | 3 | 0 |
| `test_push_down_copilot_customizations_rewrites` | 6 | 0 |
| `test_push_down_claude_resource_contracts` | 14 | 0 |
| `test_push_down_codex_and_agents_resource_contracts` | 9 | 0 |
| `test_push_down_claude_pack_manifest_completeness` | 2 | 0 |
| `test_push_down_codex_and_agents_pack_manifest_completeness` | 2 | 0 |
| `test_push_down_pack_manifest_dependency_closure` | 18 | 0 |
| `test_execution_environment_brief_contracts` | 27 | 0 |

The four F2 modules pass.
