# Pytest Gate (Final) — Issue #1106 (P5-T3)

Timestamp: 2026-11-07T15-18
Command: PY -m pytest -n auto --cov=scripts.dev_tools.atomic_executor.qc_runner --cov=scripts.dev_tools.atomic_executor.qc_toolchain --cov=scripts.dev_tools.atomic_executor.cli_preflight --cov=scripts.dev_tools.atomic_executor.prompt_builder --cov=scripts.dev_tools.fix_all_branches_extra --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1106-pytest-final.json --junitxml=SCRATCH/issue-1106-pytest-final.xml (via SCRATCH/issue-1106-pytest.sh final; cwd worktree root, VIRTUAL_ENV unset, PYTHONPATH worktree root and packages/discovery-runtime/src)
EXIT_CODE: 0
Output Summary: 16198 passed, 6 skipped in 192.22s. JUnit: tests=16204 failures=0 errors=0 skipped=6. Single gate run; all five D3 modules measured with branch coverage.

## JUnit counts (SCRATCH/issue-1106-pytest-final.xml)

- tests: 16204 (baseline 16185; +19 from the new tests)
- failures: 0
- errors: 0
- skipped: 6
- Failing tests: none

## Contract and target suites (passed / failed, from the same JUnit file)

| Suite | Passed | Failed |
|---|---|---|
| test_push_down_claude_resource_contracts.py | 14 | 0 |
| test_push_down_codex_and_agents_resource_contracts.py | 9 | 0 |
| test_codex_handoff_contract_parity.py | 5 | 0 |
| test_orchestration_guardrail_contracts.py | 10 | 0 |
| test_claude_rules_frontmatter.py | 8 | 0 |
| test_push_down_issue_824_follow_ups.py | 62 | 0 |
| test_push_down_claude_pack_manifest_completeness.py | 2 | 0 |
| test_push_down_codex_and_agents_pack_manifest_completeness.py | 2 | 0 |
| test_push_down_pack_manifest_dependency_closure.py | 18 | 0 |
| test_qc_runner.py | 24 | 0 |
| test_cli_part3.py | 30 | 0 |
| test_prompt_builder.py | 19 | 0 |

## Per-module coverage (SCRATCH/issue-1106-pytest-final.json)

| Module | percent_covered | covered_lines / num_statements | covered_branches | num_branches | missing_lines |
|---|---|---|---|---|---|
| scripts.dev_tools.atomic_executor.qc_runner | 90.91 | 96 / 103 | 14 | 18 | 152, 195, 300, 301, 477, 509, 564 |
| scripts.dev_tools.atomic_executor.qc_toolchain | 100.00 | 15 / 15 | 0 | 0 | none |
| scripts.dev_tools.atomic_executor.cli_preflight | 99.57 | 153 / 153 | 77 | 78 | none |
| scripts.dev_tools.atomic_executor.prompt_builder | 100.00 | 124 / 124 | 44 | 44 | none |
| scripts.dev_tools.fix_all_branches_extra | 100.00 | 85 / 85 | 24 | 24 | none |
