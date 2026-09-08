# Final QA — Per-File Coverage Delta (cycle 2)

Task: `[P5-T8]`
Timestamp: 2026-09-07T22-56
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

**Result: PASS.** All seven rows carry a numeric baseline, a numeric post-change value, and a
difference at or above `0.0000`. The remediation branch of this task is **not** triggered.

Command: arithmetic reconciliation of two recorded evidence artifacts. No test or coverage command
was executed by this task.
EXIT_CODE: 0

## Sources

| Side | Task | Artifact | CI run | Measured commit |
|---|---|---|---|---|
| Baseline | `[P0-T9]` | `evidence/remediation-baseline/baseline-per-file-coverage.2026-09-07T21-05.md` | `34158596238` | `3b4f10b9813191d59e6c886978c43ecbd2aea80d` |
| Post-change | `[P5-T7]` | `evidence/qa-gates/final-per-file-coverage.2026-09-07T22-55.md` | `34181009673` | `06d166e0f47e4c377618384c8d2904ac0ab1a306` |

Both sides are figures from `.github/workflows/_poshqc.yml`, derived by summing the JaCoCo `LINE`
counters per `<sourcefile>` in the `powershell-coverage.xml` each run produced. The two sides are
therefore measured by the same method against the same declared denominator and are directly
comparable.

The seven baseline values in the table below were read from the `[P0-T9]` artifact on disk and
matched, value for value, against the figures the orchestrator supplied with this task. No
discrepancy was found on any of the seven rows.

## The seven-row delta table

| # | Canonical path | Baseline (run `34158596238`) | Post-change (run `34181009673`) | Difference |
|---|---|---|---|---|
| 1 | `.claude/hooks/hook-command-scanner.ps1` | 97.7778 | 97.8142 | **+0.0364** |
| 2 | `.codex/hooks/hook-command-scanner.ps1` | 100.0000 | 100.0000 | **+0.0000** |
| 3 | `.claude/hooks/enforce-epic-merge-gate.ps1` | 96.6102 | 96.7213 | **+0.1111** |
| 4 | `.codex/hooks/enforce-epic-merge-gate.ps1` | 98.5075 | 98.5915 | **+0.0840** |
| 5 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 92.7536 | 93.5897 | **+0.8361** |
| 6 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 95.5224 | 96.0000 | **+0.4776** |
| 7 | `.claude/hooks/validate-bash.ps1` | 94.4444 | 94.6237 | **+0.1793** |

## Acceptance check, row by row

| # | Numeric baseline | Numeric post-change | Difference >= 0.0000 | Post-change >= 85.0000 | Row |
|---|---|---|---|---|---|
| 1 | yes (97.7778) | yes (97.8142) | yes | yes | PASS |
| 2 | yes (100.0000) | yes (100.0000) | yes (exactly 0) | yes | PASS |
| 3 | yes (96.6102) | yes (96.7213) | yes | yes | PASS |
| 4 | yes (98.5075) | yes (98.5915) | yes | yes | PASS |
| 5 | yes (92.7536) | yes (93.5897) | yes | yes | PASS |
| 6 | yes (95.5224) | yes (96.0000) | yes | yes | PASS |
| 7 | yes (94.4444) | yes (94.6237) | yes | yes | PASS |

Seven of seven rows PASS. Six rows rose; row 2 held at exactly 100.0000, which satisfies the
at-or-above-zero condition (the file was already fully covered at baseline, so no increase was
available to it).

## No `BASELINE_NOT_REPORTED` marker appears

Run `34158596238` reports a `LINE` counter for every one of the seven paths, including both scanner
paths, so a marker in any baseline column would be a recording error rather than a permitted
substitution. None appears. All seven baseline cells hold a number.

## Remediation branch not triggered

The task's remediation branch fires only if a row shows a negative difference. No row does, so:

- no pinning case was added to any suite,
- no `R2-` case name was created by this task,
- the `tests` counts recorded in `[P1-T7]`, `[P2-T8]`, `[P3-T9]`, and `[P4-T6]` are unchanged and
  required no update,
- no re-dispatch of `[P5-T7]` was required.

The 85.0000 threshold was not lowered, the baseline comparison was not waived, and no shortfall was
recorded as an accepted regression, because there was no shortfall.

## Preflight expectation corrected by observation

Preflight had flagged `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (row 6) as a row that
might go negative. It rose instead, from 95.5224 to 96.0000, a difference of +0.4776 — the
second-largest gain of the seven. Recorded so the flagged risk is visibly closed by measurement
rather than left as an open concern.

## TOOLCHAIN_SUBSTITUTION

The MCP test runner (`mcp__drm-copilot__run_poshqc_test`) was **deliberately not used** for any
coverage figure on either side of this table.

Reason: the MCP runner resolves its runsettings from the installed VS Code extension payload rather
than from this branch's checkout, so it cannot see this branch's `CodeCoverage.Path` entries —
including the two `hook-command-scanner.ps1` registrations at lines 253 and 255 of
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. A figure from that runner would be
measured against a different denominator from the baseline and would make the difference column
meaningless. `pwsh`, `powershell`, and `cmd` are not invocable from this session, so the CI dispatch
of `.github/workflows/_poshqc.yml` is the only valid route, and it is the route both sides used.

## Output Summary

Seven-row per-file coverage delta reconciled between CI run `34158596238` at commit `3b4f10b9`
(baseline) and CI run `34181009673` at commit `06d166e0` (post-change). Every row carries a numeric
baseline, a numeric post-change value, and a difference at or above `0.0000`: +0.0364, +0.0000,
+0.1111, +0.0840, +0.8361, +0.4776, +0.1793. All seven post-change values are at or above the
85.0000 floor. No `BASELINE_NOT_REPORTED` marker appears in any cell. The no-regression condition is
met on all seven rows, so the remediation branch is not triggered and no artifact test count required
updating. The row preflight flagged as a possible regression rose by +0.4776.
