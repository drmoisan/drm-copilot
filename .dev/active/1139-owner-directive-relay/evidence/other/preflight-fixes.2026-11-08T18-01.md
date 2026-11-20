# Preflight Fixes - owner-directive-relay (#1139)

Timestamp: 2026-11-08T18-01
Plan: docs/features/active/2026-11-08-owner-directive-relay-1139/plan.2026-11-08T12-32.md
Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-11-08-owner-directive-relay-1139/plan.2026-11-08T12-32.md (run with VIRTUAL_ENV unset), and the MCP validate_orchestration_artifacts plan route
EXIT_CODE: 0
Output Summary: both validators pass before and after the fixes below; no warning was reported. The fixes edit task text only; no task was added, removed, or reordered.

## Fixes

1. [P2-T1] | stale anchor | The guarded imports of `.claude/hooks/validate-orchestrator-output.ps1` are script-level statements, not part of `Get-OrchestratorOutputBlockDecision`. The task now places the new guarded import in the script-level import block (above `Get-CheckpointFileContent`) and the call inside `Get-OrchestratorOutputBlockDecision`. The import form and the call position are unchanged.
2. [P2-T1] | missing disposition for changed existing behavior | Added the existing tests that read this hook and were not named: `hook-dependency-failure.SpecialCases.Tests.ps1` and `subagentstop-uncaught-error.Tests.ps1` (prefix unchanged), and `tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1` (the import records through `Add-HookDependencyFailure`, not a scoped handler). Each is unchanged.
3. [P3-T2] | missing disposition for changed existing behavior | Named `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, whose ledger entries 0002, 0003, and 0009 record regions in the orchestrate skills, the orchestrator agent, and the parallel-orchestrate skill. Disposition: unchanged, because each pointer is placed outside every recorded region.
4. [P3-T3] | missing disposition and test-name citation | Named the same ledger test (entry 0007 records both epic-orchestrate files) and `test_parallel_orchestrator_surface_contracts.py`, the test file that reads `PINNED_FROZEN_SURFACE_HASHES`.
5. [P3-T4] | missing disposition for changed existing behavior | Named the same ledger test (entries 0002 and 0003 record regions in `.claude/rules/orchestrator-state.md`). Disposition: unchanged, because the new section and bullet are placed outside those regions.
6. [P3-T5] | missing disposition for changed existing behavior | Named the same ledger test, including `PRC-LEDGER-NO-EXCEPTIONS`, which filters brief errors. Entries 0001, 0002, 0003, and 0006 record brief regions, including the `Merge guard (#1097)` bullet of `## Hook Execution Context`. Disposition: unchanged, because the bullet is placed outside those regions.
7. [P4-T3] | AC bookkeeping | P3-T6 defers S2 to P4-T3, but the P4-T3 AC list omitted S2. Without that entry, P4-T6 ("every AC box checked") could not pass. S2 was added, and `ProcessReductionChain.Ledger` was added to the suites listed as passed.
8. [P4-T4] | test-name citation | "frozen-surface tests of `parallel_orchestrator_surface_expectations.py`" names an expectations module. The task now names the test file `test_parallel_orchestrator_surface_contracts.py`, which reads that module.

## Probe

- A pytest probe (`pytest -n auto`, no coverage) ran in the item worktree on the unmodified branch: 16560 passed, 6 skipped, exit 0. The P4-T4 zero-failure gate is therefore not contradicted by a pre-existing failure. Raw output stays under SCRATCH and is not evidence.
