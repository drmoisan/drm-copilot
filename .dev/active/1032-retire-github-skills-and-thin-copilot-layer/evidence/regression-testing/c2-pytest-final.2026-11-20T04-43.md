# Cycle-2 Final Pytest Gate ([P1-T7], GATE-RUN)

Timestamp: 2026-11-20T04-43
Plan: remediation-plan.2026-11-19T19-58.md
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:SCRATCH/issue-1032-c2-pytest.json --junitxml=SCRATCH/issue-1032-c2-pytest.xml -q (one pytest -n auto run through the launcher, started 2026-11-20T04-38 UTC); summary by sh SCRATCH/issue-1032-c2-run.sh issue-1032-c2-pysum.ps1 over the JUnit and JSON reports
EXIT_CODE: 0
Output Summary: 17101 passed, 0 failed, 6 skipped (17107 cases) in 256.72s.
  Repository-wide coverage: line 98.00% (35359/36079), branch 95.46% (13091/13714); BASELINE-REF (branch-b-pytest-final.2026-11-19T19-20.md): line 98.00% (35359/36079), branch 95.46% (13091/13714); no drop.
  Failing tests: none.

## Named modules (tests/failures)

| Module | Set | Tests | Failures |
| --- | --- | --- | --- |
| `test_push_down_claude_resource_contracts` | PUSH-DOWN-CONTRACT-TESTS | 14 | 0 |
| `test_push_down_codex_and_agents_resource_contracts` | PUSH-DOWN-CONTRACT-TESTS | 9 | 0 |
| `test_push_down_claude_pack_manifest_completeness` | PUSH-DOWN-CONTRACT-TESTS | 2 | 0 |
| `test_push_down_codex_and_agents_pack_manifest_completeness` | PUSH-DOWN-CONTRACT-TESTS | 2 | 0 |
| `test_push_down_pack_manifest_dependency_closure` | PUSH-DOWN-CONTRACT-TESTS | 18 | 0 |
| `test_execution_environment_brief_contracts` | BRIEF-PIN-TESTS | 27 | 0 |
| `test_discovery_documentation_contracts` | BRIEF-PIN-TESTS | 32 | 0 |
| `test_single_pass_preflight_contracts` | BRIEF-PIN-TESTS | 12 | 0 |
| `test_bash_command_shape_surfaces` | brief copy list (`_BRIEF_COPIES`) | 12 | 0 |
