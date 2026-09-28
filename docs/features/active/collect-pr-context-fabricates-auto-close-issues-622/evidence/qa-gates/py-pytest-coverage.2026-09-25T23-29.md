# Python Test and Coverage Gate — [P8-T4]

Timestamp: 2026-09-26T20-23
Loop iteration: 1
Command: poetry run pytest --cov=scripts.dev_tools.pr_context --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/evidence/qa-gates/python-coverage-final.json --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
EXIT_CODE: 0
Output Summary:
- Result line: `4508 passed, 5 skipped, 1 deselected in 10.91s` (no failed count).
- Deselection reason: the deselected node fails locally on gitignored batch-budget state regardless of this change (open issue #510) and runs in CI on a fresh checkout.
- TOTAL row: `TOTAL 1608 112 640 80 90%`
- Term-missing rows:
  - `scripts\dev_tools\pr_context\models.py 126 1 14 1 99% 165`
  - `scripts\dev_tools\pr_context\feature_docs.py 168 11 92 8 91% 165, 169, 193->191, 223, 247, 255-256, 303->308, 312-316`
  - `scripts\dev_tools\pr_context\render_feature_excerpts.py 144 20 72 6 82% 70-87, 154->158, 165->167, 209, 223, 231-232`
  - `scripts\dev_tools\pr_context\render_pr_helpers.py 130 5 64 3 96% 68, 93-95, 141, 275->274`
  - `scripts\dev_tools\pr_context\autoclose.py 45 0 16 0 100%`
  - `scripts\dev_tools\pr_context\collector.py 168 11 50 8 91% 218, 229, 230->225, 272-273, 299-302, 315, 328, 360`
- JSON report written to docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/evidence/qa-gates/python-coverage-final.json.
