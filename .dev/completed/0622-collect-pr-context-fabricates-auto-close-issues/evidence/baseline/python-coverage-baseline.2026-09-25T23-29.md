# Python Baseline Per-File Coverage (P0-T19)

Timestamp: 2026-09-26T19-41
Command: poetry run pytest --cov=scripts.dev_tools.pr_context --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/evidence/baseline/python-coverage-baseline.json --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
EXIT_CODE: 0

Output Summary:
Source: files["<path key>"]["summary"] in python-coverage-baseline.json (Windows path keys).
- scripts\dev_tools\pr_context\models.py: covered_lines/num_statements 122/123 = 99.19%; covered_branches/num_branches 13/14 = 92.86%
- scripts\dev_tools\pr_context\feature_docs.py: covered_lines/num_statements 157/168 = 93.45%; covered_branches/num_branches 80/92 = 86.96%
- scripts\dev_tools\pr_context\render_feature_excerpts.py: covered_lines/num_statements 120/144 = 83.33%; covered_branches/num_branches 50/72 = 69.44%
- scripts\dev_tools\pr_context\render_pr_helpers.py: covered_lines/num_statements 120/127 = 94.49%; covered_branches/num_branches 55/60 = 91.67%
- scripts\dev_tools\pr_context\collector.py: covered_lines/num_statements 174/186 = 93.55%; covered_branches/num_branches 57/66 = 86.36%

Below threshold (pre-existing, baseline): scripts\dev_tools\pr_context\render_feature_excerpts.py is below 85.00% line (83.33%) and below 75.00% branch (69.44%).
