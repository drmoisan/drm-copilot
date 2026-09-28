# P5-T4 Final Scoped Coverage Run

Timestamp: 2026-09-27T03-46
Pass: 1
Command: sh <SCRATCHPAD>/x713-cov-p5.sh (R-COV over the 18 HRS files plus tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1)
EXIT_CODE: 0
Output Summary: 795 passed, 0 failed, 0 failed blocks, 0 failed containers (727 HRS plus 68 new). Exactly 68 PASSED lines belong to the new suite. Line coverage is 98.25% (168 covered, 3 missed) for both canonical helpers copies. All ten CHANGED_LINE entries (five per copy) read executed.

PassedCount: 795
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0

FAILED lines: none

NEW_SUITE_PASSED_LINES: 68 (lines beginning `PASSED: preimplementation gate attribution trailers (`)

```text
LINE_COVERAGE: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=168 missed=3 percent=98.25
MISSED_LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 357,464,481
LINE_COVERAGE: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 covered=168 missed=3 percent=98.25
MISSED_LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 357,464,481
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

B_SCOPED is empty, and no FAILED line exists, so no failure belongs to the new suite, the Parity suite, or the legacy-codex suite.
