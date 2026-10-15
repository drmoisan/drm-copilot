# Final Python Coverage Values (P6-T7, AC-15)

Timestamp: 2026-10-09T04-20
Command: poetry run python -c "import json; d=json.load(open('docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/qa-gates/python-coverage-final.json', encoding='utf-8')); [print(k, v['summary']['covered_lines'], v['summary']['num_statements'], v['summary']['covered_branches'], v['summary']['num_branches']) for k, v in d['files'].items() if k.replace(chr(92), '/').endswith(('dev_tools/_blast_radius_extraction.py', 'dev_tools/_blast_radius_token_shapes.py'))]"
EXIT_CODE: 0
Output Summary: two lines.
  _blast_radius_extraction: line 97/97 = 100.0% (>= 85); branch 44/44 = 100.0% (>= 75)
  _blast_radius_token_shapes: line 25/25 = 100.0% (>= 85); branch 8/8 = 100.0% (>= 75)

## Output

```text
scripts\dev_tools\_blast_radius_extraction.py 97 97 44 44
scripts\dev_tools\_blast_radius_token_shapes.py 25 25 8 8
```
