# Final QC Python Per-Module Coverage Values (P6-T5)

Timestamp: 2026-10-10T08-25
Command: poetry run python -c "import json, pathlib; f = {k.replace(chr(92), '/'): v['summary'] for k, v in json.loads(pathlib.Path('artifacts/python/coverage-790-final.json').read_text(encoding='utf-8'))['files'].items()}; [print(m, 'LINE', round(100 * f[m]['covered_lines'] / f[m]['num_statements'], 2), 'BRANCH', round(100 * f[m]['covered_branches'] / f[m]['num_branches'], 2) if f[m]['num_branches'] else 'NO_BRANCHES') for m in ['scripts/dev_tools/push_down_claude_filesystem.py', 'scripts/dev_tools/push_down_claude_gitignore_merge.py', 'scripts/dev_tools/push_down_claude_customizations.py', 'scripts/dev_tools/push_down_claude_pack_selection.py']]"
EXIT_CODE: 0
Output Summary:
- Loop iteration: 1.
- Printed (verbatim):
  - `scripts/dev_tools/push_down_claude_filesystem.py LINE 88.5 BRANCH 64.29`
  - `scripts/dev_tools/push_down_claude_gitignore_merge.py LINE 100.0 BRANCH 100.0`
  - `scripts/dev_tools/push_down_claude_customizations.py LINE 93.67 BRANCH 87.5`
  - `scripts/dev_tools/push_down_claude_pack_selection.py LINE 93.98 BRANCH 83.33`
- Threshold result: THRESHOLD NOT MET. `push_down_claude_filesystem.py` BRANCH 64.29 is below 75 (line 88.5 meets 85). The other three modules meet both thresholds.
- The filesystem module was already below both thresholds at baseline (P0-T10: LINE 83.18, BRANCH 57.69); this change raised line by 5.32 and branch by 6.60 points.
- Remedy not applied in this run: per the orchestrator's execution directive, no tests were added beyond the plan's written content; the gap is reported for an orchestrator remediation cycle. P6-T5 remains unchecked and AC-22 remains unchecked.
- Uncovered branch-relevant lines (from P6-T4 term-missing): 122, 128, 135, 145, 148, 182-183, 326, 407, 409-414; 8 partial branches.
