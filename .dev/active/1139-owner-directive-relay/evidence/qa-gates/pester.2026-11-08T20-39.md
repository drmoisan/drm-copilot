# Pester Final Gate, Cycle 1 Run 2 ([P2-T2])

Timestamp: 2026-11-08T20-30
Command: sh SCRATCH/issue-1139-pester.sh (from the worktree root: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root (Get-Location).ProviderPath; exit $r.ExitCode')
EXIT_CODE: 0
Output Summary: One Invoke-PoshQCParallelTest run of the branch-current PoshQC module, re-run once after the coverage fix recorded in pester.2026-11-08T20-31.md. Returned ExitCode 0; WorkerCount 8; wall-clock 512.06 s; all 8 shards exited 0. Counts from artifacts/pester/pester-junit.xml (merged, written 2026-11-08T20:39Z): 20502 tests, 0 failures, 0 errors, 10 skipped, 20492 passed; no failing test. Coverage from artifacts/pester/powershell-coverage.xml: repo-wide 95.68% (36412 covered, 1644 missed); OrchestratorStateOwnerDirectives.psm1 100.00% (151 covered, 0 missed); validate-orchestrator-output.ps1 99.25% (132 covered, 1 missed). No per-file or repo-wide drop against pester.2026-11-08T19-51.md; the module is at or above 90%. P1-T2 rows present in the merged JUnit: 14 B7 reject rows, 3 B7 accept rows, 3 R9 rows, all passed; plus 2 rows of the gate-fix It `B7 rejects the calendar-invalid ISO 8601 shape <Recorded>`, passed.

## Comparison With the Baseline (pester.2026-11-08T19-51.md, cited by baseline-reference.2026-11-08T20-17.md)

| Measure | Baseline | This run | Result |
|---|---|---|---|
| Tests / failed / skipped | 20464 / 0 / 10 | 20502 / 0 / 10 | +38 tests, no new failure |
| Repo-wide line coverage | 95.68% (36387/38031) | 95.68% (36412/38056) | no drop |
| `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` | 100.00% (148/148) | 100.00% (151/151) | no drop; at or above 90% |
| `.claude/hooks/validate-orchestrator-output.ps1` | 99.25% (132/133) | 99.25% (132/133) | no drop |

## P1-T2 Row Counts (merged JUnit)

| It | Cases | Failed |
|---|---|---|
| `B7 rejects recorded_at <Recorded> with expires_at <Expires>` (6 existing + 8 new) | 14 | 0 |
| `B7 accepts the ISO 8601 shape <Recorded>` | 3 | 0 |
| `R9 rejects the non-ISO decided_at <Decided>` | 3 | 0 |
| `B7 rejects the calendar-invalid ISO 8601 shape <Recorded>` (gate fix) | 2 | 0 |

| Suite | Tests | Failures |
|---|---|---|
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1` | 74 | 0 |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Records.Tests.ps1` | 53 | 0 |
| `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectives.Tests.ps1` | 22 | 0 |
