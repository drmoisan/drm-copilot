# Baseline Coverage (Issue #205)

Timestamp: 2026-06-19T18-05

Command: `poetry run pytest --cov=scripts/dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_fix_all.py tests/scripts/dev_tools/test_fix_all_branches.py`

EXIT_CODE: 0

Output Summary:
- 34 tests passed.
- `scripts/dev_tools/fix_all_runtime.py`: 220 statements, 34 missed; 68 branches, 14 partial.
  - Line coverage = (220 - 34) / 220 = 84.55% (below 85% threshold; confirms Blocking finding R2).
  - Branch coverage = (68 - 14) / 68 = 79.41%.
  - Combined report column shows 83%.
- `scripts/dev_tools/fix_all.py`: line 85% combined.
- Missing lines in fix_all_runtime.py: 75, 104-106, 111-113, 143-145, 176-178, 200-202, 230-237, 272, 382-384, 411-413, 440-442, 601, 607, 614-615.
