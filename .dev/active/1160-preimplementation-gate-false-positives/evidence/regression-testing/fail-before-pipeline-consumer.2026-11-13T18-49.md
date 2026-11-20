# Fail-Before — D16 Pipeline Consumers ([P1-T4] [expect-fail])

Timestamp: 2026-11-13T18-49
Command: sh SCRATCH/issue-1160-r4-gate.sh p1 (pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <worktree>; exit with the returned ExitCode), then sh SCRATCH/issue-1160-r4-shards.sh (reads artifacts/pester/parallel/shard-<i>/pester-junit.xml)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: one Invoke-PoshQCParallelTest run on the unfixed commands sibling (head of [P1-T3]), 8 workers, wall clock 601.94 s, run 2026-11-13T18-39 to 2026-11-13T18-49. Shard JUnit totals: 22305 tests, 66 failures, 0 errors, 10 skipped (22229 passed). The 66 failures are exactly the expected set named by [P1-T2] and [P1-T3]: 32 classification failures (8 rows x 2 tests x 2 runners) and 34 commands-suite failures (17 cases x 2 surfaces). No other test fails; the five D16 guard cases pass on both surfaces. No merged JUnit or coverage file is written by a failed run, so the counts come from the eight shard JUnit files.

## Shards

| Shard | Tests | Failures | Errors | Skipped |
|---|---|---|---|---|
| 1 | 548 | 0 | 0 | 0 |
| 2 | 2428 | 0 | 0 | 2 |
| 3 | 3797 | 16 | 0 | 1 |
| 4 | 2815 | 34 | 0 | 7 |
| 5 | 3366 | 0 | 0 | 0 |
| 6 | 3207 | 0 | 0 | 0 |
| 7 | 3815 | 16 | 0 | 0 |
| 8 | 2329 | 0 | 0 | 0 |

## Expected failures, by name (66)

Claude runner (`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Tests.ps1`, Context `existing denials stay classified with unchanged deny text`) and Codex runner (`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classification.Tests.ps1`, same Context), each:

- `classifies existing-denial row ED-43` to `classifies existing-denial row ED-50` (8)
- `denies existing-denial row ED-43 with the generic deny text` to `denies existing-denial row ED-50 with the generic deny text` (8)

Commands suite (`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1`), on each of `Claude copy of the sibling` and `Codex copy of the sibling`:

- `mention-host table (spec AC-5)`: `returns exactly the decision D2 groups`; `returns exactly the decision D2 executing-option exclusions`
- `pipeline consumers confirm the hit (decision D16)`: `confirms probe ED-43, a ForEach-Object consumer of Get-ChildItem tests/scripts/`; `confirms probe ED-44, a ForEach-Object consumer of a filtered Get-ChildItem`; `confirms probe ED-45, a % consumer`; `confirms probe ED-46, a ForEach-Object consumer of Get-Command pytest`; `confirms probe ED-47, a ForEach-Object consumer calling the Source property`; `confirms probe ED-48, a ForEach-Object consumer of Get-Command Invoke-Pester`; `confirms probe ED-49, an xargs env consumer of echo`; `confirms sort with --compress-program`; `confirms a non-host stage after an intervening host stage`; `reads NotHost before the host groups`; `confirms a PowerShell expression consumer containing ::`; `confirms a PowerShell expression consumer containing .Invoke`; `skips nested payload records when following the pipeline`; `reads NotHost before the host groups in the consumer check`; `confirms a consumer with an executing option`

Each failure was confirmed by name from the shard JUnit files (16 Claude runner, 16 Codex runner, 34 commands suite).
