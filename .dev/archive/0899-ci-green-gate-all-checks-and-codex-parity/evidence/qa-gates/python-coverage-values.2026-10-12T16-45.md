# Python Coverage Values (P1-T2)

Timestamp: 2026-10-12T17-14

Command: poetry run python -S -c "import json, os, pathlib; t = json.loads(pathlib.Path('artifacts/python/issue-899-coverage.json').read_text(encoding='utf-8'))['totals']; L = pathlib.Path('artifacts/python/lcov.info').read_text(encoding='utf-8').splitlines(); n = lambda k: sum(int(x[len(k):]) for x in L if x.startswith(k)); root = os.path.realpath('.').lower(); sf = [x[3:] for x in L if x.startswith('SF:')]; print('TOTAL_LINE', round(t['percent_statements_covered'], 2), 'TOTAL_BRANCH', round(t['percent_branches_covered'], 2), 'LF', n('LF:'), 'LH', n('LH:'), 'BRF', n('BRF:'), 'BRH', n('BRH:'), 'SF_TOTAL', len(sf), 'SF_FOREIGN', sum(1 for x in sf if not os.path.realpath(x).lower().startswith(root)))"

EXIT_CODE: 0

Output Summary:
- Printed line (verbatim): `TOTAL_LINE 93.8 TOTAL_BRANCH 88.1 LF 17633 LH 16539 BRF 6364 BRH 5607 SF_TOTAL 214 SF_FOREIGN 0`
- FINAL_TOTAL_LINE = 93.80
- FINAL_TOTAL_BRANCH = 88.10
- LCOV_LINE = 100 * 16539 / 17633 = 93.80
- LCOV_BRANCH = 100 * 5607 / 6364 = 88.10
- Required checks: LF 17633 > 0, BRF 6364 > 0 (branch data collected), SF_TOTAL 214 > 0, SF_FOREIGN 0. All pass.
- Threshold comparison is made in P1-T3.
