# QA Gate — File-Size Limit — [P8-T11]

Timestamp: 2026-08-23T04-16

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T11]

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
| `tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1` | **319** | 500 | 181 | yes |

**All six counts are at or under 500.** **PASS.**

## Trajectory across the change, and why the sequencing mattered

The two extraction modules entered this item at 497 and 498 lines, measured at [P0-T11], leaving 3
and 2 lines of headroom against the hard limit in `.claude/rules/general-code-change.md`. An in-place
guard was arithmetically impossible in either: the guard, its mandatory decision-logic comment, and
the docstring amendment together exceed the available lines.

That is why the plan sequenced module creation and the relocation-out **before** the guard, and why
no task in either phase left any file above the limit at its own completion:

| Stage | Python extraction module | PowerShell extraction module |
| --- | --- | --- |
| baseline ([P0-T11]) | 497 | 498 |
| after relocation-out ([P2-T3] / [P3-T2]) | 455 | 449 |
| after the guard ([P2-T4] / [P3-T3]) | **475** | **472** |

Both modules ended the change with **more** headroom than they started with — 25 and 28 lines against
3 and 2 — so the change left the file-size position better than it found it rather than merely
staying legal.

The two new leaf modules are the reason. Each is well clear of the limit at 144 and 187 lines, and
each is a genuine cohesive unit rather than an overflow bucket: both hold only context-free token-shape
predicates, and both import nothing from the blast-radius library, which is what lets the extraction
module import them without a cycle.

## The one file with the least headroom

`tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1` grew from 227 lines at
baseline to 319 after [P5-T9] added the two retrospective-cleaning cases. It retains 181 lines of
headroom, so its own acceptance condition at [P5-T9] — at or under 500 — holds with room to spare.

## Output Summary

All six files are at or under the 500-line limit. The two extraction modules finished at 475 and 472
lines with 25 and 28 lines of headroom, having entered the change at 497 and 498 with 3 and 2, so the
relocation improved the file-size position in both runtimes rather than merely preserving it.
