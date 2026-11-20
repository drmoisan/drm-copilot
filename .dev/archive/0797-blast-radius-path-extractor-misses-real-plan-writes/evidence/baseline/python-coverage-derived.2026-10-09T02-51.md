# Baseline Python Coverage Values (P0-T11)

Timestamp: 2026-10-09T02-51
Command: poetry run python -c "import json; d=json.load(open('docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/python-coverage-baseline.json', encoding='utf-8')); [print(k, v['summary']['covered_lines'], v['summary']['num_statements'], v['summary']['covered_branches'], v['summary']['num_branches']) for k, v in d['files'].items() if k.replace(chr(92), '/').endswith(('dev_tools/_blast_radius_extraction.py', 'dev_tools/_blast_radius_token_shapes.py'))]"
EXIT_CODE: 0
Output Summary: two lines.
  _blast_radius_extraction: line 101/101 = 100.0%; branch 46/46 = 100.0%
  _blast_radius_token_shapes: line 14/14 = 100.0%; branch 4/4 = 100.0%

## Output

```text
scripts\dev_tools\_blast_radius_extraction.py 101 101 46 46
scripts\dev_tools\_blast_radius_token_shapes.py 14 14 4 4
```
