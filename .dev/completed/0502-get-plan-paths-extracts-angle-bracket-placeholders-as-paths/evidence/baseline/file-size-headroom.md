# Baseline — File-Size Headroom — [P0-T11]

Timestamp: 2026-08-23T00-54

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T11]
State captured: PRE-CHANGE baseline

Command: `wc -l` over each of the seven files named by [P0-T11].

EXIT_CODE: 0

## Measured line counts

| File | Lines | Headroom to the 500-line limit |
| --- | --- | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | **497** | 3 |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | **498** | 2 |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1` | 460 | 40 |
| `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` | 156 | 344 |
| `tests/scripts/dev_tools/test_blast_radius_normalization.py` | 207 | 293 |
| `tests/scripts/dev_tools/test_blast_radius_validation.py` | 270 | 230 |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1` | 227 | 273 |

The two extraction modules measure 497 and 498 lines respectively, matching the plan's
design-constraint statement exactly.

## Why this measurement is load-bearing

The hard limit in `.claude/rules/general-code-change.md` is 500 lines for any production, test, or
reusable script file. With 3 and 2 lines of headroom, an in-place guard in either extraction module
is arithmetically impossible: the guard, its mandatory decision-logic comment, and the docstring
amendment together exceed the available lines in both files.

This is what makes the new leaf module per runtime mandatory rather than stylistic, and it is why
Phases 2 and 3 sequence module creation and the relocation-out *before* the guard is added. No task
in either phase may leave any file above 500 lines at its own completion:

- [P2-T3] relocates content out of the Python module, whose acceptance requires the resulting count
  to be strictly less than 497. Only then does [P2-T4] add the guard.
- [P3-T2] relocates content out of the PowerShell module, whose acceptance requires strictly less
  than 498. Only then does [P3-T3] add the guard.

The two test files with the least headroom, `BlastRadiusExtraction.Path.Tests.ps1` at 460 and
`BlastRadiusNormalization.Tests.ps1` at 227, are recorded because [P5-T9] adds to the latter and
its acceptance carries an explicit at-or-under-500 condition.

## Output Summary

Seven files measured. The two extraction modules are at 497 and 498 lines, leaving 3 and 2 lines of
headroom against the 500-line limit, which confirms the plan's premise that the guard cannot be
added in place. The five test files carry between 40 and 344 lines of headroom.
