# RT-2 Python Coverage Figures

Timestamp: 2026-10-11T01-40
Task: [P2-T2]
Command: Glob artifacts/python/lcov.info; Glob artifacts/python/coverage.json; Grep artifacts/python/coverage.json pattern `"totals": \{[^}]*\}` with -o
EXIT_CODE: 0

## Output files

- `artifacts/python/lcov.info`: present
- `artifacts/python/coverage.json`: present

## Totals object (verbatim)

```
"totals": {"covered_lines": 16539, "num_statements": 17633, "percent_covered": 92.28653581697712, "percent_covered_display": "92", "missing_lines": 1094, "excluded_lines": 590, "percent_statements_covered": 93.7957239267283, "percent_statements_covered_display": "94", "num_branches": 6364, "num_partial_branches": 505, "covered_branches": 5607, "missing_branches": 757, "percent_branches_covered": 88.10496543054683, "percent_branches_covered_display": "88"}
```

## Repo-wide figures

| Metric | hit/total | Percent |
|---|---|---|
| Lines (LH/LF = covered_lines/num_statements) | 16539/17633 | 93.80 |
| Branches (BRH/BRF = covered_branches/num_branches) | 5607/6364 | 88.10 |

`num_branches` is 6364 (greater than 0), so `--cov-branch` took effect. These totals equal the sums of the lcov counters (`coverage/lcovreport.py` lines 50-52 and 147-151; `coverage/jsonreport.py` lines 61-63 and 97-100).

Output Summary: Both report files exist. Repo-wide line 93.80% (16539/17633) >= 85.00; branch 88.10% (5607/6364) >= 75.00; num_branches > 0.

## Per-changed-file figures

Task: [P2-T3]
Command: Grep artifacts/python/lcov.info pattern `^(SF|LF|LH|BRF|BRH):` (content mode, no head limit); rows assembled per `SF:` record after normalizing `\` to `/` (exact equality, no prefix change). Absent `LF:` or `BRF:` would be recorded as `0/0` (100.00); none of the 13 set members lacks either line. Arithmetic: `round(hit*100/found, 2)`.
EXIT_CODE: 0
PY_IDENTITY_EXIT (from [P0-T6]): 1 (NO-REGRESSION path unavailable; not needed, as every row passes outright)

| # | Path | LH/LF | Line % | BRH/BRF | Branch % | Verdict |
|---|---|---|---|---|---|---|
| 1 | scripts/dev_tools/_blast_radius_extraction.py | 97/97 | 100.00 | 44/44 | 100.00 | PASS |
| 2 | scripts/dev_tools/_blast_radius_token_shapes.py | 25/25 | 100.00 | 8/8 | 100.00 | PASS |
| 3 | scripts/dev_tools/_orchestrator_state_issue_adoption.py | 116/116 | 100.00 | 48/48 | 100.00 | PASS |
| 4 | scripts/dev_tools/check_quality_tiers.py | 70/70 | 100.00 | 13/14 | 92.86 | PASS |
| 5 | scripts/dev_tools/potential_to_issue.py | 135/136 | 99.26 | 37/38 | 97.37 | PASS |
| 6 | scripts/dev_tools/push_down_claude_customizations.py | 74/79 | 93.67 | 14/16 | 87.50 | PASS |
| 7 | scripts/dev_tools/push_down_claude_filesystem.py | 109/113 | 96.46 | 26/28 | 92.86 | PASS |
| 8 | scripts/dev_tools/push_down_claude_gitignore_merge.py | 48/48 | 100.00 | 14/14 | 100.00 | PASS |
| 9 | scripts/dev_tools/push_down_claude_pack_selection.py | 78/83 | 93.98 | 25/30 | 83.33 | PASS |
| 10 | scripts/dev_tools/skill_bundle_contract.py | 136/141 | 96.45 | 57/60 | 95.00 | PASS |
| 11 | scripts/dev_tools/validate_epic_orchestrator_state.py | 126/128 | 98.44 | 60/62 | 96.77 | PASS |
| 12 | scripts/dev_tools/validate_epic_planner_state.py | 167/182 | 91.76 | 81/96 | 84.38 | PASS |
| 13 | scripts/dev_tools/validate_orchestration_artifacts.py | 146/149 | 97.99 | 52/56 | 92.86 | PASS |

Rows: 13 of 13 Python set members; every member has an `SF:` record; 0 FAIL rows, 0 NO-REGRESSION rows. Lowest line: validate_epic_planner_state.py 91.76. Lowest branch: push_down_claude_pack_selection.py 83.33.

Failed tests in [P2-T1]: 0 (6944 passed, 6 skipped).

Output Summary: 13/13 rows PASS; repo-wide line 93.80%, branch 88.10%; 0 failed tests.

RT-2 VERDICT: PASS
