# Baseline Targeted Pytest With Coverage (P0-T9)

Timestamp: 2026-10-10T08-01
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py --cov=scripts.dev_tools.push_down_claude_filesystem --cov=scripts.dev_tools.push_down_claude_customizations --cov=scripts.dev_tools.push_down_claude_pack_selection --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-790-baseline.json
EXIT_CODE: 0
Output Summary:
- Pytest summary: `55 passed in 1.00s`. BASELINE_TARGETED_PASSED = 55 (collected 55; customizations 8, parity 10, pack_selection 16, pack_end_to_end 6, exclusion_filter 15).
- Term-missing table rows (verbatim):
  - `scripts\dev_tools\push_down_claude_customizations.py      84      5     16      0    93%   130-139`
  - `scripts\dev_tools\push_down_claude_filesystem.py         107     18     26      9    78%   116, 122, 129, 139, 142, 176-177, 289-290, 309, 340-342, 378, 390, 392-397`
  - `scripts\dev_tools\push_down_claude_pack_selection.py      74      5     28      5    90%   214, 229, 240, 256, 314`
  - `TOTAL                                                    265     28     70     14    86%`
- JSON report written to `artifacts/python/coverage-790-baseline.json` (gitignored tool output).
