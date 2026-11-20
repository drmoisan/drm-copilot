# Phase 0 — Codex Gate Hook Baseline Uncovered-Line Inventory (remediation cycle 2)

Timestamp: 2026-08-28T01-36
Task: [P0-T7]
Command: `python -c "<ElementTree read of artifacts/pester/powershell-coverage.xml, selecting the sourcefile element for .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 and emitting its LINE counter plus every line element whose ci attribute is 0>"`
EXIT_CODE: 0

Source report: `artifacts/pester/powershell-coverage.xml`, produced by the [P0-T6] run.
Package: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a502f12120e44837d/.codex/hooks`
Source file: `enforce-orchestration-preimplementation-gate.ps1`

## LINE counter for the file

| Metric | Value |
| --- | --- |
| Covered | **135** |
| Missed | **27** |
| Total | **162** |
| Line coverage | **83.33 percent** |

The baseline missed count is the integer **27**.

## Explicit uncovered-line list

```
197, 206, 292, 293, 294, 296, 304, 305, 306, 308, 421, 422, 426, 427, 428, 429,
430, 432, 433, 434, 435, 436, 437, 439, 441, 442, 443
```

Twenty-seven members.

## Per-line statement for the two B5 lines, backed by the report's coverage attributes

| Line | `line` element attributes read from the report | Verdict |
| --- | --- | --- |
| **197** | `nr="197" mi="1" ci="0" mb="0" cb="0"` | **UNCOVERED** — covered-instruction count `ci` is 0 |
| **206** | `nr="206" mi="1" ci="0" mb="0" cb="0"` | **UNCOVERED** — covered-instruction count `ci` is 0 |

**Line 197 is uncovered.** It is the non-`orchestrator` subagent-type `return $false` branch of
`Test-PreparationModeDelegation`.

**Line 206 is uncovered.** It is the all-conjuncts-hold `return $true` of the same function.

Both were covered at the fixed comparison anchor `1e991b86d78e4f979922b79268f19ca0e5ab19e3` through
merge-base line 213 inside `Test-ImplementationDelegation`. This branch removed that call site.

## Companion per-file figures observed in the same report, for context

| File | Covered | Missed | Total | Line coverage |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 132 | 18 | 150 | 88.00 percent |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 130 | 2 | 132 | 98.48 percent |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 135 | 27 | 162 | 83.33 percent |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 130 | 2 | 132 | 98.48 percent |

Output Summary: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` baseline is 135
covered, **27 missed**, 162 total, **83.33 percent** line coverage. Both **line 197** and **line
206** are recorded UNCOVERED, each backed by a `ci="0"` coverage attribute read from the report.
EXIT_CODE 0.
