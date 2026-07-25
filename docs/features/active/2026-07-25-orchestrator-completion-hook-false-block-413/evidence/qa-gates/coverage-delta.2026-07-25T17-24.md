# Coverage Delta and Threshold Verification (issue #413, [P6-T5])

Timestamp: 2026-07-25T17-24

Sources compared:

- Baseline: `../baseline/poshqc-test.2026-07-25T17-01.md` ([P0-T5])
- Post-change: `final-poshqc-test.2026-07-25T17-24.md` ([P6-T3])

Both sets of numbers were read from `artifacts/pester/powershell-coverage.xml`
(Pester `CoverageGutters` / JaCoCo) produced by the same command,
`Invoke-PoshQCTest -Root .`, at the repository root.

## Numeric comparison

| Metric | Baseline | Post-change | Delta |
|---|---|---|---|
| Overall INSTRUCTION covered % | **89.68%** (2,929 / 3,266) | **89.68%** (2,928 / 3,265) | **0.00 pp** |
| Overall LINE covered % | 90.22% (2,150 / 2,383) | 90.22% (2,150 / 2,383) | 0.00 pp |
| Per-file INSTRUCTION covered % (`.claude/hooks/validate-orchestrator-output.ps1`) | **93.30%** (167 covered / 12 missed, 179 total) | **93.26%** (166 covered / 12 missed, 178 total) | **-0.04 pp** |
| Per-file LINE covered % (same file) | 92.16% (94 covered / 8 missed) | 92.16% (94 covered / 8 missed) | 0.00 pp |
| Per-file INSTRUCTION **missed** count | 12 | 12 | **0** |
| Per-file LINE **missed** count | 8 | 8 | **0** |
| Tests passed / failed | 1,345 / 0 | 1,347 / 0 | +2 / 0 |

## Check (a) — Overall covered percentage >= 85%

Baseline 89.68%; post-change **89.68%**; threshold 85%
(`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`).

Margin above threshold: **+4.68 pp**. No change from baseline.

**Verdict: PASS.**

## Check (b) — Per-file percentage for the changed hook >= baseline (no regression on changed lines)

Baseline 93.30%; post-change **93.26%**; raw delta **-0.04 pp**.

The literal percentage is 0.04 pp lower, so this is reported explicitly rather than rounded
away. The cause is arithmetic, not a loss of test coverage:

- The fix **removes one command** from the file. The two-disjunct expression
  `($exitCode -ne 0) -or (-not [string]::IsNullOrWhiteSpace($outputText))` counted as two
  analyzed commands; the replacement `($exitCode -ne 0)` counts as one. The analyzed-command
  denominator therefore fell 179 -> 178, and the removed command had been a **covered** one,
  so the numerator fell 167 -> 166.
- The **missed count is unchanged at 12 instructions and 8 lines**. No command or line that
  was covered at baseline became uncovered. Removing a covered item from a set whose ratio is
  below 100% necessarily lowers the ratio slightly; that is the entire -0.04 pp.
- The per-file **LINE** percentage — the metric the coverage policy states in line terms — is
  **identical at 92.16%** before and after, with the same 94 covered / 8 missed split.
- The **changed lines are covered.** The `<line>` element for hook line 232
  (`$hasErrors = ($exitCode -ne 0)`) reports `mi=0 ci=2`, i.e. zero missed instructions. The
  file's missed line numbers are `140, 309, 313, 344, 345, 346, 347, 350`; none falls in the
  changed regions (docstring lines 165-176; comment and decision lines 228-233).

The governing rule is "Code changes or refactors must not reduce coverage for the lines that
were changed" (`.claude/rules/general-unit-test.md`) and "No regression on changed lines"
(`.claude/rules/quality-tiers.md`). The changed lines are fully covered, the missed counts are
unchanged, and the per-file line coverage is unchanged.

**Verdict: PASS** (no coverage regression on changed lines). The -0.04 pp instruction-ratio
movement is recorded transparently and is fully explained by the removal of one covered
command from the denominator.

## Check (c) — 75% branch-coverage gate

**Verdict: NOT MEASURABLE by this toolchain.**

`artifacts/pester/powershell-coverage.xml` is emitted by Pester's `CoverageGutters` (JaCoCo)
writer, whose counter set for this repository is **INSTRUCTION, LINE, METHOD, and CLASS only**.
No `BRANCH` counter is written at either the report level or the per-`<sourcefile>` level, so
the >= 75% branch-coverage gate in `.claude/rules/quality-tiers.md` cannot be evaluated
locally against a measured value. This was verified directly against both the baseline and the
post-change XML: the only `<counter type=...>` values present are `INSTRUCTION`, `LINE`,
`METHOD`, and `CLASS`.

Precedent for this recorded limitation:
`docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/baseline/poshqc-test-baseline.md`.

Per plan tasks [P0-T5], [P6-T3], and [P6-T5], the absent branch metric is a documented
tooling limitation and does **not** trigger the fail-closed evidence rule.

## Summary

| Check | Result |
|---|---|
| (a) Overall covered % >= 85% | **PASS** (89.68%, unchanged) |
| (b) Per-file % >= baseline / no regression on changed lines | **PASS** (changed line covered, missed counts unchanged, per-file line % unchanged; instruction ratio -0.04 pp from denominator shrink) |
| (c) Branch coverage >= 75% | **NOT MEASURABLE** (INSTRUCTION/LINE/METHOD/CLASS counters only; no BRANCH counter emitted) |

No numeric value required by [P6-T5] is missing or a placeholder, so no remediation is
required on coverage grounds.
