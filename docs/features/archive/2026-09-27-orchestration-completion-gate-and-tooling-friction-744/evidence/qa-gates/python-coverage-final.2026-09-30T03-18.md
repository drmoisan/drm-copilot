# QA Gate: Python Numeric Coverage, Comparison, and Changed-Line Coverage

Timestamp: 2026-10-02T01-49
Command: poetry run python -c "import json; j = json.load(open('artifacts/python/coverage-744-final.json', encoding='utf-8')); t = j['totals']; f = [v for k, v in j['files'].items() if k.replace(chr(92), '/') == 'scripts/dev_tools/pr_context/verification_evidence.py'][0]; s = f['summary']; print('TOTAL lines=%d/%d branches=%d/%d' % (t['covered_lines'], t['num_statements'], t['covered_branches'], t['num_branches'])); print('FILE lines=%d/%d branches=%d/%d missing_lines=%s' % (s['covered_lines'], s['num_statements'], s['covered_branches'], s['num_branches'], ','.join(str(n) for n in f['missing_lines'])))"
Companion command: git diff -U0 b080a69ecb60b65d016362b21fffed0a34be9144 -- scripts/dev_tools/pr_context/verification_evidence.py
EXIT_CODE: 0
Loop iteration: 1
Output Summary:
- Raw output: `TOTAL lines=16129/17244 branches=5406/6230`
- Raw output: `FILE lines=56/56 branches=15/16 missing_lines=` (empty list)
- FinalTotalLine%: 93.53 (baseline 93.53); floor 85.00 met.
- FinalTotalBranch%: 86.77 (baseline 86.76); floor 75.00 met.
- FinalFileLine%: 100.00 (baseline 98.28); not below baseline; floor 85.00 met.
- FinalFileBranch%: 93.75 (baseline 88.89); not below baseline; floor 75.00 met.
- Percentages derived with `poetry run python -c "print('%.2f %.2f %.2f %.2f' % (16129/17244*100, 5406/6230*100, 56/56*100, 15/16*100))"` -> `93.53 86.77 100.00 93.75`.
- Changed-line coverage (companion diff hunks `@@ -121 +121,4 @@` and `@@ -127,3 +130,3 @@`): added lines 121, 122, 123, 124 are comments (non-executable; not in `missing_lines`); added lines 130, 131, 132 form the single `if (...) and key not in parsed:` statement starting at line 130, which is not in `missing_lines`. No added executable line appears in `missing_lines` (the list is empty).
- The one remaining partial branch `98->97` is in the unchanged evidence-discovery loop and predates this change (present in the baseline row).
