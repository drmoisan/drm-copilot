# Pytest Coverage Baseline

Timestamp: 2026-06-19T17-36
Command: poetry run pytest --cov=scripts/dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_fix_all.py
EXIT_CODE: 0
Output Summary:
- 34 tests passed in approximately 3.06s.
- Targeted module `scripts/dev_tools/fix_all_runtime.py` (current branch, this test file):
  - Line coverage: 84.55% (186/220 statements).
  - Branch coverage: 79.41% (54/68 branches).
  - Missing lines: 75, 104-106, 111-113, 143-145, 176-178, 200-202, 230, 235-237, 272, 382-384, 411-413, 440-442, 601, 607, 614-615 (pre-existing FAIL/cancel/aggregation paths in the json, shell, python, and powershell branches; none fall within the added TypeScript branch at lines 453-571).
- Pre-change baseline for the same module on merge-base 18121fbd (no TypeScript branch present):
  - Line coverage: 82.20% (157/191 statements).
  - Branch coverage: 75.00% (45/60 branches).
- The package-level `--cov=scripts/dev_tools` TOTAL reads 4% because only this single test file executes; that number is expected and not the targeted-module figure.
