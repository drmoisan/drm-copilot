# Victim Set (P0-T6)

Timestamp: 2026-11-03T23-20
Command: pwsh -NoProfile -File SCRATCH/issue-1066-junit-sets.ps1 -First RAW/baseline-forward.xml -Second RAW/baseline-excluded.xml -Root <worktree root>
EXIT_CODE: 0
Output Summary:
- A (forward DEVLIST, 37 files): 94 failing keys. B (DEVLIST without TARGET, 36 files): 94 failing keys. The two lists are byte-identical.
- A_T (keys of A in TARGET): 0.
- V = A minus B minus A_T: 0 keys; suites spanned: none.
- B minus A: 0 keys.
- Acceptance result: FAIL. V is empty, so the reproduction did not occur within DEVLIST; this task is left unchecked and the run stops with BLOCKED per the task text.

## Sets

- A_T (0): none
- V (0): none
- B minus A (0): none
- B (94): identical to the failing-key list in `evidence/baseline/devtools-excluded.2026-11-03T23-18.md`; it spans the 18 suites listed there (the #1067 host-failure set).

## Diagnostic (outside the plan's task list; recorded to support the plan delta)

Command: sh SCRATCH/issue-1066-launch-diag.sh (issue-1066-run-list.ps1 over TARGET followed by the 8 suites below, to RAW/diag-with-target.xml; then over the 8 suites alone, to RAW/diag-victims-alone.xml; then issue-1066-junit-sets.ps1 over both)
EXIT_CODE: 1 for both runs (pre-existing failures)
- With TARGET first: Pester Total=391 Passed=68 Failed=323 FailedBlocks=7. Alone: Total=356 Passed=270 Failed=86.
- Failing keys only when TARGET runs first: 105, in 8 suites outside tests/scripts/dev-tools:
  - tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1: 2
  - tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1: 4
  - tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1: 1
  - tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1: 11
  - tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1: 24
  - tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1: 23
  - tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1: 32
  - tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1: 8
- Failing keys only when the 8 suites run alone: 76 (73 in tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1, 3 in tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1). These show a separate pre-existing order dependence among those suites and testcase-name changes when a block's BeforeAll fails (template names are not expanded), so the key convention is not stable for failed blocks.
- Duplicate testcase keys exist (Pester Failed=323 maps to 115 distinct failing keys in the with-TARGET run); the set tool treats a duplicated key as failing when any duplicate failed.
- Conclusion: the 7 suites that follow TARGET in the forward DEVLIST order show no outcome change from the leak, so no PATH-induced victim exists inside DEVLIST on this host.
