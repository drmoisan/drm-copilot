# Coverage-Denominator Re-Partition Record — Cycle 2026-08-26T02-36

Timestamp: 2026-08-26T04-08

> Filename-stamp substitution note: the filename carries the fixed cycle stamp `2026-08-26T02-36`
> required by the plan, whose acceptance conditions assert exact filenames. The `Timestamp:` field
> records the actual execution stamp, `2026-08-26T04-08`. Same convention as Phases 0 through 3.

Command: `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path'`

EXIT_CODE: 0

## Output Summary

Phase 1 of this cycle split four pure helper functions out of
`scripts/dev-tools/Invoke-ReleaseVerification.ps1` into the new sibling
`scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`, and Phase 1 registered the new file in the
`CodeCoverage.Path` allow-list. Measured lines therefore moved from one file into a second file, and
the repository-wide denominator changed. This record states the before and after figures explicitly
so that no reader mistakes the re-partitioning for a coverage regression.

### Pre-split figures — historical values, quoted only

Quoted as historical values from `evidence/qa-gates/verification-module-coverage.2026-08-26T01-13.md`
for `scripts/dev-tools/Invoke-ReleaseVerification.ps1`:

| Metric | Pre-split value |
|---|---|
| Total measured lines | **92** |
| Covered lines | **83** |
| Missed lines | **9** |
| Line coverage | 90.22 percent |

That artifact also records the pre-split uncovered line numbers as 57, 58, 74, 75, 92, 485, 496, 497,
and 498 — the three wrapper-seam bodies plus the dot-source-guarded entry-point block.

These values are reproduced here **as historical record only**. They are never used as the
right-hand side of an acceptance condition.

### Post-split figures

Measured by the direct self-hosted PoshQC invocation named in `Command:` above, parsed from
`artifacts/pester/powershell-coverage.xml` by keying on the enclosing `package` element and then
selecting the `sourcefile` by name within it.

| File | Covered | Missed | Measured |
|---|---|---|---|
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | 56 | 9 | **65** |
| `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` | 29 | **0** | **29** |

Post-split line coverage is 86.1538 percent and 100 percent respectively; both are at or above the
uniform 85.0 percent floor.

### The arithmetic, and why the two sides differ

| Quantity | Value |
|---|---|
| Post-split measured, `Invoke-ReleaseVerification.ps1` | 65 |
| Post-split measured, `Invoke-ReleaseVerificationHelpers.ps1` | 29 |
| **Sum of the two post-split measured counts** | **94** |
| Pre-split measured count, single file | **92** |
| Difference | **+2** |

The sum of the two post-split measured counts, 94, is **not** equal to the pre-split measured count
of 92, and it is not expected to be. Three effects account for the difference, and none of them is a
coverage regression:

1. **The split itself is measure-preserving only for relocated bodies.** The four relocated functions
   carried their measured lines with them. Relocation alone moves lines between the two columns and
   does not change the sum.

2. **Phase 1 added a dot-source statement to the retained file.** `scripts/dev-tools/Invoke-ReleaseVerification.ps1`
   gained a `Join-Path`-based dot-source of the new sibling immediately after its `param()` block, so
   the retained file has at least one measured line that did not exist before the split. That line is
   covered.

3. **Phases 2 and 3 added measured lines to the retained file after the split.** Phase 2 replaced one
   shared interval/attempt pair with six per-check budget parameters and forwarded each pair to its
   own check; Phase 3 introduced the `RUN_INCOMPLETE` token and its return path. Both phases added
   executable statements to `scripts/dev-tools/Invoke-ReleaseVerification.ps1`, all of which are
   covered.

Because effects 2 and 3 add lines that never existed pre-split, the pre-split total of 92 is simply
not the same population as the post-split total of 94. Subtracting one from the other measures
nothing about test quality.

The **missed**-line count is the quantity that carries meaning across the boundary, and it is
unchanged at exactly 9 for `scripts/dev-tools/Invoke-ReleaseVerification.ps1` and exactly 0 for
`scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`. The nine misses are the same three
wrapper-seam bodies and the same entry-point block as before, at their new line numbers 69, 70, 86,
87, 104, 403, 418, 419, and 420. The set is enumerated and classified in
`evidence/qa-gates/uncovered-line-classification.2026-08-26T02-36.md`.

### Repository-wide denominator

Post-split repository-wide line coverage is 6794 covered of 7073 measured, 96.0554 percent, which is
at or above the 85.0 percent floor. The repository-wide denominator grew when the new file was
registered in `CodeCoverage.Path`; the new file contributes 29 measured lines with 0 missed, so its
registration cannot lower the repository-wide figure.

### Explicit statement required by the plan

**No acceptance condition in this cycle compared a post-split figure against a pre-split figure.**
Every coverage acceptance condition executed in this cycle compared against an absolute constant: the
uniform 85.0 percent line-coverage floor from `.claude/rules/quality-tiers.md`, a missed-line count of
exactly 0 for `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`, and an out-of-region
uncovered-line count of exactly 0 for `scripts/dev-tools/Invoke-ReleaseVerification.ps1`. The
pre-split values 92, 83, 9, and 90.22 percent appear in this cycle's artifacts as historical record
only, never as the right-hand side of a comparison.
