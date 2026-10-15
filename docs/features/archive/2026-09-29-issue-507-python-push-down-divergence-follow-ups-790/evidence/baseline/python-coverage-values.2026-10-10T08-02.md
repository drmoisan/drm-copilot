# Baseline Python Per-Module Coverage Values (P0-T10)

Timestamp: 2026-10-10T08-02
Command: poetry run python -c "import json, pathlib; f = {k.replace(chr(92), '/'): v['summary'] for k, v in json.loads(pathlib.Path('artifacts/python/coverage-790-baseline.json').read_text(encoding='utf-8'))['files'].items()}; [print(m, 'LINE', round(100 * f[m]['covered_lines'] / f[m]['num_statements'], 2), 'BRANCH', round(100 * f[m]['covered_branches'] / f[m]['num_branches'], 2) if f[m]['num_branches'] else 'NO_BRANCHES') for m in ['scripts/dev_tools/push_down_claude_filesystem.py', 'scripts/dev_tools/push_down_claude_customizations.py', 'scripts/dev_tools/push_down_claude_pack_selection.py']]"
EXIT_CODE: 0
Output Summary:
- `scripts/dev_tools/push_down_claude_filesystem.py LINE 83.18 BRANCH 57.69`
- `scripts/dev_tools/push_down_claude_customizations.py LINE 94.05 BRANCH 87.5`
- `scripts/dev_tools/push_down_claude_pack_selection.py LINE 93.24 BRANCH 82.14`
- `scripts/dev_tools/push_down_claude_gitignore_merge.py`: N/A - module absent at baseline (new module)
- Observation: push_down_claude_filesystem.py is below the 85% line and 75% branch thresholds at baseline (targeted test set). Recorded for the Phase 7 delta check.
