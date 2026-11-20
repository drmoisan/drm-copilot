# Phase Gate — Phase 1 (cycle 3, [P1-T4] [expect-fail] [phase-gate])

Timestamp: 2026-11-14T00-57
Command: sh SCRATCH/issue-1160-r4-tc.sh (Invoke-Formatter comparison and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the two changed test files); sh SCRATCH/issue-1160-r4-gate.sh c3p1 (one Invoke-PoshQCParallelTest run on the branch-current scripts/powershell/PoshQC/PoshQC.psd1)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: static stage 0 formatter differences and 0 analyzer findings over the Cases file (210 lines) and the new Modelled suite (97 lines); type check not applicable to PowerShell; architecture-boundary stage not applicable (no boundary rule covers these files); unit stage one Invoke-PoshQCParallelTest run, 23215 tests, 256 failures, 0 errors, 10 skipped, and the 256 failures are exactly the [expect-fail] tests named by [P1-T2] and [P1-T3], which [P2-T1] makes pass; every other test passes; contract stage has no selection (no mirrored or bundled file changed in Phase 1).

| Stage | Command | Exit code | Findings |
|---|---|---|---|
| Format | Invoke-Formatter comparison, 2 files | 0 | 0 differences |
| Lint | Invoke-ScriptAnalyzer, 2 files | 0 | 0 findings |
| Type check | not applicable (PowerShell) | n/a | n/a |
| Unit | Invoke-PoshQCParallelTest (8 workers, 713.45 s) | 1 (expected) | 256 expected failures, 0 other failures |
| Contract | none selected (no mirrored or bundled file changed) | n/a | n/a |

Expected failures (listed by name in `evidence/regression-testing/fail-before-modelled-command.2026-11-14T00-57.md`): the 184 classification-runner tests of rows ED-51 to ED-96 (46 rows x 2 tests x 2 runners) and the 72 cases of `unmodelled constructs keep the hit classified (decision D17)` (36 cases x 2 surfaces). The three guards of `modelled constructs keep a mention unclassified (decision D17)`, ED-01 to ED-50, FP-01 to FP-17, and NG-01 to NG-09 pass on both surfaces.
