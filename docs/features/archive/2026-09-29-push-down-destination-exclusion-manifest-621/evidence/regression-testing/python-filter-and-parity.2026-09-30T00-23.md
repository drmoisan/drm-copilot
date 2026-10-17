# Python Filter, Entry Point, and Parity Tests with Coverage — Issue #621

Task: [P4-T5]
Branch: feature/push-down-destination-exclusion-manifest-exec-621

Timestamp: 2026-09-30T00-23
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py tests/scripts/dev_tools/test_push_down_claude_exclusion_parity.py tests/scripts/dev_tools/test_push_down_exclusion_manifest.py tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_pack_selection.py --cov=scripts.dev_tools.push_down_exclusion_manifest --cov=scripts.dev_tools.push_down_claude_exclusion_filter --cov=scripts.dev_tools.push_down_claude_customizations --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json -q
EXIT_CODE: 0
Output Summary:
- Summary line: `159 passed in 0.59s` (0 failed, 0 errors, 0 skipped). Composition: 15 filter tests, 45 parity cases (7 test functions; 18 matcher, 14 manifest, and 9 plan cases plus 4 non-parametrized tests), 75 manifest-module cases, and the pre-existing customization and pack-selection suites.
- Term-missing rows:
  - `scripts\dev_tools\push_down_claude_customizations.py 84 5 16 0 93% 130-139` (the uncovered lines are the pre-existing bundled-import fallback of the second `try` block).
  - `scripts\dev_tools\push_down_claude_exclusion_filter.py 100 1 16 1 98% 330` (the non-object artifact `ValueError` branch).
  - `scripts\dev_tools\push_down_exclusion_manifest.py 104 0 34 0 100%`.
- From `artifacts/python/coverage.json` (`files[<key>].summary`, keys after `\` to `/`):

| Key | num_statements | covered_lines | Line ratio | num_branches | covered_branches | Branch ratio |
| --- | --- | --- | --- | --- | --- | --- |
| scripts/dev_tools/push_down_exclusion_manifest.py | 104 | 104 | 1.0000 | 34 | 34 | 1.0000 |
| scripts/dev_tools/push_down_claude_exclusion_filter.py | 100 | 99 | 0.9900 | 16 | 15 | 0.9375 |
| scripts/dev_tools/push_down_claude_customizations.py | 84 | 79 | 0.9405 | 16 | 14 | 0.8750 |

- All three line ratios are at or above 0.85 and all three branch ratios are at or above 0.75.

AC status: the Python halves of AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-9, AC-13, AC-14, AC-15, AC-17, AC-18, AC-22, and AC-23 are exercised by the named tests in this run. No checkbox is changed here (plan rule 12): AC-13 and AC-22 list [P4-T5] as their only evidence task in plan section 5, but the plan assigns their check-off to [P6-T7] together with the TypeScript half; the remaining ACs also require [P6-T7].
