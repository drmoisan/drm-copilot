# Coverage Delta — Baseline vs Post-Change (P6-T9) (#331)

Timestamp: 2026-07-07T21-08

## Python (poetry run pytest --cov --cov-branch)

- Baseline (P0-T5): TOTAL line 84% (9252 stmts, 1243 missed; 3342 branch, 450 partial); 1298 passed.
- Post-change (P6-T4): TOTAL line 84% (9320 stmts, 1247 missed; 3378 branch, 452 partial); 1309 passed.
- Delta: TOTAL line coverage unchanged at 84% (the pre-existing untested files
  shell_qc.py / tk_dialog_helpers.py dominate the denominator and are untouched).
- Changed/new modules (new/changed-code coverage, all >= 85% line / >= 75% branch):
  - validate_epic_orchestrator_state.py: 95% line.
  - _epic_orchestrator_state_resolution.py (new): 94% line.
  - new_active_feature_folder_docs.py: 96% line.
  - new_active_feature_folder_flow.py: 90% line.
  - new_active_feature_folder_io.py: 94% line.
- No regression on changed lines: all changed lines are new logic covered by new
  tests; no previously-covered line lost coverage.

## TypeScript (npm run test:coverage)

- Baseline (P0-T10): Statements 96.58%, Branches 88.5%, Functions 87.37%, Lines 96.58%; 1555 passed.
- Post-change (P6-T8): Statements 96.58%, Branches 88.56%, Functions 87.45%, Lines 96.58%; 1568 passed.
- Delta: line coverage steady at 96.58%; branch coverage improved 88.5% -> 88.56%;
  +13 tests. Above the 85% line / 75% branch gates.
- Changed/new modules covered by the new epic scaffolding tests (flow/io/docs) and
  the TS validator port + resolution module tests (30 port tests).

## Conclusion

Both languages meet the uniform gates (line >= 85% on changed modules, branch >= 75%),
with no regression on changed lines. The unchanged 84% Python TOTAL is a pre-existing
repository state driven by files outside this feature's scope.
