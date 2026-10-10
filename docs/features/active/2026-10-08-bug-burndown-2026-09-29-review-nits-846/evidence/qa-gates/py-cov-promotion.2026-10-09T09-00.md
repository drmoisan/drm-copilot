# Final QC: potential_to_issue targeted coverage ([P10-T5])

Timestamp: 2026-10-09T21-53
Loop-Iteration: 1
Command: poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue.py" "tests/scripts/dev_tools/test_potential_to_issue_branches.py" "tests/scripts/dev_tools/test_potential_to_issue_bug_bodies.py" "tests/scripts/dev_tools/test_potential_to_issue_cli_and_adapters.py" "tests/scripts/dev_tools/test_potential_to_issue_content.py" "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py" "tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py" "tests/scripts/dev_tools/test_potential_to_issue_move_verification.py" "tests/scripts/dev_tools/test_potential_to_issue_work_modes.py" "--cov=scripts.dev_tools.potential_to_issue" --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/python/cov-targeted.json"
EXIT_CODE: 0
Output Summary: 59 passed in 0.97s. Module 136 statements, 1 missed, 38 branches, 1 partial, 99%, Missing: 298 (the same uncovered statement as baseline line 296, shifted by two lines by the Phase 6 docstring and comment edits; verified with `sed -n 298p` on the working tree and `git show <merge-base>:scripts/dev_tools/potential_to_issue.py | sed -n 296p`, both printing `_emit(f"Fallback reason: {fallback_reason}")`; merge-base used is 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a, substituted for e7d3779b398604af919678c16c877c8539a86cc0). COVJSON: line 99.26 branch 97.37 (>= 85 / >= 75); identical to baseline.

## Term-missing row (verbatim)

```
Name                                      Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------
scripts\dev_tools\potential_to_issue.py     136      1     38      1    99%   298
-------------------------------------------------------------------------------------
TOTAL                                       136      1     38      1    99%
```

## Block 2

Command: poetry run python -c "import json,sys;d=json.load(open(sys.argv[1]));[print(k,'line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2) if s['num_branches'] else 'n/a') for k,v in d['files'].items() for s in [v['summary']]]" artifacts/python/cov-targeted.json
EXIT_CODE: 0
Output Summary: `scripts\dev_tools\potential_to_issue.py line 99.26 branch 97.37`

## Baseline ([P0-T13]) versus post-change

| Module | Baseline line | Post line | Baseline branch | Post branch |
| --- | --- | --- | --- | --- |
| scripts.dev_tools.potential_to_issue | 99.26 | 99.26 | 97.37 | 97.37 |
