# promotion.ts Coverage Precheck (#623)

Timestamp: 2026-09-30T08-45
Command: npm --prefix extensions/drm-copilot run test:coverage; then NODE-LCOV against "extensions/drm-copilot/coverage/lcov.info"
EXIT_CODE: 0
Output Summary:
- `Tests:       3318 passed, 3318 total` (`Test Suites: 237 passed, 237 total`)
- promotion.ts: LH/LF=445/450 (line 98.89%); BRH/BRF=57/68 (branch 83.82%)
- potential-to-issue-service-call.ts: LH/LF=238/238 (line 100.00%); BRH/BRF=17/20 (branch 85.00%); DA223=2
- text-summary: Lines 97.02% (49787/51311); Branches 91.17% (7214/7912)

## NODE-LCOV output (verbatim; paths under extensions/drm-copilot/)

```
src/lib/potential-to-issue/potential-to-issue-service-call.ts LH/LF=238/238 BRH/BRF=17/20 DA223=2
src/lib/potential-to-issue/promotion.ts LH/LF=445/450 BRH/BRF=57/68 DA223=36
```
