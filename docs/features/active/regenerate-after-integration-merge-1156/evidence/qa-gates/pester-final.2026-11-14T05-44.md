# Pester Final Gate — remediation cycle 1, [P2-T2]

Timestamp: 2026-11-14T05-44
Command: sh SCRATCH/issue-1156-pester-gate.sh (pwsh 7 from the item worktree root: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>; launcher exits with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- One Invoke-PoshQCParallelTest run, 8 shards all exit 0, ExitCode 0, 755.57 s; merged JUnit and coverage written at the end of this run (both file times 2026-11-14T05:43:13 UTC).
- artifacts/pester/pester-junit.xml: 24344 tests, 0 failures, 0 errors, 10 skipped, 24334 passed. Named suites: `Invoke-RegenerationPath.ProcessStart.Tests.ps1` 17/0, `Invoke-RegenerationPath.Tests.ps1` 123/0 (74 result-table rows, 0 failed), `enforcement-hooks-no-python-invocation.Tests.ps1` 35/0, `FileSizePolicy.RepoGate.Tests.ps1` 5/0.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 95.90% (40303 covered, 1722 missed); `Phase 0 baseline` 95.80% (`evidence/baseline/pester-parallel.2026-11-10T04-00.md`). No drop.
- `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` (new file on this branch, no pre-change run): 91.28% (293 covered, 28 missed); threshold 85% met; prior final-gate figure 91.03% (`pester-final.2026-11-14T04-07.md`, 274 covered, 27 missed). No drop.
- New lines of `Resolve-RegenerationExecutable` and `Get-RegenerationProcessStartSpec`: every line covered except the single line of the `-Resolver` seam default (the `Get-Command` pipeline), as the plan permits. In the `Invoke-RegenerationProcess` `-Invoker` default, the resolution and start-spec lines are now covered (by the `Invoke-RegenerationProcessStep` cases of `Invoke-RegenerationPath.ProcessStart.Tests.ps1`); the remaining missed lines are the process-start statements after them, the other seam defaults, and the guarded script body, unchanged in kind from the prior gate.
