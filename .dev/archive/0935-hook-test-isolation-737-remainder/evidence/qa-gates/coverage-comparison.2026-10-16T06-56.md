# Coverage Comparison, COV-1 (P5-T3)

Timestamp: 2026-10-16T06-56
Command: D-COV-FRESH: stat -c %y artifacts/pester/powershell-coverage.xml; grep -n -F -e 'report name="Pester (' artifacts/pester/powershell-coverage.xml. D-COV-READ: grep -c -E -e '^  .counter type="LINE" missed=' artifacts/pester/powershell-coverage.xml; grep -E -e '^  .counter type="LINE" missed=' artifacts/pester/powershell-coverage.xml | awk -F'"' '{ printf "covered=%d missed=%d total=%d pct=%.2f\n", $6, $4, $6 + $4, 100 * $6 / ($6 + $4) }'. Configuration check: git diff --quiet origin/main...HEAD -- config
EXIT_CODE: 0
Output Summary:
- Baseline (CI run 38730332356 at `adb9aa5f0`, from `baseline/ci-baseline.2026-10-16T00-11.md`): covered 16381, missed 1735, denominator 18116, line coverage 90.42%.
- Post-change (regenerated local file, P5-T2 run at HEAD `c40ee18db`): K = 1; covered 11598, missed 682, denominator 12280, line coverage 94.45%.
- Denominators: post-change 12280 vs baseline 18116; difference 12280 - 18116 = -5836 lines.
- Folder list used: `scan_folders` omitted; configured set `scripts`, `tests/powershell`, `tests/scripts` (`config/poshqc-scan.json` `test.scanFolders`).
- Last-write time: before `2026-10-16 02:25:17.045727800 -0400` (P5-T1), after `2026-10-16 02:54:06.628638700 -0400`.
- `report name` line: before `3:<report name="Pester (10/16/2026 02:24:53)">`, after `3:<report name="Pester (10/16/2026 02:53:39)">`. The file was rewritten by the P5-T2 run.
- P0-T5 roots result: `ROOTS-IDENTICAL` (`baseline/r1-coverage-population.2026-10-16T04-39.md`).
- P5-T2 call disposition: returned without error (`qa-gates/r1-coverage-run.2026-10-16T06-56.md`).
- Post-change percent vs 85.00: 94.45 is at or above 85.00. Post-change percent vs 90.42: 94.45 is at or above 90.42. These comparisons are over a different population (12280 lines) from the baseline (18116 lines) and are therefore not a like-for-like comparison.
- Changed-production-line coverage: n/a: no production file changed (all changed files are under `tests/`, outside the `config/poshqc-coverage.json` roots).
- Configuration check: `git diff --quiet origin/main...HEAD -- config` exited 0 (no configuration change).
- Observation: the local denominator (12280) equals the denominator of the three-folder runs (P0-T6, P5-T1), so the local runner did not reproduce the CI coverage population even with `scan_folders` omitted. This is consistent with the known limitation recorded in the plan (the MCP runner can resolve coverage settings from the installed extension rather than the repository copy); the cause was not demonstrated in this cycle.

Condition evaluation (Step A, order C1 to C7):
- C1 `RUN-RAISED`: not held (the call returned).
- C2 `FILE-NOT-REWRITTEN`: not held (last-write time and `report name` line both changed).
- C3 `COUNTER-NOT-FOUND`: not held (K = 1).
- C4 `ROOTS-DRIFT`: not held (P0-T5 recorded `ROOTS-IDENTICAL`).
- C5 `DENOMINATOR-MISMATCH`: held (total 12280 is not 18116).
- C6 `BELOW-85`: not held (94.45).
- C7 `BELOW-BASELINE`: not held (94.45).

COV-1-CONDITIONS: DENOMINATOR-MISMATCH
COV-1-OUTCOME: MEASUREMENT-POPULATION-MISMATCH (DENOMINATOR)
COV-1-STATUS: awaiting_ci (P7-T6, AC-24)

Rule 2 recording: total 12280, required 18116, difference -5836. `MEASUREMENT-POPULATION-MISMATCH` is a recorded outcome, not a pass; COV-1 is reclassified `awaiting_ci` for orchestrator task P7-T6 (AC-24) on the PR head.
