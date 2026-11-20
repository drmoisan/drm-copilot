# Final QC: pytest Gate (P7-T5)

Timestamp: 2026-11-14T17-11
Command: sh SCRATCH/issue-1173-pytest.sh final (from the worktree root: env -u VIRTUAL_ENV poetry run pytest tests -n auto -q --cov=docs_python_native.cli_argparse --cov=docs_python_native.cli --cov=docs_python_native.call_sites --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1173-pytest-final.json); per-module figures read from the JSON report by SCRATCH/issue-1173-covjson.ps1
EXIT_CODE: 0
Output Summary:
- One pytest -n auto run: 16735 passed, 6 skipped, 0 failed in 142.37 s.
- Coverage from the JSON report:

| Module | Lines covered/total | Line % | Branches covered/total | Branch % |
|---|---|---|---|---|
| docs_python_native.call_sites | 105/105 | 100.00 | 38/38 | 100.00 |
| docs_python_native.cli_argparse | 213/213 | 100.00 | 113/114 | 99.12 |
| docs_python_native.cli | 140/141 | 99.29 | 63/64 | 98.44 |
| Total (three modules) | 458/459 | - | 214/216 | combined 99.56 |

- The `## Mirror Contract Tests` pytest files (test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py, test_codex_agent_wrapper_contracts.py, test_execution_environment_brief_contracts.py) ran in this run with 0 failures.
- The Phase 0 baseline recorded one failure (the `__pycache__` bytecode in the bundled payload enumeration); the related fix of P1-T3 removed it and this run has none.
- Expected failures: none.
