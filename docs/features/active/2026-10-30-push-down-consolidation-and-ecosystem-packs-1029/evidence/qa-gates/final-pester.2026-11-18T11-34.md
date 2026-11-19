# Final QC: Pester (P5-T4)

Timestamp: 2026-11-18T11-34
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (Invoke-PoshQCParallelTest -Root . through the launcher; integration and golden lanes excluded)
EXIT_CODE: 1
Output Summary: Returned `ExitCode` 1 (workers=8, wall-clock 721.87 s). Counts from the eight per-shard `artifacts/pester/parallel/shard-<i>/pester-junit.xml` files (no merged `artifacts/pester/pester-junit.xml` is written when a shard fails): 29032 tests, 1 failure, 0 errors, 22 disabled — identical to the `Phase 0 baseline` (`evidence/baseline/baseline-pester.2026-11-18T08-22.md`). The only failure is the pre-existing `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` case `reports no drift for any generated target in the working tree`, with the identical message (drift in `.claude/rules/orchestrator-state.md` and its bundle copy, files this item does not change). No new failing test. `FileSizePolicy.RepoGate.Tests.ps1` passed 5 of 5; the `*.Manifest.Tests.ps1` suites and `ProcessReductionChain.Ledger.Tests.ps1` passed. Repo-wide line coverage: not recorded — no merged coverage file exists for a run with a failing shard, as at the baseline. In-scope PowerShell files: none.

## Deviation from the literal acceptance

P5-T4's acceptance names `ExitCode` 0 and zero failures. Both are unreachable while the upstream drift exists, and the repair (regenerating a file under `.claude/rules/`) is outside this item's scope and outside what this executor may edit. Per `evidence/other/execution-decision.pester-baseline-drift.2026-11-18T08-22.md`, the gate is judged by the plan's comparison rule against the `Phase 0 baseline`: no new failing test. That holds. The CI shard jobs `poshqc / PowerShell QC shard 1`–`3` will report the same pre-existing failure until the integration branch regenerates the rule; this is listed as pending-CI in the final report.
