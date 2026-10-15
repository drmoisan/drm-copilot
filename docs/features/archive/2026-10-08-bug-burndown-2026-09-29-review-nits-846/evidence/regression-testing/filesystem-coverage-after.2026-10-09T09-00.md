# Regression: potential_to_issue_filesystem coverage with partial_also and the retained Protocol test ([P6-T3], AC-18)

Timestamp: 2026-10-09T21-29
Command: poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py" "--cov=scripts.dev_tools.potential_to_issue_filesystem" --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/python/cov-targeted.json"
EXIT_CODE: 0
Output Summary: 8 passed in 0.13s. Module 31 statements, 0 missed, 14 branches, 0 partial, 100%. Baseline ([P0-T12]): line 100 / branch 100.

```
Name                                                 Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\potential_to_issue_filesystem.py      31      0     14      0   100%
TOTAL                                                   31      0     14      0   100%
============================== 8 passed in 0.13s ==============================
```

## Block 2 (COVJSON)

Command: poetry run python -c "import json,sys;d=json.load(open(sys.argv[1]));[print(k,'line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2) if s['num_branches'] else 'n/a') for k,v in d['files'].items() for s in [v['summary']]]" artifacts/python/cov-targeted.json
EXIT_CODE: 0
Output Summary: line 100.0, branch 100.0 (>= 85 and >= 75).

```
scripts\dev_tools\potential_to_issue_filesystem.py line 100.0 branch 100.0
```

## Block 3

Command: git diff --name-only 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a -- "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py"
EXIT_CODE: 0
Output Summary: no output. Merge-base substitution: 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a used in place of e7d3779b398604af919678c16c877c8539a86cc0 as recorded in [P0-T4].

## Block 4

Command: git status --porcelain -- "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py"
EXIT_CODE: 0
Output Summary: no output.

## Block 5

Command: grep -c -F -e "def test_file_system_protocol_members_declare_no_behavior" "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py"
EXIT_CODE: 0
Output Summary: 1.

Acceptance (AC-18): pytest exit 0 with 8 passed; COVJSON line 100 and branch 100; both git blocks print nothing; the Protocol test is present once. PASS.
