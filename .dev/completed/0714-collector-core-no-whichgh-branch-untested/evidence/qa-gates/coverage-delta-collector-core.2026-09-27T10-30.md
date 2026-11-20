Timestamp: 2026-09-27T10-30

Coverage delta for `extensions/drm-copilot/src/lib/pr-context/collector-core.ts`, comparing the [P0-T13] baseline against the [P3-T5] post-change measurement.

| Metric | Baseline ([P0-T13]) | Post-change ([P3-T5]) |
|---|---|---|
| LF | 386 | 386 |
| LH | 380 | 380 |
| Line % | 98.4456 | 98.4456 |
| BRF | 52 | 53 |
| BRH | 47 | 49 |
| Branch % | 90.3846 | 92.4528 |
| Anchor-line (136) `BRDA:` hit count(s) | `BRDA:136,2,0,0` -> 0 | `BRDA:136,2,0,1` -> 1; `BRDA:136,3,0,52` -> 52 |

Narrative: Branch coverage for `collector-core.ts` rose from 90.3846% to 92.4528%, a strict increase of 2.0682 percentage points, driven by the new test at `test/lib/pr-context/collector-core-default-resolver.test.ts` exercising the previously-untaken side of the `whichGh === undefined ? {} : { whichGh }` ternary (both anchor-line `BRDA:` entries in the post-change measurement report non-zero hit counts, versus the single zero-hit entry in the baseline). Line coverage is unchanged at 98.4456% (380/386 in both runs): no line-coverage regression occurred. The anchor line's `BRDA:` entry count itself grew from one to two entries between the two runs, which is documented as a v8 coverage-instrumentation discrepancy from the plan's single-entry assumption in `evidence/qa-gates/verify-collector-core-coverage.2026-09-27T10-30.md`; both post-change entries are non-zero, so the discrepancy does not affect this delta's conclusion.
