# Remediation file-size ledger (issue #672, feature-review cycle 1)

This ledger deliberately carries no timestamp element in its filename, because more than one task appends a
block to it. Each block is `Timestamp:`-bearing.

The cap is 500 lines per file, from `.claude/rules/general-code-change.md`. The measured quantity is the
**physical** line count, because the cap is a cap on file length. The non-blank count is recorded beside it for
continuity with the `[P0-T3]` baseline ledger, which established that the plan's stated measurement command,
`Get-Content | Measure-Object -Line`, returns the non-blank count rather than the physical count.

---

## Phase 1 block — the three edited test files (batch R-A)

Timestamp: 2026-09-17T13-56

Task: `[P1-T8]`

Command:
`$lines = @(Get-Content -LiteralPath '<file>'); $lines.Count; $lines | Measure-Object -Line | Select-Object -ExpandProperty Lines`

EXIT_CODE: 0

| file | physical lines | non-blank lines | baseline physical | delta | headroom to 500 | at or under cap |
| --- | --- | --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | **499** | 419 | 454 | +45 | 1 | **yes** |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | **446** | 398 | 445 | +1 | 54 | **yes** |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | **454** | 404 | 453 | +1 | 46 | **yes** |

Three integers recorded. Every one is at or under the 500-line cap.

### Overage encountered and resolved, recorded rather than hidden

The TargetResolution suite measured **504** physical lines on the first pass of `[P1-T7]`, which is 4 lines
over the cap. The plan's halt protocol names "a delivered file measured over the 500-line cap" as a halt
condition, and `[P1-T8]` forbids resolving an overage by trimming an assertion.

The overage was resolved without trimming anything, by applying two directions `[P1-T7]` already states:

1. Two mocks in the new case `allows a repo-relative citation placed in the item worktree` had been written as
   three-line blocks; they were rewritten in the **single-line `Mock -CommandName ... -MockWith { ... }`
   form** that `[P1-T7]` mandates for precisely this budget reason. Reclaimed 4 lines.
2. The explanatory comment `[P1-T3]` added was condensed from three lines to two. Reclaimed 1 line.

No assertion, mock behaviour, payload, or `It` name was changed by either step, and the post-reclaim re-run
reproduced the same 28 / 24 / 4 counts and the same four failing identifiers with the same four messages, so
the reclaim is demonstrably behaviour-neutral. No halt was required.

### Budget reconciliation

`[P1-T7]` allotted 46 lines to be shared by `[P1-T2]`, `[P1-T3]`, and `[P1-T7]` on the TargetResolution suite.
The delivered growth is **45** lines — 454 to 499 — so the phase finished one line inside its allotment.

The header-comment correction consumed none of that allotment, as the plan states: three lines were replaced
by three lines.

The two sibling suites each gained exactly one line, being the single `Mock` statement `[P1-T4]` and `[P1-T5]`
add inside an existing Describe-level `BeforeAll`. That matches the plan's prediction of a one-line gain each
and corroborates the corrected header comment's claim that both siblings sit within sixty lines of the cap:
the measured headroom is 54 and 46.

### Note for the next task that appends here

The TargetResolution suite now has **1 line of headroom**. No task in Phase 2, 3, or 4 of this plan edits that
file, so the headroom is not consumed further by this remediation. A future change to that suite will need to
either reclaim lines or split the file.
