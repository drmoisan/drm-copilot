# Execution deviations from the plan text (#1048)

Timestamp: 2026-10-31T19-18
Command: record of micro-actions and policy-driven adjustments made during execution
EXIT_CODE: 0
Output Summary:
Six deviations were needed to satisfy the plan's own acceptance conditions or repository policy. None adds a task or changes what a task asserts.

## D1: P1-T5 and P6-T3, governed-JSON validation

- Plan text: "`poetry run python -m scripts.dev_tools.validate_json` exits 0".
- Observation: the command exits 1 on 3700 findings in pre-existing repository JSON files under `docs/` and `scripts/`. `.vscode/tasks.json` is outside the governed globs and is JSONC, so the command never reads it.
- Substitute verification: a JSONC parse of `.vscode/tasks.json` plus a label check. Recorded in `validate-json-tasks.2026-10-31T18-16.md`.
- P6-T3 repeat: after the `PoshQC: 4 test (Pester, parallel)` task was added, `validate_json` again exited 1 with the same 3700 findings, none naming a `.vscode` path. The JSONC parse succeeds (55 tasks), and both `PoshQC: 4 test (Pester)` (unchanged) and `PoshQC: 4 test (Pester, parallel)` are present.

## D2: P5-T2, the PR09 default-seam case

- Plan text: PR09 "mocks `Start-Process`, `Wait-Process`, `Remove-Item`, `New-Item`, `Get-Content`, and `Set-Content` by name".
- Observation: the PreToolUse hook `.claude/hooks/check-powershell-test-purity.ps1` rejects any Pester file whose text contains `Start-Process` ("mock the wrapper seam instead"). `.claude/rules/powershell.md` (Design Seams, Mocking Rules) requires a wrapper function for an external executable.
- Adjustment: `PoshQC.Parallel.psm1` puts the `Start-Process` call in the wrapper `Invoke-PoshQCPwshExe -PwshArgs <string[]> -LogPath <string>`, which the default `StartShardProcess` seam calls. PR09 mocks `Invoke-PoshQCPwshExe` together with `Wait-Process`, `Remove-Item`, `New-Item`, `Get-Content`, `Set-Content`, `Test-Path`, and `Write-Information`. Every default seam body of `Invoke-PoshQCParallelTest` still runs; the five-line wrapper body is not executed by unit tests.

## D3: P5-T3, module registration needed before P5-T5

- Plan text: P5-T3 acceptance is "`PoshQC.ParallelMerge.Tests.ps1` passes all eleven cases", while the sub-module registration is assigned to P5-T5.
- Observation: functions in `PoshQC.Parallel.psm1` are loaded only when `PoshQC.psm1` dot-sources the file from its sub-module list and are callable only when `Export-ModuleMember` lists them, so the P5-T3 acceptance cannot hold before that registration.
- Adjustment: P5-T3 added `PoshQC.Parallel.psm1` to the sub-module list (after `PoshQC.CoverageMerge.psm1`, before `PoshQC.Testing.psm1`) and the five names to `Export-ModuleMember` in `PoshQC.psm1`. P5-T5 added the five names to `FunctionsToExport` in `PoshQC.psd1` and ran its verification (MC05 and `Get-Command -Module PoshQC`).

## D5: P7-T3, defect found by the first concurrent run

- Observation: the first `Invoke-PoshQCParallelTest` run (8 workers) stopped with `Wait-Process: Cannot find a process with the process identifier ...`. The default `WaitShardProcess` seam called `Wait-Process -Id`, which fails when a shard process has already exited before the runner waits on it, because the lookup by id no longer finds the process.
- Fix (in P7-T3, mechanically necessary to complete the concurrent run): the default seam calls `$Process.WaitForExit()` on the process object the runner holds and then reads `ExitCode`. In PR09, the fake process object returned by the mocked `Invoke-PoshQCPwshExe` reports exit code 99 until its `WaitForExit` script method runs, so the asserted overall exit code of 0 proves the default seam waited on every shard; the `Wait-Process` mock and its assertion were removed. `PoshQC.ParallelRunner.Tests.ps1` and `PoshQC.ParallelMerge.Tests.ps1` pass (21 passed), and the bundled copy was re-mirrored (see the mirror-hash record).

## D4: P4-T1, SW03 call scope

- `Select-PoshQCShardTestFile` is not exported, so SW03 calls it inside `InModuleScope PoshQC`, like SW06. The case still passes before and after P4-T2, as the plan requires.

## D6: P10-T7, Shard coverage below the P0-T3 value on the first final run

- Observation: the first P10-T7 run reported `PoshQC.Shard.psm1` at 98.55% line coverage, below the P0-T3 value of 100%. Lines 296 and 316 were not executed: the non-object document branch and the non-relative key branch of `ConvertFrom-PoshQCShardWeightJson`.
- Fix (in P10-T7, mechanically necessary to meet its acceptance): SW04 gained two malformed documents, `'[1, 2]'` and a weights map keyed by `/abs/tests/a.Tests.ps1`. No production code changed. The toolchain loop was restarted from P10-T1, and every earlier gate record carries a loop-restart note.
