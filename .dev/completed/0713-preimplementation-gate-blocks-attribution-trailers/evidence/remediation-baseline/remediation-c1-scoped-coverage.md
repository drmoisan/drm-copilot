# Remediation Cycle 1 - P0-T8 Scoped Coverage Baseline

Timestamp: 2026-09-27T04-53
Command: sh <SCRATCHPAD>/c1-cov.sh (R-COV-C1 over the 18 HRS files plus tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1)
EXIT_CODE: 0
Output Summary: 795 passed, 0 failed (FailedBlocksCount 0, FailedContainersCount 0). Line coverage 98.25 percent (168 covered, 3 missed) on `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and 98.25 percent (168 covered, 3 missed) on `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`. The new suite contributed 68 PASSED lines. The five original changed-line literals are executed in both copies; the two cycle-1 literals are not yet present.

## Counts

```text
PassedCount: 795
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
```

FAILED lines: none

New-suite PASSED lines (beginning `PASSED: preimplementation gate attribution trailers (`): 68

## Coverage

```text
LINE_COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=168 missed=3 percent=98.25
MISSED_LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 357,464,481
LINE_COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=168 missed=3 percent=98.25
MISSED_LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 357,464,481
```

## Changed lines

```text
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:36 executed
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:140 executed
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:156 executed
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:402 executed
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:410 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:36 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:140 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:156 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:402 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:410 executed
```

## C1_B_SCOPED

none (no failed ExpandedPath values)
