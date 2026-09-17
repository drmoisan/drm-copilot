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

---

## Phase 2 block — the two repository production files (batch R-B)

Timestamp: 2026-09-17T13-56

Task: `[P2-T7]`

Command:
`$lines = @(Get-Content -LiteralPath '<file>'); $lines.Count; $lines | Measure-Object -Line | Select-Object -ExpandProperty Lines`

EXIT_CODE: 0

| file | physical lines | non-blank lines | pre-remediation physical | delta | headroom to 500 | at or under cap |
| --- | --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | **456** | 403 | 431 | +25 | 44 | **yes** |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | **320** | 284 | 314 | +6 | 180 | **yes** |

Both integers recorded. Both are at or under the 500-line cap. No overage arose, so the halt branch in
`[P2-T7]` was not taken and no rationale comment was shortened to absorb one.

### Reconciliation against the plan's stated headroom

`[P2-T7]` states pre-remediation values of 431 and 314, carrying 69 and 186 lines of headroom. Both were
confirmed by `[P0-T3]` against the current tree. The delivered change consumes 25 of the parent hook's 69
lines and 6 of the helpers sibling's 186.

### Attribution of the delta, per task

**Parent hook, +25 lines:**

- `[P2-T2]`, net **0**. The `.DESCRIPTION` paragraph replacement grew from 5 lines to 10, and the pre-filter
  deletion removed 5 lines: the four-line `if ($text -notmatch ...)` block and its trailing blank separator.
- `[P2-T3]`, net **+25**. The resolution-order block grew from 21 lines to 46, because the delivered branch
  order has seven steps where the stale block documented four, and four of those steps describe behaviour the
  stale block did not mention at all: the derivation's own ambiguity deny, the derived-target disambiguator,
  the unresolved-tie deny, and the folder-absent-under-the-target-root deny.

**Helpers sibling, +6 lines:**

- `[P2-T5]`, net **+6**. The file-level `.DESCRIPTION` sentence `It is loaded for its declarations only.` was
  replaced by a paragraph naming the one file-scope statement and stating why its import is unguarded.

No executable line was added to either file by Phase 2. The parent hook's only executable change is a
deletion.
