# R4 Coverage Delta Record (P5-T7, issue #935)

Timestamp: 2026-10-17T01-41

CI quotations (from P0-T4 `baseline/r4-coverage-mode.2026-10-16T23-42.md`; not local measurements):
- CI baseline: 90.42% root line coverage (`adb9aa5f0`).
- CI post-change at the former PR #956 head `048d76cd8` (run 38963921545): 89.66% (16531/18437).

Local repo-scope root values (scan_folders omitted; local population; not compared with CI):
- Baseline (P0-T8, `baseline/r4-ps-test-repo.2026-10-17T00-12.md`): covered=16532 missed=1905 total=18437 pct=89.67.
- Post-change (final P5-T5, `qa-gates/r4-ps-test-repo.2026-10-17T01-40.md`): covered=16532 missed=1905 total=18437 pct=89.67.
- Difference in pct: 0.00.

Local three-folder root values (claude-hooks, codex-hooks, claude-runtime; local population; not compared with CI):
- Baseline (P0-T7, `baseline/r4-ps-test.2026-10-16T23-57.md`): covered=11910 missed=6527 total=18437 pct=64.60.
- Post-change (final P5-T3, `qa-gates/r4-ps-test.2026-10-17T01-22.md`): covered=11910 missed=6527 total=18437 pct=64.60.

Post-change CI coverage: PENDING-CI (orchestrator, S9, P7-T6, AC-24)
New and changed production-line coverage: n/a: no production file changed (every changed code file is under `tests/`, outside the `config/poshqc-coverage.json` roots)

This record does not evaluate AC-24; AC-24 stays unchecked until S9.
