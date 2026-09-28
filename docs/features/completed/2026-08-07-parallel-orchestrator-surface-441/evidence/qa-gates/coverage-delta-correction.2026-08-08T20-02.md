# Verification of the Coverage-Delta Correction (CR-05)

Timestamp: 2026-08-08T20-02

Corrected artifact:
`docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/qa-gates/coverage-delta.2026-08-08T17-58.md`

Numeric source (sole):
`docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/remediation-baseline/branch-coverage-remeasure.2026-08-08T19-18.md`,
measured at HEAD `41633ad5e867070853e3e4501c3457b6641d1efc`.

Commands used to verify the amended artifact:

1. `grep -n -e "83.82" -e "4191" -e "809" -e "555" -e "89.66503047629323" -e "most likely mechanism" docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/qa-gates/coverage-delta.2026-08-08T17-58.md`
2. `grep -n -A2 "^## Verdict" docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/qa-gates/coverage-delta.2026-08-08T17-58.md`
3. `grep -n "91.82362065145136\|12432\|13539" docs/features/active/2026-08-07-parallel-orchestrator-surface-441/evidence/qa-gates/coverage-delta.2026-08-08T17-58.md`

EXIT_CODE: 0 (all three)

## Output Summary — Corrected Fields, Before and After

| Field | Before (unreproduced) | After (re-measured) |
| --- | --- | --- |
| Comparison table, post-change branch coverage | 83.82% (4191 / 5000) | 83.80% (4190 / 5000) |
| Comparison table, branch-coverage delta | +0.02 pp | 0.00 pp |
| Comparison table, post-change combined headline | 89.67% (89.66503047629323) | 89.66% (89.65963644209505) |
| Comparison table, combined-headline delta | +0.0054 pp | 0.0000 pp |
| Comparison table, post-change branch destinations missing | 809 (delta -1, "improvement") | 810 (delta 0, "no regression") |
| Comparison table, post-change partial branches | 555 (delta -1, "improvement") | 556 (delta 0, "no regression") |
| Precise values, post-change `covered_branches` | 4191 | 4190 |
| Precise values, post-change `missing_branches` | 809 | 810 |
| Precise values, post-change `num_partial_branches` | 555 | 556 |
| Precise values, post-change `percent_branches_covered` | 83.82 | 83.8 |
| Precise values, post-change `percent_covered` | 89.66503047629323 | 89.65963644209505 |
| Threshold item 2 | "83.82% >= 75% required, margin +8.82 pp" | "83.80% >= 75% required, margin +8.80 pp" |
| Threshold item 3 | "branch coverage increased by 0.02 pp" | "branch coverage is exactly equal (83.8% both sides)" |
| Attribution sentence | "The most likely mechanism is that the newly added `.claude` runtime files and the three new `pack-manifests/core.json` entries changed the inputs traversed by existing production helpers..." | "A single-destination difference between runs at the same HEAD is environment-dependent and is not a reproducible property of the branch content; no causal attribution to the branch's `.claude` files or `core.json` entries is supported by the evidence, and none is asserted." |

## Residual Occurrences of the Superseded Figures

Command 1 returned three hits for the superseded values, at lines 11-12 and line 100. Both locations
are the dated correction note and the historical-record paragraph, which state explicitly that those
values were recorded by an earlier revision and did not reproduce. **No unreproduced branch-coverage
figure remains anywhere in the artifact as an asserted measurement**, and the phrase
"most likely mechanism" is gone.

## Threshold and Verdict Confirmation

- **Both branch figures clear the 75% floor.** The original 83.82% clears it by +8.82 pp; the
  corrected 83.80% clears it by +8.80 pp. The correction moves the margin by 0.02 pp and changes no
  threshold outcome.
- **Neither figure is a regression against the baseline.** The baseline branch coverage is 83.80%
  (`covered_branches` 4190, `num_partial_branches` 556). The original post-change figure was 0.02 pp
  above it; the corrected figure is exactly equal to it. In neither reading does branch coverage
  decrease.
- **Line coverage is untouched by the correction.** Command 3 confirms the line figures remain
  91.82% / `percent_statements_covered` 91.82362065145136 / 12432 of 13539 statements on both sides,
  exactly as before the correction.
- **The changed-code analysis is untouched.** The section establishing that the diff's only Python
  files are test-tree modules, that no production Python file changed, and that changed-line regression
  is structurally zero, is unchanged.
- **The verdict line still reads PASS** (command 2, line 125: `**PASS.**`). The verdict was not
  weakened, qualified, or downgraded by the correction; it now rests on reproducible figures.
