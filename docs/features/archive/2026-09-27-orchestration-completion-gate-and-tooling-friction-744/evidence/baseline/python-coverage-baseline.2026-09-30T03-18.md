# Baseline Python Numeric Coverage

Timestamp: 2026-10-02T01-22
Timestamp-Correction: original value 2026-10-02T01-17 was a Phase 0 start reading reused through Phase 4; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T02-02.md), an upper bound on the command run time.
Command: poetry run python -c "import json; j = json.load(open('artifacts/python/coverage-744-baseline.json', encoding='utf-8')); t = j['totals']; f = [v for k, v in j['files'].items() if k.replace(chr(92), '/') == 'scripts/dev_tools/pr_context/verification_evidence.py'][0]; s = f['summary']; print('TOTAL lines=%d/%d branches=%d/%d' % (t['covered_lines'], t['num_statements'], t['covered_branches'], t['num_branches'])); print('FILE lines=%d/%d branches=%d/%d missing_lines=%s' % (s['covered_lines'], s['num_statements'], s['covered_branches'], s['num_branches'], ','.join(str(n) for n in f['missing_lines'])))"
EXIT_CODE: 0
Output Summary:
- Raw output: `TOTAL lines=16130/17246 branches=5407/6232`
- Raw output: `FILE lines=57/58 branches=16/18 missing_lines=124`
- BaselineTotalLine%: 93.53
- BaselineTotalBranch%: 86.76
- BaselineFileLine%: 98.28 (scripts/dev_tools/pr_context/verification_evidence.py)
- BaselineFileBranch%: 88.89 (scripts/dev_tools/pr_context/verification_evidence.py)
- No value is below 85.00% line or 75.00% branch.
- Percentages were derived with `poetry run python -c "print('%.2f %.2f %.2f %.2f' % (16130/17246*100, 5407/6232*100, 57/58*100, 16/18*100))"` -> `93.53 86.76 98.28 88.89`.
