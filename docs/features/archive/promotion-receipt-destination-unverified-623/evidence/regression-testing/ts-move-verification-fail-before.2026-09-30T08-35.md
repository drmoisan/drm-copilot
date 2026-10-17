# TypeScript Move-Verification Fail-Before (#623)

Timestamp: 2026-09-30T08-35
Command: git diff --quiet 6e6ccd62792e0838bee7459a2b468de83ad5d408 -- extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts; npm --prefix extensions/drm-copilot test -- promotion.move-verification
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: promotion.ts unchanged against BASE_SHA (git diff --quiet exit 0). Jest exit 1 with `Tests:       1 failed, 1 passed, 2 total`. The failing test is `returns exit code 1 without a destination when the promoted file is missing after the move`; its first assertion expected 1 and received 0.

## git diff --quiet result

EXIT_CODE: 0 (production file unchanged)

## Jest output (verbatim, ANSI colour codes removed)

```
> drm-copilot@1.1.17 test
> node run-jest.cjs promotion.move-verification

FAIL test/lib/potential-to-issue/promotion.move-verification.test.ts
  ● promotePotential — post-move destination verification › returns exit code 1 without a destination when the promoted file is missing after the move

    expect(received).toBe(expected) // Object.is equality

    Expected: 1
    Received: 0

      48 |
      49 |     // Assert
    > 50 |     expect(outcome.exitCode).toBe(1);
         |                              ^
      51 |     expect(outcome.destination).toBeUndefined();

      at Object.<anonymous> (test/lib/potential-to-issue/promotion.move-verification.test.ts:50:30)

Test Suites: 1 failed, 1 total
Tests:       1 failed, 1 passed, 2 total
Snapshots:   0 total
Time:        0.393 s
Ran all test suites matching promotion.move-verification.
```
