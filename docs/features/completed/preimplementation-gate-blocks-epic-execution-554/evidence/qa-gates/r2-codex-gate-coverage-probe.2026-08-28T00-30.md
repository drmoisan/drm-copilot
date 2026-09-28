# Remediation Cycle 2 — Codex Gate Hook Per-Line Coverage Probe (B5 closure proof)

Timestamp: 2026-08-28T02-06
Task: [P3-T6]
Command: `python -c "<ElementTree read of artifacts/pester/powershell-coverage.xml, selecting the .codex/hooks package and the enforce-orchestration-preimplementation-gate.ps1 sourcefile, emitting its LINE counter, every line element whose ci attribute is 0, and an explicit probe of the line elements numbered 197 and 206>"`
EXIT_CODE: 0

Source report: `artifacts/pester/powershell-coverage.xml`, produced by the [P3-T4] run.
File probed: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`

## Explicit per-line probe of the two B5 lines

| Line | `line` element attributes read from the report | Covered count `ci` | Verdict |
| --- | --- | --- | --- |
| **197** | `nr="197" mi="0" ci="1" mb="0" cb="0"` | **1** | **COVERED** |
| **206** | `nr="206" mi="0" ci="1" mb="0" cb="0"` | **1** | **COVERED** |

Both rows show a **covered count greater than zero**. At the [P0-T7] baseline both carried
`mi="1" ci="0"` and were UNCOVERED. **Component 1 of finding B5 is closed.**

- Line 197 is the non-`orchestrator` subagent-type `return $false` of
  `Test-PreparationModeDelegation`, driven by the [P1-T2] case
  `returns false for a non-orchestrator subagent type carrying both preparation markers on the Codex surface`.
- Line 206 is the all-conjuncts-hold `return $true` of the same function, driven by the [P1-T3] case
  `returns true for an orchestrator carrying both preparation markers on the Codex surface`.

## File LINE counter

| Metric | [P0-T7] baseline | This run |
| --- | --- | --- |
| Covered | 135 | **137** |
| Missed | 27 | **25** |
| Total | 162 | **162** |
| Line coverage | 83.33 percent | **84.57 percent** |

The recorded covered count is the integer **137**, the missed count the integer **25**, and the total
the integer **162**. The file line-coverage figure is numerically **84.57**, rounded to two decimal
places from 84.5679 percent. Movement from the [P0-T7] baseline of **83.33** is **+1.24 percentage
points**, exactly the two lines B5 closed.

## Full missed-line set

```
292, 293, 294, 296, 304, 305, 306, 308, 421, 422, 426, 427, 428, 429, 430,
432, 433, 434, 435, 436, 437, 439, 441, 442, 443
```

Twenty-five members. This is **exactly** the set the plan's acceptance condition names, member for
member and in the same order. Lines 197 and 206 are absent from it.

## Attribution — no line of the residual is unattributed

| Members | Count | Named exception | Reason |
| --- | --- | --- | --- |
| `292, 293, 294, 296` | 4 | **Group 1**, injected read seams | `Get-EpicCheckpointContent` body — real filesystem I/O; the injection seam exists so the decision logic is testable without touching the filesystem, and covering it would make several allow assertions pass vacuously against the live checkpoint |
| `304, 305, 306, 308` | 4 | **Group 1**, injected read seams | `Get-ParallelCheckpointContent` body — same reason |
| `421, 422` | 2 | **Group 2** | the `declared-checkpoint-path` deny return, uncovered for the decision-D5 transport reason |
| `426, 427, 428, 429, 430, 432, 433, 434, 435, 436, 437, 439, 441, 442, 443` | 15 | **Issue #555 shipping exception**, lines 426-443 | driving the epic/parallel decision branch requires constructing a delegation payload for the Codex decision function, which decision D5 prohibits because `.codex/config.toml` registers no `PreToolUse` matcher admitting an `Agent` or `Task` tool name |

4 + 4 + 2 + 15 = **25**. **The residual is wholly the accepted issue #555 exception at lines 426-443
plus the group-1 and group-2 residuals, and no line of it is unattributed.**

## Companion per-file figures from the same report

| File | Covered | Missed | Total | Line coverage |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 132 | 18 | 150 | 88.00 percent |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 130 | 2 | 132 | 98.48 percent |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 137 | 25 | 162 | **84.57 percent** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 130 | 2 | 132 | 98.48 percent |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 112 | 6 | 118 | 94.92 percent (byte-untouched) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 112 | 6 | 118 | 94.92 percent (byte-untouched) |

Output Summary: **Lines 197 and 206 are both COVERED**, each proved by an explicit per-line probe
showing `ci="1"`. The Codex gate hook stands at **137 covered / 25 missed / 162 total = 84.57
percent**, up from 83.33 percent. The missed set is exactly the 25 named members and every one of
them is attributed to a named exception. EXIT_CODE 0.
