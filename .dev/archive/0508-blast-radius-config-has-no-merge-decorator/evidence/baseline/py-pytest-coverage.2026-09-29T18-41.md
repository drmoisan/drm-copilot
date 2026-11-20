# Python Test and Coverage Baseline (P0-T18)

Timestamp: 2026-09-29T18-41
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-508-baseline.json
Command actually executed: the same command with `-q -p no:cacheprovider` appended (quiet output; no pytest cache write), output redirected to a session scratch log; coverage values read from artifacts/python/coverage-508-baseline.json with `node -e`.
EXIT_CODE: 0
Output Summary:
- Result line: `5472 passed, 6 skipped in 111.20s` (0 failed, 0 errors)
- Terminal TOTAL row: 16593 stmts, 1125 miss, 5994 branch, 583 brpart, 91%
- totals.percent_statements_covered: 93.22 (93.22003254384379)
- totals.percent_branches_covered: 86.07 (86.0694027360694)
- scripts/dev_tools/push_down_claude_customizations.py: statements 92.75 (92.7536231884058), branches 75.0
- scripts/dev_tools/push_down_claude_destination_writes.py (REGISTRY_MODULE): statements 98.84 (98.83720930232558), branches 91.67 (91.66666666666667)
- Failing node IDs: none. The issue #510 condition did not occur in this run.
