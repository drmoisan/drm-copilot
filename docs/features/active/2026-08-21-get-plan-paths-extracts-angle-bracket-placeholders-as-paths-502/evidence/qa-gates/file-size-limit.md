# QA Gate — File-Size Limit — [P8-T11]

Timestamp: 2026-08-23T05-32

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T11]
Run: revision-6 re-run. Two of the six files grew on this run, which is why the gate had to be
re-measured rather than carried forward.

Command: `wc -l` over each of the six files named by [P8-T11].

EXIT_CODE: 0

## Measured line counts

| File | Lines | Limit | Headroom | At or under |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_token_shapes.py` | **144** | 500 | 356 | yes |
| `scripts/dev_tools/_blast_radius_extraction.py` | **475** | 500 | 25 | yes |
| `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | **187** | 500 | 313 | yes |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | **472** | 500 | 28 | yes |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` | **197** | 500 | 303 | yes |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1` | **419** | 500 | 81 | yes |

**All six counts are at or under 500.** **PASS.**

## What changed on this run

Only the last row moved among the six, and one file outside the six also grew:

| File | Previous run | This run | Cause |
| --- | --- | --- | --- |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1` | 319 | **419** | [P5-T3] PowerShell test |
| `tests/scripts/dev_tools/test_blast_radius_normalization.py` (not in the six) | 287 | 365 | [P5-T3] Python test |

The PowerShell normalization test file is the one to watch: it entered this item at 227 lines, grew to
319 at [P5-T9], and stands at **419** after [P5-T3]. It retains **81** lines of headroom, so [P5-T9]'s
own at-or-under-500 condition and this gate both hold, but the margin is now the smallest of the six
and a future addition to that file should check the count before writing rather than after.

The Python counterpart at 365 lines is not among the six this task enumerates, but it is recorded here
because it grew for the same reason and because the 500-line limit applies to it identically. It has
135 lines of headroom.

## Trajectory across the change, and why the sequencing mattered

The two extraction modules entered this item at 497 and 498 lines, measured at [P0-T11], leaving 3 and
2 lines of headroom against the hard limit in `.claude/rules/general-code-change.md`. An in-place guard
was arithmetically impossible in either: the guard, its mandatory decision-logic comment, and the
docstring amendment together exceed the available lines.

That is why the plan sequenced module creation and the relocation-out **before** the guard, and why no
task in either phase left any file above the limit at its own completion:

| Stage | Python extraction module | PowerShell extraction module |
| --- | --- | --- |
| baseline ([P0-T11]) | 497 | 498 |
| after relocation-out ([P2-T3] / [P3-T2]) | 455 | 449 |
| after the guard ([P2-T4] / [P3-T3]) | **475** | **472** |

Both modules ended the change with **more** headroom than they started with — 25 and 28 lines against
3 and 2 — so the change left the file-size position better than it found it rather than merely staying
legal. Neither was touched by [P5-T3], so both counts are unchanged from the previous run.

The two new leaf modules are the reason. Each is well clear of the limit at 144 and 187 lines, and each
is a genuine cohesive unit rather than an overflow bucket: both hold only context-free token-shape
predicates, and both import nothing from the blast-radius library, which is what lets the extraction
module import them without a cycle.

## Output Summary

All six files are at or under the 500-line limit. The two extraction modules stand at 475 and 472 lines
with 25 and 28 lines of headroom, having entered the change at 497 and 498 with 3 and 2. The PowerShell
normalization test file grew to 419 lines on this run from [P5-T3]'s addition and retains 81 lines of
headroom, the narrowest margin of the six.
