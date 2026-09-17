# Phase 0 — pre-remediation line-count ledger

Timestamp: 2026-09-17T13-56

Task: `[P0-T3]` of `remediation-plan.2026-09-17T12-29.md`

Command: `Get-Content -LiteralPath '<file>' | Measure-Object -Line | Select-Object -ExpandProperty Lines`
run once per path, for the seven paths listed in `[P0-T3]`.

A second, companion command was run in the same task to reconcile the measured values against the figures the
plan and the review artifacts cite:
`$lines = @(Get-Content -LiteralPath '<file>'); $lines | Measure-Object -Line | Select-Object -ExpandProperty Lines; $lines.Count; @($lines | Where-Object { $_ -match '^\s*$' }).Count`

EXIT_CODE: 0 for both commands, for all seven paths. No path was missing.

Output Summary:

## Measurement-spelling reconciliation (recorded before the verdicts)

The plan's stated command and the plan's cited figures measure two different quantities, and the difference is
not drift. `Get-Content` emits one string per line and `Measure-Object -Line` counts the lines *within* each
input string, so an empty string contributes zero. The pipeline therefore returns the **non-blank** line count,
not the physical line count. The figures the plan and the review artifacts cite are **physical** line counts.

Both quantities are recorded below for every path, and the blank-line count is recorded beside them so the
identity `non-blank + blank = physical` can be checked on each row by a third party. The identity holds on all
seven rows.

The 500-line cap in `.claude/rules/general-code-change.md` is a cap on file length, so the **physical** count
is the figure every cap comparison in this plan is evaluated against, here and at `[P1-T8]` and `[P2-T7]`.

## Ledger

| # | path | non-blank (plan's command) | physical | blank | physical <= 500 |
| --- | --- | --- | --- | --- | --- |
| 1 | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 377 | 431 | 54 | yes, 69 lines of headroom |
| 2 | `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 278 | 314 | 36 | yes, 186 lines of headroom |
| 3 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` | 377 | 431 | 54 | yes, 69 lines of headroom |
| 4 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 278 | 314 | 36 | yes, 186 lines of headroom |
| 5 | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | 383 | 454 | 71 | yes, 46 lines of headroom |
| 6 | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 397 | 445 | 48 | yes, 55 lines of headroom |
| 7 | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 403 | 453 | 50 | yes, 47 lines of headroom |

Seven integers are recorded per metric. None is a placeholder. Every physical value is at or under 500.

## Required comparisons

- **Parent hook, against the review-recorded figure of 431.** Measured physical count 431. Verdict:
  **MATCHES**. The non-blank count for the same file is 377, which differs from 431 by 54, and that 54 is
  exactly the file's blank-line count, so the difference is fully attributed to the measurement spelling and
  not to any change in the file.
- **Helpers sibling, against the review-recorded figure of 314.** Measured physical count 314. Verdict:
  **MATCHES**. The non-blank count is 278, differing by 36, which is exactly that file's blank-line count.

No citation drift is recorded for either file. The physical counts the plan and the review artifacts cite are
confirmed against the current tree.

## Corroboration of the plan's other cited line counts

The same reconciliation confirms the remaining line-count citations the plan relies on, each against the
physical measure:

- `[P1-T7]` and `[P1-T8]` state the TargetResolution suite measures 454 lines with 46 lines of headroom to the
  500-line cap. Measured: 454 physical. Confirmed.
- `[P1-T7]`'s header-comment correction states the two sibling suites measure 445 and 453 lines in the current
  tree. Measured: 445 and 453 physical. Confirmed, and the header comment's recorded figures of 431 and 419
  are therefore wrong as the plan states.
- `[P2-T7]` states pre-remediation values of 431 and 314 with 69 and 186 lines of headroom. Measured and
  computed: 431 with 69, and 314 with 186. Confirmed.
- Rows 1 and 3, and rows 2 and 4, are pairwise identical on all three metrics, which is consistent with the
  bundled mirrors being text-identical to the repository copies at the baseline. Text identity itself is
  asserted by hash at `[P3-T4]`, not here; an equal line count is not accepted as evidence of it.

Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; seven integers
are recorded per metric, each physical value at or under 500; and the `Output Summary:` states the measured
value for the parent hook with an explicit `MATCHES` verdict against 431 and for the helpers sibling with an
explicit `MATCHES` verdict against 314. Satisfied.
