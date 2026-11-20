# R1 Pytest Final Gate ([P1-T5])

Plan: remediation-plan.2026-11-19T12-09.md
Timestamp: 2026-11-19T14-02
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:SCRATCH/pytest-r1-final.json --junitxml=SCRATCH/pytest-r1-final.xml -q; summary through sh SCRATCH/issue-1032-r1-run.sh issue-1032-r1-pyjunit.ps1
EXIT_CODE: 0
Output Summary: one `pytest -n auto` GATE-RUN on the post-fix head (integration and golden lanes excluded by the launcher): 17102 passed, 0 failed, 6 skipped in 212.39s. Repository-wide coverage (JSON report totals): line 98.00% (35359/36079), branch 95.46% (13091/13714), equal to the Phase 0 baseline. `scripts/dev_tools/agentic_sync.py`: line 98.02% (99/101), branch 94.12% (32/34), missing lines 209 and 364, equal to the Phase 0 baseline.

## Named Modules in the Passing Set (from the JUnit report)

| Set | Module | Tests | Failures |
| --- | --- | --- | --- |
| F2 | `test_agentic_sync` | 5 | 0 |
| F2 | `test_agentic_sync_artifacts` | 7 | 0 |
| F2 | `test_push_down_copilot_customizations` | 3 | 0 |
| F2 | `test_push_down_copilot_customizations_rewrites` | 6 | 0 |
| PUSH-DOWN-CONTRACT-TESTS | `test_push_down_claude_resource_contracts` | 14 | 0 |
| PUSH-DOWN-CONTRACT-TESTS | `test_push_down_codex_and_agents_resource_contracts` | 9 | 0 |
| PUSH-DOWN-CONTRACT-TESTS | `test_push_down_claude_pack_manifest_completeness` | 2 | 0 |
| PUSH-DOWN-CONTRACT-TESTS | `test_push_down_codex_and_agents_pack_manifest_completeness` | 2 | 0 |
| PUSH-DOWN-CONTRACT-TESTS | `test_push_down_pack_manifest_dependency_closure` | 18 | 0 |
| brief contract | `test_execution_environment_brief_contracts` (includes `test_brief_copies_are_byte_identical`) | 27 | 0 |
