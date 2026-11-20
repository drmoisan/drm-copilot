Timestamp: 2026-09-27T10-30

Source: extensions/drm-copilot/coverage/lcov.info produced by [P3-T4], `SF:src\lib\pr-context\collector-core.ts` block (line 27544).

Totals:
- LF: 386
- LH: 380
- Line coverage: 380/386 = 98.4456%
- BRF: 53
- BRH: 49
- Branch coverage: 49/53 = 92.4528%

Anchor-line (136) BRDA entries (two, per the discrepancy documented in verify-collector-core-coverage.2026-09-27T10-30.md):
- `BRDA:136,2,0,1` (hit count 1)
- `BRDA:136,3,0,52` (hit count 52)

Acceptance check:
- Every anchor-line `BRDA:` hit count is non-zero (1 and 52). PASS.
- Branch coverage (92.4528%) is strictly greater than the [P0-T13] baseline (90.3846%). PASS.
- Line coverage (98.4456%) is not less than the [P0-T13] baseline (98.4456%, unchanged). PASS.
- Both percentages meet or exceed the `jest.config.cjs` per-file `coverageThreshold` entry for `./src/lib/pr-context/collector-core.ts` (lines 85, branches 75): 98.4456% >= 85 and 92.4528% >= 75. PASS.
