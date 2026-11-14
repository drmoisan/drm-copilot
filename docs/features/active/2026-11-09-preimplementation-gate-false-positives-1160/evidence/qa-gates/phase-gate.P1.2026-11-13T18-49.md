# Phase Gate — Phase 1 ([P1-T4] [expect-fail] [phase-gate])

Timestamp: 2026-11-13T18-49
Command: sh SCRATCH/issue-1160-r4-static.sh (Invoke-Formatter comparison and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the six files of [P0-T1]); sh SCRATCH/issue-1160-r4-gate.sh p1 (one Invoke-PoshQCParallelTest run on the branch-current scripts/powershell/PoshQC/PoshQC.psd1)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: format 0 differences and analyzer 0 findings over 6 files (git status --porcelain digest unchanged before and after); type check not applicable to PowerShell; architecture-boundary stage not applicable (no boundary rule covers these files); unit stage one Invoke-PoshQCParallelTest run, 22305 tests, 66 failures, 0 errors, 10 skipped; the 66 failures are exactly the [expect-fail] tests named by [P1-T2] and [P1-T3], which [P2-T1] makes pass; every other test passes; contract stage has no selection (no mirrored or bundled file changed in Phase 1).

| Stage | Command | Exit code | Findings |
|---|---|---|---|
| Format | Invoke-Formatter comparison, 6 files | 0 | 0 differences |
| Lint | Invoke-ScriptAnalyzer, 6 files | 0 | 0 findings |
| Type check | not applicable (PowerShell) | n/a | n/a |
| Unit | Invoke-PoshQCParallelTest (8 workers, 601.94 s) | 1 (expected) | 66 expected failures, 0 other failures |
| Contract | none selected (no mirrored or bundled file changed) | n/a | n/a |

Expected failures (listed by name in `evidence/regression-testing/fail-before-pipeline-consumer.2026-11-13T18-49.md`): `classifies existing-denial row ED-43` to `ED-50` and `denies existing-denial row ED-43` to `ED-50 with the generic deny text` in both classification runners (32); the two updated pins `returns exactly the decision D2 groups` and `returns exactly the decision D2 executing-option exclusions` and the fifteen cases of `pipeline consumers confirm the hit (decision D16)` on both surfaces of the commands suite (34). The five cases of `pipeline guards keep a mention unclassified (decision D16)` pass on both surfaces.
