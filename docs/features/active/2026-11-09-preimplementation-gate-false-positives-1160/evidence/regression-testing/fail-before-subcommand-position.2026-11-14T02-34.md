# Fail-Before: Subcommand Position (decision D19, cycle 4, [P1-T4])

Timestamp: 2026-11-14T02-34
Command: sh SCRATCH/issue-1160-r4-gate.sh c4p1 (imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCParallelTest -Root on the worktree); failure names read from artifacts/pester/parallel/shard-<i>/pester-junit.xml through SCRATCH/issue-1160-r4-shards.sh
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: one parallel run on the unfixed commands sibling (run 2026-11-14T02-21 to 02-33, 8 shards, wall-clock 713.45 s). Shards 3 and 5 exited non-zero, so no merged artifact was written. 23685 tests across the shard JUnit files, 84 failures, 0 errors, 10 disabled. Every failure is an expected D19 test, listed below; every other test passes, including ED-01 to ED-96, ED-117 to ED-120, FP-01 to FP-17, NG-01 to NG-09, and the two D19 `clears` cases on both surfaces. No new row or case passed where it was expected to fail.

## Expected failures (84)

Classification runners (80): for each Id in ED-97, ED-98, ED-99, ED-100, ED-101, ED-102, ED-103, ED-104, ED-105, ED-106, ED-107, ED-108, ED-109, ED-110, ED-111, ED-112, ED-113, ED-114, ED-115, ED-116, the four tests

- `enforce-orchestration-preimplementation-gate.ps1 classification corpus (issue #1160)` / `classifies existing-denial row <Id>`
- `enforce-orchestration-preimplementation-gate.ps1 classification corpus (issue #1160)` / `denies existing-denial row <Id> with the generic deny text`
- `Codex enforce-orchestration-preimplementation-gate classification corpus (issue #1160)` / `classifies existing-denial row <Id>`
- `Codex enforce-orchestration-preimplementation-gate classification corpus (issue #1160)` / `denies existing-denial row <Id> with the generic deny text`

Per-Id failure count: 4 for each of the 20 Ids (40 in the Claude runner, 40 in the Codex runner; 40 `classifies`, 40 `denies ... with the generic deny text`).

Commands suite (4):

- `Claude copy of the sibling` / `subcommand position (decision D19)` / `confirms a host subcommand word that is a global option value (decision D19)`
- `Claude copy of the sibling` / `subcommand position (decision D19)` / `confirms a global option before a host subcommand (decision D19)`
- `Codex copy of the sibling` / `subcommand position (decision D19)` / `confirms a host subcommand word that is a global option value (decision D19)`
- `Codex copy of the sibling` / `subcommand position (decision D19)` / `confirms a global option before a host subcommand (decision D19)`

## Shard results

| Shard | Tests | Failures | Errors | Disabled |
|---|---|---|---|---|
| 1 | 562 | 0 | 0 | 0 |
| 2 | 3051 | 0 | 0 | 0 |
| 3 | 3552 | 4 | 0 | 1 |
| 4 | 2796 | 0 | 0 | 7 |
| 5 | 3585 | 80 | 0 | 0 |
| 6 | 3473 | 0 | 0 | 2 |
| 7 | 4287 | 0 | 0 | 0 |
| 8 | 2379 | 0 | 0 | 0 |
