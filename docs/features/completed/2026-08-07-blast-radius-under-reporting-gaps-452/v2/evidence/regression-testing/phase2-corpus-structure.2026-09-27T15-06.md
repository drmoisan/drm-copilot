# Phase 2 Corpus Structure (P2-T1, P2-T2)

Timestamp: 2026-09-27T15-06

## P2-T1 authoring

The corpus `tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json` was generated from the P0-T30 case table (`<scratchpad>`/phase0-cases.json) by a scratchpad builder that added one `expected` object per case (the P2-T1 values, which equal the P0-T33 trace values under branch NO-CORRECTION-REQUIRED), replaced every {BT} marker with one literal backtick character, and pretty-printed the result with two-space indentation. The builder cross-checked every expected object against the executed P0-T31 CASE lines: 17 MATCH, 0 MISMATCH.

## P2-T2 structural checks

Command: poetry run python -c "import json, pathlib; d = json.loads(pathlib.Path('tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json').read_text(encoding='utf-8')); print('CASES=' + str(len(d['cases'])) + ' SCHEMA=' + str(d['schema_version']) + ' ISSUE=' + str(d['issue']))"
EXIT_CODE: 0
Output: CASES=17 SCHEMA=1 ISSUE=452

Command: grep -c -e '"id": ' tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json
EXIT_CODE: 0
Output: 17

Command: grep -c -F -e "{BT}" tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json
EXIT_CODE: 1 (expected for zero matches)
Output: 0

Command: grep -c -e '"plan_a": ' tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json
EXIT_CODE: 0
Output: 5

Command: git status --porcelain --untracked-files=all -- tests/fixtures/blast_radius
EXIT_CODE: 0
Output:

```
?? tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json
```

Output Summary: JSON parse reports CASES=17 SCHEMA=1 ISSUE=452; the independent grep count of "id" keys is 17; no {BT} marker remains (count 0, grep exit 1); five plan_a keys (the five plan_pair cases; their plan lines are confirmed by the P3-T2 plan-line intent test); the porcelain capture lists exactly one entry, the new corpus file with status ??, so no existing fixture was modified or deleted.
