# TypeScript Move-Verification Pass-After (#623)

Timestamp: 2026-09-30T08-39
Command: npm --prefix extensions/drm-copilot test -- promotion.move-verification
EXIT_CODE: 0
Output Summary: `Tests:       2 passed, 2 total` after the P3-T1 fix to promotion.ts. Both move-verification tests pass.

## Jest output (verbatim)

```
> drm-copilot@1.1.17 test
> node run-jest.cjs promotion.move-verification

Test Suites: 1 passed, 1 total
Tests:       2 passed, 2 total
Snapshots:   0 total
Time:        0.337 s, estimated 1 s
Ran all test suites matching promotion.move-verification.
```

## Per-test results (from the supplementary `--json` run recorded in ts-promotion-suites-pass-after.2026-09-30T08-39.md)

- passed :: promotePotential — post-move destination verification returns exit code 1 without a destination when the promoted file is missing after the move
- passed :: promotePotential — post-move destination verification returns exit code 0 with the destination when the promoted file exists after the move
