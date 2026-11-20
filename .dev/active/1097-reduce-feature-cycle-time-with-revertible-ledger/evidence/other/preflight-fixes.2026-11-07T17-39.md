# Preflight Fixes: Stage R Plan

Timestamp: 2026-11-07T17-39
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T12-03.md

Single-pass preflight under `DIRECTIVE: PREFLIGHT VALIDATION ONLY`. Each entry is a trivial defect fixed in task or preamble text. No task was added, removed, or reordered.

1. `## Design` R3, `Get-ProcessReductionPatchHunk` bullet | stale parsing premise | Git appends a tab to the `---` and `+++` lines of a path that contains a space (observed for `.github/agents/Powershell DI Unit Test Engineer.agent.md` in `patches/0001-parallel-only-test-gates.patch`). The bullet now states that the parser strips that tab, so the parsed path matches the tracked file.
2. [P1-T2] | fixture precision | `PRC-HUNK-PARSES-SECTIONS` now names a path with spaces whose `---` and `+++` lines end in a tab, matching the stored-patch format.
3. [P1-T5] | validator-blind mock-scope defect | `ProcessReductionChain.psm1` imports `ProcessReductionLedger.psm1` into its own scope, so `Read-ProcessReductionLedger` resolves its filesystem cmdlets in the ledger module's scope, and a filesystem mock inside `InModuleScope ProcessReductionChain` does not reach it. The task now mocks `Read-ProcessReductionLedger` and the filesystem cmdlets inside `InModuleScope ProcessReductionChain`. The assertion is unchanged.
4. [P0-T3] | coverage figure source | Under `--cov-branch` the terminal table's `Cover` column combines lines and branches, so it does not give a line percentage. The task now computes the line percentage from the `TOTAL` row's `Stmts` and `Miss` columns and the branch percentage from the summed `BRF`/`BRH` records of `artifacts/python/lcov.info`. The figures asserted are unchanged.
5. [P2-T3] | coverage figure source | The Output Summary now reads the line and branch percentages from the same sources as [P0-T3], so the baseline and final figures are compared on the same basis.
6. [P2-T2] | stale-artifact read | A failed `Invoke-PoshQCParallelTest` run can leave older merged files in place, as the `execution-environment` brief states. The task now reads counts and failing tests from `artifacts/pester/parallel/shard-<i>/` when `ExitCode` is non-zero, as [P0-T2] already does. The acceptance is unchanged.

Validation after the fixes: the branch-current Python CLI `plan` subcommand passed with exit 0 and the two expected G4 warnings on `--cov-branch`; the merged planner hook functions `Get-PlanStructureValidationReport` and `Test-PreMortemSection` reported zero structure errors and a complete Pre-Mortem.
