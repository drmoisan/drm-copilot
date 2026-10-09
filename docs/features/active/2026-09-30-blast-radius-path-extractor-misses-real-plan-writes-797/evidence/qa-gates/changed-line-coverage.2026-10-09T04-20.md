# Changed-Line Coverage (P6-T8, AC-15)

Timestamp: 2026-10-09T04-20
Command: git diff -U0 3d5a8446d6e39f66dd593a53280e47aedd83ba1c -- scripts/dev_tools/_blast_radius_token_shapes.py scripts/dev_tools/_blast_radius_extraction.py; poetry run python -c "import json; d=json.load(open('docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/qa-gates/python-coverage-final.json', encoding='utf-8')); [print(k, v['missing_lines'], v['missing_branches']) for k, v in d['files'].items() if k.replace(chr(92), '/').endswith(('dev_tools/_blast_radius_extraction.py', 'dev_tools/_blast_radius_token_shapes.py'))]"
EXIT_CODE: 0
Output Summary: both modules report empty missing_lines and empty missing_branches, so no added executable line and no branch on an added line is uncovered. The diff is anchored to the SHA recorded in P0-T3 (run in the shell with the literal SHA because inline `pwsh` is denied; denial text in evidence/baseline/requirements-source.2026-10-09T02-51.md).

## Added line ranges (new side of each hunk header)

| Module | Added ranges | missing_lines | missing_branches |
|---|---|---|---|
| _blast_radius_extraction.py | 50; 74-79; 88-90; 255-258; 289; 305-307; 309; 311; 318; 323 (hunk 92 is deletion-only) | [] | [] |
| _blast_radius_token_shapes.py | 15-20; 25-26; 42-48; 50-52; 61-62; 84-105; 180-218 | [] | [] |

## Coverage output

```text
scripts\dev_tools\_blast_radius_extraction.py [] []
scripts\dev_tools\_blast_radius_token_shapes.py [] []
```
