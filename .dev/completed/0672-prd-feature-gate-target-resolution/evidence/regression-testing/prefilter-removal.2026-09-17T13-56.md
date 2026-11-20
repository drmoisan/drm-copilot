# R1 Option A — removal of the absolutely-placed-token pre-filter

Timestamp: 2026-09-17T13-56

Task: `[P2-T2]` of `remediation-plan.2026-09-17T12-29.md`
Batch: R-B (2 production files, 0 test files)

Command, each run as `Select-String -SimpleMatch -Pattern '<token>' -Path '<path>'` with the pattern in single
quotes. `-SimpleMatch` is mandatory: without it `$`, `(`, and `[` carry regular-expression meaning and the
token `[A-Za-z]:[\\/]` matches nothing whatever the file contains.

EXIT_CODE: 0 for every invocation.

Output Summary:

## The four required counts

| # | asserted token | path | pre-change count | post-change count | required | verdict |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `[A-Za-z]:[\\/]` | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 1, at line 243 | **0** | 0 | **OK** |
| 2 | `[A-Za-z]:[\\/]` | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | 1, at line 57 | **1**, at line 57 | the `[P0-T4]` control count of 1 | **OK** |
| 3 | `absolutely-placed` | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 2, at lines 219 and 242 | **0** | 0 against a recorded pre-change count of 2 | **OK** |
| 4 | `a call that places in no worktree, or in several, denies before any probe` | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 0 | **1**, at line 226 | exactly 1 | **OK** |

All pre-change counts are the values `[P0-T4]` measured before any file was edited, and all carried a
`MATCHES` verdict against the plan's preamble control table.

Row 2 is the control that makes row 1 a real assertion rather than a token that never existed: the same
pattern still occurs exactly once, at the same line 57, in F1's resolution module. A post-edit control count
other than 1 would mean this edit reached the resolution module, which it must not.

Row 4 asserts the mandated sentence is present on a single line of its own. It is, at line 226.

## What was deleted

The four-line pre-filter formerly at lines 242-245, together with its trailing blank separator:

- the comment `# An absolutely-placed token is the only citation that identifies one worktree.`
- the `if ($text -notmatch '(?<![^\s"''`(])(?:[A-Za-z]:[\\/]|/)') {` test
- its `return $null`
- its closing brace

`-notmatch` now occurs **0** times in the file. Line 243 was the only `-notmatch` in it, so the count moving
from 1 to 0 is a second independent confirmation that the test itself is gone rather than merely reworded.

The assembled text now passes to `Resolve-WorktreeCallTarget` unconditionally.

## What survived byte-unmodified

Each verified present exactly once, and the region inspected with `cat -A` to confirm the line structure and
the blank separator:

| structure | plan's cited lines | occurrence count | status |
| --- | --- | --- | --- |
| the empty-text guard `if (-not $text) {` with its `return $null` and brace | 238-240 | 1 | unmodified |
| the session-root read, `Test-ClaudeHookEnvelopeHasKey -Envelope $Envelope -Name 'cwd'` | 247-250 | 1 | unmodified |
| `return (Resolve-WorktreeCallTarget -Text $text -SessionRoot $sessionRoot)` | 252-255 | 1 | unmodified |
| `return (Resolve-WorktreeCallTarget -Text $text)` | 252-255 | 1 | unmodified |

The blank line that separated the empty-text guard from the following statement is preserved: after the
deletion the guard's closing brace is followed by one blank line and then `$sessionRoot = ''`. The blank line
removed was the pre-filter's own trailing separator, not the guard's.

The empty-text guard surviving is what keeps the delivered case `derives nothing from a call whose text is
empty` passing with its zero-invocation assertion; the plan states that case is not amended, and `[P2-T8]`
confirms it still passes.

## The `.DESCRIPTION` paragraph replacement

The paragraph formerly at lines 219-223 claimed that "A call whose text carries no absolutely-placed token is
NOT handed to the derivation" and that such a call "is resolved against the session root exactly as before".
Both clauses describe the behaviour this task removes, so the paragraph was replaced with one stating that the
assembled text is handed to the derivation unconditionally, that the derivation answers `NoTarget` for a call
it cannot place and `Ambiguous` for a signal that places in no worktree or in several, and that the outcome is
fail-closed.

The replacement is 10 lines against the original 5. Combined with the 5 lines the pre-filter deletion removed,
the file's physical line count is unchanged at **431**, which is 69 lines inside the 500-line cap.
`[P2-T7]` records the measurement formally.

## Resolution of R3 by the same edit

The pre-filter was the hook's own local decision about which calls are eligible for derivation, which is the
finding R3 names. With it deleted, `Resolve-WorktreeCallTarget` is the single owner of what counts as a
placeable signal, and the hook holds no such decision. `[P2-T4]` verifies that property by measurement.

Acceptance: the `[A-Za-z]:[\\/]` search against the hook returns 0 matches while the same search against the
resolution module returns the `[P0-T4]` control count of 1; the `absolutely-placed` search returns 0 against a
recorded pre-change count of 2; and the mandated sentence search returns exactly 1. All four counts recorded
above. Satisfied.
