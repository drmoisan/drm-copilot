# Stage G PowerShell Test Final Gate (P3-T2)

Timestamp: 2026-11-08T13-12
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1 and running Invoke-PoshQCParallelTest from the worktree root (one run; launcher stored under SCRATCH), with the 0009 entry, its index row, and its stored patch present in the working tree; counts read from artifacts/pester/pester-junit.xml and line coverage from artifacts/pester/powershell-coverage.xml by reader scripts under SCRATCH
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest returned ExitCode 0 (workers=8, wall-clock 916.88 s, run 13-12 to 13-27 UTC); every shard exited 0; merged JUnit and coverage written by this run.
  JUnit totals: 19666 tests, 0 failures, 0 errors, 10 disabled. No failing test.
  Suite counts by test-name prefix (tests, failed): RG- 377, 0; RGC- 233, 0; OCR- 27, 0; PRL- 87, 0; PRC- 55, 0; PGW- 56, 0; CRS- 58, 0; LEC- 77, 0.
  Passed: RG-ci-cross-check-synthetic-after-pass (and its RG-GATE-TOKEN-LEADS-EVERY-DENY row), RGC-ci-cross-check-synthetic-after-pass, OCR-CROSS-CHECK-SYNTHETIC-ENTRY-VALID, OCR-CROSS-CHECK-SYNTHETIC-ENTRY-BLOCKS-COMPLETION, PRC-LEDGER-CHAIN-HOLDS, PRC-LEDGER-END-STATE-RECORDED, PRC-LEDGER-SUBCHAIN-HOLDS.
  Repo-wide PowerShell line coverage: 95.56% (35308 of 36947 lines).
  No figure comes from MCP output.

## Comparison With the Phase 0 Baseline

Baseline: `stage-g-powershell-test-baseline.2026-11-08T03-35.md` (16132 tests, 0 failures, 10 disabled; 94.18%, 24954 of 26496 lines). The baseline was recorded before the origin/main merge that brought in PRs #1124 and #1125.

- Failing tests: 0 before, 0 after. No new failing test.
- Test count: +3534 (16132 to 19666).
  - Stage G: +82. LEC- +77 (new suite `less-evidence-contract.Tests.ps1`); RG- +2 (the `ci-cross-check-synthetic-after-pass` row and its `RG-GATE-TOKEN-LEADS-EVERY-DENY` row); RGC- +1; OCR- +2.
  - Merged PRs #1124 and #1125: +3362 from the 126 test files the merge added (all 126 present in this run's JUnit), among them the `tests/scripts/claude-lib/docs/Docs*.Tests.ps1` suites, the `docs-authoring-roles.*.Tests.ps1` suites, and the `epic-progress-report` Durations, Gather, Stages, and Steps suites; +90 net, by subtraction, from the 9 test files the merge modified (`cleanup-merged-worktrees-workflow.EndToEnd`, `hook-dependency-failure.Claude`, `subagentstop-uncaught-error`, `enforcement-hooks-no-python-invocation`, and five `epic-progress-report` suites), which hold 409 tests in this run.
- Repo-wide line coverage: 94.18% to 95.56%, no drop. The denominator grew by 10451 lines, all from production PowerShell that the merge added or changed (`.claude/lib/docs/*.psm1`, the docs hooks, and the `epic-progress-report` scripts, with their bundle copies). Stage G changes no production PowerShell file, so it moves neither figure and no per-file row applies.
