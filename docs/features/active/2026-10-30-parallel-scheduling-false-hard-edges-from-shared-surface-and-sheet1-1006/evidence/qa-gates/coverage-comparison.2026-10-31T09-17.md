# TypeScript Coverage Comparison (Remediation Cycle 1, Issue #1006)

Timestamp: 2026-10-31T09-17
Command: comparison of evidence/remediation-baseline/ts-coverage.2026-10-31T09-12.md (baseline) with evidence/qa-gates/ts-coverage.2026-10-31T09-17.md (post-change), plus the FN/FNDA, DA, and BRDA records of both files in extensions/drm-copilot/coverage/lcov.info (awk extract in SCRATCH/issue-1006-tscov.sh)
EXIT_CODE: 0
Output Summary: No per-file figure falls below 85 line / 75 branch. demote module stays at 100/100; overlay module 99.57 -> 99.55 line and 96.15 -> 96.00 branch, caused only by the removal of fully covered lines and branches (uncovered counts unchanged at 2 lines and 4 branches). Repo-wide line 97.05 -> 97.05, branch 93.67 -> 93.67. unionStrings and applySharedSurfaceDemotion have no zero-hit line.

## Per-file

| File | Metric | Baseline | Post-change | Delta |
|---|---|---|---|---|
| `claude-blast-radius-overlay.ts` | Line | 99.57% (463/465) | 99.55% (442/444) | -0.02 pp (uncovered lines 2 -> 2) |
| `claude-blast-radius-overlay.ts` | Branch | 96.15% (100/104) | 96.00% (96/100) | -0.15 pp (uncovered branches 4 -> 4) |
| `claude-blast-radius-overlay-demote.ts` | Line | 100.00% (126/126) | 100.00% (157/157) | 0.00 pp |
| `claude-blast-radius-overlay-demote.ts` | Branch | 100.00% (26/26) | 100.00% (27/27) | 0.00 pp |

The overlay-module percentage change is arithmetic: the deleted local `unionStrings` was fully covered, so removing its 21 lines and 4 branches lowers the denominator while the uncovered set is unchanged. No changed line is uncovered.

## Repo-wide (extension `text-summary`)

| Metric | Baseline | Post-change | Delta |
|---|---|---|---|
| Lines | 97.05% (61640/63511) | 97.05% (61650/63521) | +0.00 pp |
| Branches | 93.67% (9392/10026) | 93.67% (9389/10023) | -0.00 pp (three fully covered branches removed) |

## Function-level coverage of the changed functions (`lcov.info`)

- `unionStrings` (`claude-blast-radius-overlay-demote.ts`): FNDA 85 calls; no `DA:<n>,0` record in the file.
- `applySharedSurfaceDemotion` (`claude-blast-radius-overlay-demote.ts`): FNDA 19 calls; no `DA:<n>,0` record in the file.
- `claude-blast-radius-overlay-demote.ts` has no zero-hit DA record and no zero-hit BRDA record.
- Zero-hit records in `claude-blast-radius-overlay.ts` are limited to the pre-existing `relativeToPosix` lines and four pre-existing branches; none is in `composeStringList` or `mergeValues`, the two call sites of `unionStrings`.

Result: no per-file decrease below the thresholds; every line of `unionStrings` and `applySharedSurfaceDemotion` is covered.
