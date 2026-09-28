# Python Baseline Tests with Coverage (P0-T18)

Timestamp: 2026-09-26T19-41
Command: poetry run pytest --cov=scripts.dev_tools.pr_context --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/evidence/baseline/python-coverage-baseline.json --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
EXIT_CODE: 0

Output Summary:
- Result line: `4419 passed, 5 skipped, 1 deselected in 21.81s` (collected 4425 items / 1 deselected / 4424 selected).
- Deselection reason: issue #510 (the bundled-payload contract test fails locally on gitignored batch-budget state and runs in CI on a fresh checkout).
- TOTAL row: `TOTAL 1575 120 636 86 89%` (Stmts Miss Branch BrPart Cover).
- Term-missing rows (Stmts Miss Branch BrPart Cover Missing):
  - scripts\dev_tools\pr_context\models.py 123 1 14 1 99% 154
  - scripts\dev_tools\pr_context\feature_docs.py 168 11 92 8 91% 158, 162, 186->184, 216, 240, 248-249, 296->301, 305-309
  - scripts\dev_tools\pr_context\render_feature_excerpts.py 144 24 72 8 79% 28, 33-35, 65-82, 149->153, 160->162, 204, 218, 226-227
  - scripts\dev_tools\pr_context\render_pr_helpers.py 127 7 60 5 94% 65, 90-92, 103, 133, 258->257, 266
  - scripts\dev_tools\pr_context\collector.py 186 12 66 9 92% 210, 235, 250, 251->246, 285-286, 312-315, 328, 341, 373
- JSON report written: docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/evidence/baseline/python-coverage-baseline.json
