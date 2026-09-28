# Final coverage delta — remediation cycle 1 — [P4-T7]

Timestamp: 2026-09-07T20-22
Task: [P4-T7]
Command: arithmetic over the `[P0-T7]` baseline values and the `[P4-T6]` post-change values (no command executed against the repository)
EXIT_CODE: 0

## 1. Inputs and their provenance

| Side | Baseline source | Post-change source |
|---|---|---|
| Baseline | `[P0-T7]`, `evidence/remediation-baseline/baseline-per-file-coverage.2026-09-07T19-37.md`, CI run `34145103168` of `.github/workflows/_poshqc.yml` | — |
| Post-change | — | `[P4-T6]`, `evidence/qa-gates/final-per-file-coverage.2026-09-07T20-21.md`, CI run `34158596238` of `.github/workflows/_poshqc.yml` at commit `3b4f10b9813191d59e6c886978c43ecbd2aea80d` |

## 2. Delta table

| # | Canonical copy | Baseline (percent) | Post-change (percent) | Difference | At or above 85.0000 | At or above baseline |
|---|---|---|---|---|---|---|
| 1 | `.claude/hooks/validate-bash.ps1` | 94.3182 | 94.4444 | **+0.1262** | yes | yes |
| 2 | `.codex/hooks/validate-bash.ps1` | 100.0000 | 100.0000 | **0.0000** | yes | yes |

Arithmetic shown:

- Claude: 94.4444 − 94.3182 = +0.1262
- Codex: 100.0000 − 100.0000 = 0.0000

## 3. Verdict

- **`.claude/hooks/validate-bash.ps1`: PASS.** 94.4444 is at or above the 85.0000 absolute
  threshold and above the 94.3182 baseline. The direction is the expected one: the R-1 edit adds
  two statements, and the new positive cases on the Claude side (`R1-C1`, `R1-C2`, `R1-C3`,
  `R1-C5`) execute both, so the covered count rises faster than the statement count. Post-change
  counts are 85 covered and 5 missed.
- **`.codex/hooks/validate-bash.ps1`: PASS.** 100.0000 is at or above the 85.0000 absolute
  threshold and equal to — therefore not below — the 100.0000 baseline. Post-change counts are 75
  covered and 0 missed, so both added statements are exercised by the `R1-X` counterparts
  (`R1-X1`, `R1-X2`, `R1-X3`, `R1-X5`). A single uncovered added statement on this side would have
  produced a value below 100.0000 and failed the no-regression condition while still clearing the
  absolute threshold; that did not occur.

Neither post-change value is below its baseline, so the no-regression condition is met on both
copies.

## 4. Remedy branch: not triggered

The plan's remedy applies only when a post-change value is at or above 85.0000 but below its
baseline. Neither row is below baseline, so the remedy does not fire. Specifically:

- No uncovered added statement was identified, because none exists on either side by the
  covered/missed counts above (Claude 5 missed lines are pre-existing, not added by R-1, as the
  covered count rose while the missed count is unchanged from the composition that yielded the
  94.3182 baseline; Codex has 0 missed).
- No pinning case is proposed, so no `R1-C` / `R1-X` case is added.
- The `tests` counts asserted in `[P1-T2]`, `[P1-T6]`, `[P2-T2]`, `[P2-T6]`, and `[P4-T4]` are
  therefore unchanged and require no plan revision.
- No re-dispatch of `[P4-T6]` is required.

The 85.0000 threshold was not lowered, the baseline comparison was not waived, and no shortfall was
recorded as an accepted regression, because there was no shortfall.

## 5. Scope of the assertion

No threshold is asserted in this artifact against any repository-wide aggregate. The
repository-wide figures recorded in `[P4-T6]` section 5 are context only. The two rows above are
the only gated values.

## Output Summary

Both canonical copies pass the `[P4-T7]` conditions.
`.claude/hooks/validate-bash.ps1`: 94.3182 → 94.4444, difference +0.1262, above threshold and above
baseline. `.codex/hooks/validate-bash.ps1`: 100.0000 → 100.0000, difference 0.0000, above threshold
and held at baseline. Remedy branch not triggered; no pinning case proposed and no plan revision
requested. Arithmetic EXIT_CODE 0.
