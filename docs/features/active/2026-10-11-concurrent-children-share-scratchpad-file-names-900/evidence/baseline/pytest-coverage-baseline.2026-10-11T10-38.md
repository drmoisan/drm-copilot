# Pytest Coverage Baseline

Timestamp: 2026-10-12T17-22

Command: poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts --cov=scripts.dev_tools.push_down_claude_customizations --cov-branch --cov-report=term-missing -q

EXIT_CODE: 0

Output Summary:
- Summary line: `48 passed, 1 deselected`
- Counts: passed 48, skipped 0, failed 0, deselected 1
- Coverage table row: `scripts\dev_tools\push_down_claude_customizations.py      79     48     16      0    33%`
- TOTAL row: Stmts 79, Miss 48, Branch 16, BrPart 0, Cover 33%
- Derived line percentage: (79 - 48) / 79 = 31 / 79 = 39.24%
- No failing node IDs.
