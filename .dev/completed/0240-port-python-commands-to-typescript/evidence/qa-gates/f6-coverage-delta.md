# F6 Coverage Delta / Threshold Verification

Timestamp: 2026-06-26T02-23

Command:
- Baseline (P0-T3): `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (see `evidence/baseline/f6-ts-test-baseline.md`)
- Post-change (P3-T4): `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (see `evidence/qa-gates/f6-final-test-coverage.md`)

EXIT_CODE: 0

Output Summary:

## Overall `src/lib/**` coverage

| Metric | Baseline | Post-change | Delta |
|---|---|---|---|
| Line | 96.3% | 96.33% | +0.03% (no regression; slight improvement) |
| Branch | 88.06% | 87.87% | -0.19% |

Test counts: baseline 698 passed / 698 (60 suites); post-change 725 passed / 725 (64 suites).

## New / changed-code coverage (must meet line >= 85%, branch >= 75%)

| File | Line | Branch | Meets thresholds? |
|---|---|---|---|
| `src/lib/new-potential-bug-entry.ts` | 95.87% | 82.97% | Yes (line >= 85, branch >= 75) |
| `src/lib/new-potential-bug-entry-service-call.ts` | 100% | 100% | Yes |

No production-source split helper (`new-potential-bug-entry-helpers.ts`) was required; the port fit within `new-potential-bug-entry.ts` at 461 lines.

## Overall-branch delta rationale

The overall `src/lib/**` line coverage did not regress (96.3% -> 96.33%). The overall branch metric moved -0.19% (88.06% -> 87.87%). This is attributable solely to introducing a new production file whose own branch coverage (82.97%) is above the 75% floor but below the prior aggregate, which lowers the weighted average.

The new file's remaining uncovered branches are:
- `defaultWhichLookup` win32-only PATHEXT inner-loop `existsSync`-true path (lines 263-272),
- `buildDefaultAuthorProvider` default-seam glue (lines 348-351),
- `createBugEntry` default-seam `??` construction of a real `SubprocessRunner`/launcher when no seam is injected (lines 404-408).

These branches are production defaults for standalone/CLI-equivalent callers; covering them requires a real `git` subprocess or a real PATH/filesystem probe, which the hermetic unit-test policy (`.claude/rules/general-unit-test.md`: no external processes, no real filesystem, no temp files) prohibits. The service/MCP path always injects both seams, so these defaults are never exercised in the supported runtime path. Per the coverage-exclusion policy, the production file is not excluded; the uncovered host-bound default lines remain a visible, minimal cost in the metric.

## Verdict

All required coverage values are available and numeric (no placeholders). Both new files meet the line >= 85% and branch >= 75% thresholds. Overall line coverage shows no regression. The -0.19% overall branch movement is a weighted-average artifact of adding a new production file whose own branch coverage exceeds the floor, with the residual uncovered branches being non-hermetically-testable production-default glue. No coverage value is unavailable; the plan outcome is not remediation-required on coverage grounds.
