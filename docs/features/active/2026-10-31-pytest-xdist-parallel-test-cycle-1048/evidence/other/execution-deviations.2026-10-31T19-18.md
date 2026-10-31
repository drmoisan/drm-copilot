# Execution deviations from the plan text (#1048)

Timestamp: 2026-10-31T19-18
Command: record of micro-actions and policy-driven adjustments made during execution
EXIT_CODE: 0
Output Summary:
Four deviations were needed to satisfy the plan's own acceptance conditions or repository policy. None adds a task or changes what a task asserts.

## D1: P1-T5 and P6-T3, governed-JSON validation

- Plan text: "`poetry run python -m scripts.dev_tools.validate_json` exits 0".
- Observation: the command exits 1 on 3700 findings in pre-existing repository JSON files under `docs/` and `scripts/`. `.vscode/tasks.json` is outside the governed globs and is JSONC, so the command never reads it.
- Substitute verification: a JSONC parse of `.vscode/tasks.json` plus a label check. Recorded in `validate-json-tasks.2026-10-31T18-16.md`.

## D2: P5-T2, the PR09 default-seam case

- Plan text: PR09 "mocks `Start-Process`, `Wait-Process`, `Remove-Item`, `New-Item`, `Get-Content`, and `Set-Content` by name".
- Observation: the PreToolUse hook `.claude/hooks/check-powershell-test-purity.ps1` rejects any Pester file whose text contains `Start-Process` ("mock the wrapper seam instead"). `.claude/rules/powershell.md` (Design Seams, Mocking Rules) requires a wrapper function for an external executable.
- Adjustment: `PoshQC.Parallel.psm1` puts the `Start-Process` call in the wrapper `Invoke-PoshQCPwshExe -PwshArgs <string[]> -LogPath <string>`, which the default `StartShardProcess` seam calls. PR09 mocks `Invoke-PoshQCPwshExe` together with `Wait-Process`, `Remove-Item`, `New-Item`, `Get-Content`, `Set-Content`, `Test-Path`, and `Write-Information`. Every default seam body of `Invoke-PoshQCParallelTest` still runs; the five-line wrapper body is not executed by unit tests.

## D3: P5-T3, module registration needed before P5-T5

- Plan text: P5-T3 acceptance is "`PoshQC.ParallelMerge.Tests.ps1` passes all eleven cases", while the sub-module registration is assigned to P5-T5.
- Observation: functions in `PoshQC.Parallel.psm1` are loaded only when `PoshQC.psm1` dot-sources the file from its sub-module list and are callable only when `Export-ModuleMember` lists them, so the P5-T3 acceptance cannot hold before that registration.
- Adjustment: P5-T3 added `PoshQC.Parallel.psm1` to the sub-module list (after `PoshQC.CoverageMerge.psm1`, before `PoshQC.Testing.psm1`) and the five names to `Export-ModuleMember` in `PoshQC.psm1`. P5-T5 added the five names to `FunctionsToExport` in `PoshQC.psd1` and ran its verification (MC05 and `Get-Command -Module PoshQC`).

## D4: P4-T1, SW03 call scope

- `Select-PoshQCShardTestFile` is not exported, so SW03 calls it inside `InModuleScope PoshQC`, like SW06. The case still passes before and after P4-T2, as the plan requires.
