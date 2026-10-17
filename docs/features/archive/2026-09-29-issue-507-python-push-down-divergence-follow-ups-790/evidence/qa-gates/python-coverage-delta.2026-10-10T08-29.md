# Python Coverage Delta and Changed-Line Coverage (P7-T1)

Timestamp: 2026-10-10T08-29
Command: poetry run python -c "import json, pathlib, re, subprocess; base = subprocess.run(['git', 'merge-base', 'HEAD', 'origin/main'], capture_output=True, text=True, check=True).stdout.strip(); files = {k.replace(chr(92), '/'): v for k, v in json.loads(pathlib.Path('artifacts/python/coverage-790-final.json').read_text(encoding='utf-8'))['files'].items()}; mods = ['scripts/dev_tools/push_down_claude_filesystem.py', 'scripts/dev_tools/push_down_claude_customizations.py', 'scripts/dev_tools/push_down_claude_pack_selection.py']; [print(m, 'CHANGED_EXECUTABLE', len(c), 'MISSED', len(c & set(files[m]['missing_lines'])), 'PCT', round(100 * (len(c) - len(c & set(files[m]['missing_lines']))) / len(c), 2) if c else 'NO_CHANGED_EXECUTABLE') for m in mods for c in [{n for a, b in re.findall(r'^@@ -[^ ]+ [+]([0-9]+)(?:,([0-9]+))? @@', subprocess.run(['git', 'diff', '-U0', base, '--', m], capture_output=True, text=True, check=True).stdout, re.M) for n in range(int(a), int(a) + (int(b) if b else 1))} & (set(files[m]['executed_lines']) | set(files[m]['missing_lines']))]]"
EXIT_CODE: 0
Output Summary:
- merge-base resolved to BASE_SHA 7bbd0b9b990737642b4eeded01a27b7c5c8348b3 (origin/main not fetched; A1). The diff includes the changes already committed on the branch.
- Printed (verbatim):
  - `scripts/dev_tools/push_down_claude_filesystem.py CHANGED_EXECUTABLE 6 MISSED 0 PCT 100.0`
  - `scripts/dev_tools/push_down_claude_customizations.py CHANGED_EXECUTABLE 7 MISSED 0 PCT 100.0`
  - `scripts/dev_tools/push_down_claude_pack_selection.py CHANGED_EXECUTABLE 9 MISSED 0 PCT 100.0`
- Changed-line coverage: every PCT is 100.0 (>= 85). No regression on changed lines.
- Per-module table (baseline P0-T10, final P6-T5):

| Module | Baseline LINE | Final LINE | Delta | Baseline BRANCH | Final BRANCH | Delta |
|---|---|---|---|---|---|---|
| push_down_claude_filesystem.py | 83.18 | 88.5 | +5.32 | 57.69 | 64.29 | +6.60 |
| push_down_claude_customizations.py | 94.05 | 93.67 | -0.38 | 87.5 | 87.5 | 0.00 |
| push_down_claude_pack_selection.py | 93.24 | 93.98 | +0.74 | 82.14 | 83.33 | +1.19 |
| push_down_claude_gitignore_merge.py (new) | N/A | 100.0 | new code | N/A | 100.0 | new code |

- New-code values for `push_down_claude_gitignore_merge.py`: LINE 100.0, BRANCH 100.0.
- Customizations line delta -0.38: statements fell from 84 to 79 (the `_resolve_published_paths` extraction) while the same 5 pre-existing lines (130-139) stay uncovered; no changed line is uncovered.
- Result: REMEDIATION REQUIRED. `push_down_claude_filesystem.py` final BRANCH 64.29 is below 75 (final LINE 88.5 meets 85). All other final values and all changed-line PCT values meet thresholds. Per the orchestrator directive no tests were added in this run; P7-T1 remains unchecked and AC-22 remains unchecked pending an orchestrator remediation cycle.
