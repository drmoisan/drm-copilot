# Negative Controls (Filter.Tag = NegativeControl) ([P8-T2])

Timestamp: 2026-10-08T22-43
Command: sh <SCRATCHPAD>/s-pester.sh NC
EXIT_CODE: 0
Output Summary:
PESTER_SET: NC FILES=147 (all *.Tests.ps1 under tests/scripts/claude-hooks and tests/scripts/codex-hooks)
PESTER_TOTAL: 4090 (4082 RESULT NotRun lines are tests excluded by the tag filter; 8 executed)
PESTER_PASSED: 8
PESTER_FAILED: 0
PESTER_SKIPPED: 0
PESTER_FAILED_BLOCKS: 0
PESTER_FAILED_CONTAINERS: 0

## Executed negative controls (8 executions, all Passed)

| Row | Runtime | Result |
|---|---|---|
| IV-16 | claude | RESULT Passed |
| IV-16 | codex | RESULT Passed |
| PM-29 | claude | RESULT Passed |
| PM-29 | codex | RESULT Passed |
| EW-39 | claude (epic gate) | RESULT Passed |
| PW-39 | claude (parallel gate) | RESULT Passed |
| CW-39 | codex (epic gate) | RESULT Passed |
| PA-20 | claude (pr-author skill gate) | RESULT Passed |

## RESULT Passed lines (verbatim)

```
RESULT Passed enforce-epic-worktree-removal-gate issue #824 decisions.no checkpoint.EW-39 denies the EW-01 command when substring presence is reinstated
RESULT Passed enforce-parallel-worktree-removal-gate issue #824 decisions.no checkpoint.PW-39 denies the PW-01 command when substring presence is reinstated
RESULT Passed enforce-pr-author-skill issue #824 decisions.inline-body and no-body pull requests.PA-20 denies the G1 command when substring presence is reinstated
RESULT Passed enforce-promotion-mcp-only issue #824 decisions, claude copy.PM-29 denies the PM-01 command when substring presence is reinstated
RESULT Passed enforce-promotion-mcp-only issue #824 decisions, codex copy.PM-29 denies the PM-01 command when substring presence is reinstated
RESULT Passed hook-command-invocation classification, claude copy (issue #824).IV-16 classifies R-824-MAIN only when substring presence is reinstated
RESULT Passed hook-command-invocation classification, codex copy (issue #824).IV-16 classifies R-824-MAIN only when substring presence is reinstated
RESULT Passed Codex enforce-epic-worktree-removal-gate issue #824 decisions.no checkpoint.CW-39 denies the CW-01 command when substring presence is reinstated
```
