# Python Unit and Coverage QA

Timestamp: 2026-09-03T03-20
Command: `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-final.2026-09-02T22-17.json`
EXIT_CODE: 0

Output Summary: The complete repository suite collected 4,387 cases and completed with 4,382 passed, 0 failed, and 5 skipped in 19.51 seconds. Coverage JSON was written to the declared canonical evidence path. Both bidirectional raw-byte provenance tests passed directly from the persistent fixture bytes.

LINE_COVERAGE: 92.86076591427847%
BRANCH_COVERAGE: 85.41811846689896%
LINE_COVERED: 14646
LINE_TOTAL: 15772
BRANCH_COVERED: 4903
BRANCH_TOTAL: 5740

```text
4382 passed, 5 skipped in 19.51s
```

Command: `node -e "const j=require('./docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-final.2026-09-02T22-17.json');console.log(JSON.stringify({lineCovered:j.totals.covered_lines,lineTotal:j.totals.num_statements,linePercent:j.totals.percent_statements_covered,branchCovered:j.totals.covered_branches,branchTotal:j.totals.num_branches,branchPercent:j.totals.percent_branches_covered}))"`
EXIT_CODE: 0

Output Summary: Parsed numeric line and branch coverage from the generated JSON.

```json
{"lineCovered":14646,"lineTotal":15772,"linePercent":92.86076591427847,"branchCovered":4903,"branchTotal":5740,"branchPercent":85.41811846689896}
```

Command: `$p1='tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md';$p2='tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md';git diff --quiet -- $p1 $p2;git diff --quiet HEAD -- tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/fixture.json tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/fixture.json tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py;Get-FileHash -LiteralPath $p1,$p2 -Algorithm SHA256`
EXIT_CODE: 0

Output Summary: Both working fixtures remain identical to the staged index at 101,998 bytes and raw SHA-256 `54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f`; manifests and the fixture test remain identical to HEAD. No pre-test or in-test newline rewrite occurred.

```json
{"FixtureUnstagedDiffExit":0,"SupportHeadDiffExit":0,"Hashes":["54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f","54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f"],"Sizes":[101998,101998]}
```
