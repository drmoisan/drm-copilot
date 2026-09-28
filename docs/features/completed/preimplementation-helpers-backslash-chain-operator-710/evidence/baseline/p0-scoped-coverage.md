# Phase 0 Scoped Coverage Baseline (Issue #710)

Timestamp: 2026-09-27T02-03
Command: sh <SCRATCHPAD>/p0-cov.sh (exec pwsh -NoProfile -File <SCRATCHPAD>/p0-cov.ps1; R-COV of plan section 5 over the 10 HRS files, CodeCoverage.Path = the two canonical helper copies, OutputPath <SCRATCHPAD>/p0-cov.coverage.xml)
EXIT_CODE: 0
Output Summary: PassedCount 445, FailedCount 0 (FailedBlocksCount 0, FailedContainersCount 0). Line coverage .claude/hooks helpers 97.04% (164 covered, 5 missed); .codex/hooks helpers 97.04% (164 covered, 5 missed).

## Counts

```text
PassedCount: 445
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
```

## Failed Tests

none

## Coverage

```text
LINE_COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=164 missed=5 percent=97.04
LINE_COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=164 missed=5 percent=97.04
MISSED_LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 357,406,412,464,481
MISSED_LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 357,406,412,464,481
```

No `CHANGED_LINE:` line was printed (neither literal exists on base).

## B_SCOPED

none (no failed ExpandedPath values in the scoped baseline run)
