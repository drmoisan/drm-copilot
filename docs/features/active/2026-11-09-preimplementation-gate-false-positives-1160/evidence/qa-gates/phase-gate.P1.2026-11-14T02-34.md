# Phase Gate P1 (cycle 4, [P1-T4], expect-fail phase)

Timestamp: 2026-11-14T02-34
Command: stage 1-2: sh SCRATCH/issue-1160-r4-static.sh (Invoke-Formatter comparison, no rewrite, and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the six files of [P0-T1], including both changed test files); stage 3: not applicable (PowerShell); stage 4: no architecture-boundary tool applies to the changed files; stage 5: sh SCRATCH/issue-1160-r4-gate.sh c4p1 (one Invoke-PoshQCParallelTest run); stage 6: no selection, because no mirrored or bundled file changed in Phase 1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: static stage 0 formatter differences and 0 analyzer findings over 6 files (Cases file 235 lines, commands suite 380 lines); `git status --porcelain` digest equal before and after. Unit stage: 23685 tests, 84 failed, 0 errors, 10 disabled; the 84 failures are exactly the named [expect-fail] tests of [P1-T2] (80) and [P1-T3] (4), listed in `evidence/regression-testing/fail-before-subcommand-position.2026-11-14T02-34.md`, and Phase 2 ([P2-T1]) makes them pass. Every other test passes. The gate passes under the expect-fail phase rule.
