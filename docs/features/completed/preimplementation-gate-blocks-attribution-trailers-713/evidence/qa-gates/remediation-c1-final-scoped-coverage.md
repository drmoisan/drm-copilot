# Remediation Cycle 1 - Final Scoped Coverage ([P4-T4])

Timestamp: 2026-09-27T05-24

Pass: 1

Command: sh <SCRATCHPAD>/c1-cov.sh (R-COV-C1 over the 18 HRS files plus `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1`; coverage on both canonical helpers copies; launcher `exec pwsh -NoProfile -File "$(dirname "$0")/c1-cov.ps1"`)

EXIT_CODE: 0

Output Summary: PassedCount 801; FailedCount 0; FailedBlocksCount 0; FailedContainersCount 0. No FAILED lines (C1_B_SCOPED is empty). 74 PASSED lines begin with `PASSED: preimplementation gate attribution trailers (`. Line coverage: `.claude` copy 98.26% (covered=169, missed=3), `.codex` copy 98.26% (covered=169, missed=3). 14 CHANGED_LINE lines, seven per copy, each `executed`. Result: PASS.

## Count lines

```text
PassedCount: 801
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
```

FAILED lines: none

New-suite PASSED lines (`PASSED: preimplementation gate attribution trailers (` prefix): 74

## Coverage

```text
LINE_COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=169 missed=3 percent=98.26
MISSED_LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 357,464,481
LINE_COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=169 missed=3 percent=98.26
MISSED_LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 357,464,481
```

## Changed lines

```text
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:36 executed
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:131 executed
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:35 executed
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:140 executed
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:156 executed
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:402 executed
CHANGED_LINE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:410 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:36 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:131 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:35 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:140 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:156 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:402 executed
CHANGED_LINE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:410 executed
```
