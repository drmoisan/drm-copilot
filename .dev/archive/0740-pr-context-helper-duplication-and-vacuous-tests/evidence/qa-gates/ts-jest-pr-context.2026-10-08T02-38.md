# Targeted pr-context Regression (P2-T5, AC-11, AC-5)

Timestamp: 2026-10-08T02-38
Command: cd extensions/drm-copilot && npx jest --config jest.config.cjs test/lib/pr-context
EXIT_CODE: 0
Output Summary: PASS. 0 failed. Test Suites 22 equals the P0-T14 count (22). Tests total 409 equals PRC_BASE_TOTAL (382) plus 27. The rewritten antisymmetry and transitivity tests (violations-array form, extended DOMAIN) pass.

```
Test Suites: 22 passed, 22 total
Tests:       409 passed, 409 total
```

Loop note: this command ran on loop pass 2 and again on loop pass 3, the final clean pass of P2-T1 through P2-T15 with no file changed (after the DEV-8 compaction of models.test.ts). Both passes gave identical results; the values above are from loop pass 3.
