# Coverage Delta and Threshold Verification — Issue #516

Timestamp: 2026-08-24T17-31

Command: comparison of the P0-T5 baseline artifact `../baseline/poshqc-test-coverage.2026-08-24T09-52.md` against the P6-T3 post-change artifact `final-poshqc-test-coverage.2026-08-24T17-31.md`, both derived from the JaCoCo report `artifacts/pester/powershell-coverage.koverage.xml`. Changed-line attribution derived from `git diff -U0 -- <hook>`.

EXIT_CODE: 0

Output Summary:

## Overall repository line coverage

| Measure | Baseline (P0-T5) | Post-change (P6-T3) | Delta |
| --- | --- | --- | --- |
| LINE missed | 255 | 259 | +4 |
| LINE covered | 6407 | 6446 | +39 |
| LINE total | 6662 | 6705 | +43 |
| **Line coverage** | **96.17%** | **96.14%** | **-0.03 pp** |

The overall figure is above the uniform 85% threshold in `.claude/rules/quality-tiers.md` both before
and after. The -0.03 pp movement is a denominator effect from 43 added executable lines, not a loss
of coverage on any previously covered line — see the per-line attribution below.

## Per-file line coverage, changed hook copies

| File | Baseline | Post-change | Delta |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 90.00% (11 missed / 99 covered) | **90.84%** (12 missed / 119 covered) | **+0.84 pp** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 99.18% (1 missed / 121 covered) | **97.22%** (4 missed / 140 covered) | **-1.96 pp** |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/...ps1` | not itemized | not itemized | n/a |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/...ps1` | not itemized | not itemized | n/a |

Both measured copies are above the 85% threshold. The two bundled mirror copies are outside the
PoshQC coverage scan set (`config/poshqc-scan.json` scans `scripts`, `tests/powershell`,
`tests/scripts`); their content is byte-identical to the measured copies, proven in
`pushdown-pair-hashes.2026-08-24T17-31.md`.

## Changed-lines statement

Added executable-line ranges, from `git diff -U0`:

- Claude hook: `+57,74` (the `ConvertTo-WorkspaceRelativePath` helper), `+317,8` (the `$WorkspaceRoot` parameter on the decision function), `+340` (the helper call site).
- Codex hook: `+60,74` (helper), `+159,8` (the `$WorkspaceRoot` parameter on `Test-ImplementationCommand`), `+174` and `+180` (the two hunk-path call sites), `+338,9` (the decision-function parameter), `+361` and `+366` (the decision-function call site and the `-WorkspaceRoot` pass-through).

Uncovered line numbers in the post-change report, attributed against those ranges:

| Hook | Uncovered lines | Inside an added range? | Attribution |
| --- | --- | --- | --- |
| Claude | 105 | yes (57-130) | new — helper trailing `/.` removal body |
| Claude | 160, 197, 231, 273, 274, 276, 356, 416, 417, 418, 421 | no | pre-existing — 11 lines, exactly the baseline's 11 missed |
| Codex | 102, 105, 108 | yes (60-133) | new — helper leading `./`, interior `/./`, and trailing `/.` removal bodies |
| Codex | 255 | no | pre-existing — 1 line, exactly the baseline's 1 missed |

**No coverage regression on changed lines.** The count of uncovered pre-existing lines is identical
to the baseline count in both files (Claude 11 → 11; Codex 1 → 1), and every pre-existing uncovered
line falls outside every added range. No line that was covered at baseline is uncovered after the
change. The entire increase in missed lines (Claude +1, Codex +3) is attributable to newly added
lines inside the helper.

**New-code line coverage** (added executable lines only):

| Hook | New executable lines | Covered | Uncovered | New-code coverage |
| --- | --- | --- | --- | --- |
| Claude | 21 (110 → 131) | 20 | 1 | **95.24%** |
| Codex | 22 (122 → 144) | 19 | 3 | **86.36%** |

Both new-code figures are above the uniform 85% threshold.

The uncovered new lines are the identity-dot-segment removal bodies of the helper. In the Claude
hook the leading-`./` and interior-`/./` branches are exercised by the named facet tests
`removes identity dot segments before stripping`, `collapses duplicated separators before stripping`,
`allows a leading dot-slash checkpoint path`, `allows an identity dot segment in the checkpoint path`,
and `allows duplicated separators in the checkpoint path`; only the trailing-`/.` body is unexercised.
The Codex facet file, whose 12 named `It` blocks are fixed by the approved plan (P3-T2) and carry no
dot-segment case, leaves all three bodies unexercised in that copy. The Codex helper is byte-identical
to the Claude helper, so the algorithm those lines implement is covered by the Claude facet tests;
extending the Codex facet file beyond its 12 planned blocks was not authorized by the plan and was
not done.

Per `.claude/rules/quality-tiers.md`, Pester does not measure branch coverage, so no branch-coverage
condition applies to PowerShell.
