# Python Final Per-File Coverage — [P8-T5]

Timestamp: 2026-09-26T20-24
Loop iteration: 1
Command: poetry run pytest --cov=scripts.dev_tools.pr_context --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/evidence/qa-gates/python-coverage-final.json --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
EXIT_CODE: 0
Output Summary:
Source: files["<path key>"]["summary"] in python-coverage-final.json (Windows path keys).
- scripts\dev_tools\pr_context\models.py: covered_lines/num_statements 125/126 = 99.21%; covered_branches/num_branches 13/14 = 92.86%
- scripts\dev_tools\pr_context\feature_docs.py: covered_lines/num_statements 157/168 = 93.45%; covered_branches/num_branches 80/92 = 86.96%
- scripts\dev_tools\pr_context\render_feature_excerpts.py: covered_lines/num_statements 124/144 = 86.11%; covered_branches/num_branches 54/72 = 75.00%
- scripts\dev_tools\pr_context\render_pr_helpers.py: covered_lines/num_statements 125/130 = 96.15%; covered_branches/num_branches 61/64 = 95.31%
- scripts\dev_tools\pr_context\autoclose.py: covered_lines/num_statements 45/45 = 100.00%; covered_branches/num_branches 16/16 = 100.00%
- scripts\dev_tools\pr_context\collector.py: covered_lines/num_statements 157/168 = 93.45%; covered_branches/num_branches 42/50 = 84.00%
Result: every file is at least 85.00% line and 75.00% branch. No coverage additions were required, so the Phase 8 loop was not restarted. render_feature_excerpts.py, below both floors at baseline (83.33% line, 69.44% branch), now meets both (86.11% line, 75.00% branch).
