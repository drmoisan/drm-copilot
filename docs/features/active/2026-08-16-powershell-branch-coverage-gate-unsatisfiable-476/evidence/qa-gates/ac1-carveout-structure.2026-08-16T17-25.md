# AC1 — Carve-Out Present and Structurally Parallel (Issue #476)

Timestamp: 2026-08-16T17-25

Command: read of `.claude/rules/powershell.md` (Testing Standards, line 64) side-by-side with `.claude/rules/shell.md:68-70`

EXIT_CODE: 0

## Precedent Text (`.claude/rules/shell.md:68-70`, unchanged)

```text
- kcov reports **line coverage only**. The uniform line-coverage threshold (>= 85% per
  `.claude/rules/quality-tiers.md`) applies. Branch coverage is not measurable by kcov for
  bash; there is no bash branch-coverage gate.
```

## Amended Carve-Out (`.claude/rules/powershell.md:64`)

```text
- Pester reports **command (instruction) coverage and line coverage only**. The uniform line-coverage threshold (>= 85% per `.claude/rules/quality-tiers.md`) applies. Branch coverage is not measurable by Pester for PowerShell; there is no PowerShell branch-coverage gate. This removes an unevaluable threshold, not a measurement obligation: PowerShell production files remain in the coverage denominator per the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`, and command coverage is reported for information only, with no threshold attached.
```

## Four-Part Structural Mapping

| Part | Required content | Precedent sentence (bash) | Amended sentence (PowerShell) | Verdict |
| --- | --- | --- | --- | --- |
| 1 | Name the tool and state the metrics it actually measures | "kcov reports **line coverage only**." | "Pester reports **command (instruction) coverage and line coverage only**." | PASS — names Pester; states command (instruction) coverage and line coverage as the measured metrics |
| 2 | Preserve the uniform line threshold with the `quality-tiers.md` cross-reference | "The uniform line-coverage threshold (>= 85% per `.claude/rules/quality-tiers.md`) applies." | "The uniform line-coverage threshold (>= 85% per `.claude/rules/quality-tiers.md`) applies." | PASS — identical wording and identical cross-reference; the `>= 85%` figure is stated explicitly |
| 3 | State the incapability as a fact about the tool | "Branch coverage is not measurable by kcov for bash" | "Branch coverage is not measurable by Pester for PowerShell" | PASS — attributes the limitation to the tool, not to a policy preference |
| 4 | Disclaim the gate's existence, not merely its threshold | "there is no bash branch-coverage gate." | "there is no PowerShell branch-coverage gate." | PASS — disclaims the gate itself |

The four parts appear in the same order as the precedent, in a single bullet occupying the same structural position (the coverage bullet list of the language's testing/coverage section).

## Additional Sentence Beyond the Precedent (required by AC3, not by AC1)

"This removes an unevaluable threshold, not a measurement obligation: PowerShell production files remain in the coverage denominator per the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`, and command coverage is reported for information only, with no threshold attached."

This sentence is an addition to the precedent's shape, required by AC3 (explicit threshold-versus-measurement distinction) and consistent with AC13 (command coverage described, never gated). It does not displace or reorder any of the four required parts.

## Adjacent Bullets Preserved

- Line 63 (unchanged): "- Line coverage must remain >= 85% across all tiers (T1–T4) per `.claude/rules/quality-tiers.md`."
- Line 65 (unchanged): "- Coverage regression on changed lines is a blocking finding."

Both appear as unmodified context lines in `git diff -U1 -- .claude/rules/powershell.md`; the diff contains exactly one removed line and one added line.

Output Summary: PASS. All four structural parts of the bash precedent are present, in order, in the amended `.claude/rules/powershell.md` carve-out, with Pester substituted for kcov and PowerShell for bash. The line-coverage bullet and the changed-lines no-regression bullet are byte-unchanged.
