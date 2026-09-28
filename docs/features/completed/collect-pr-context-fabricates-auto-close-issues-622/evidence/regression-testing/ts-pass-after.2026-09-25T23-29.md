# TypeScript Pass-After Run on Fixed Production Code (P5-T2)

Timestamp: 2026-09-26T20-35
Command: node run-jest.cjs test/lib/pr-context/issue-reference-pattern.test.ts test/lib/pr-context/collector-core-autoclose.test.ts --verbose (from extensions/drm-copilot)
EXIT_CODE: 0

Output Summary:
- `Test Suites: 2 passed, 2 total`
- `Tests:       67 passed, 67 total`
- The output contains no `Test suite failed to run` line.
- In this non-interactive shell the `--verbose` run printed only the summary block, not per-test lines. Per-test status was therefore read from a supplementary run of the same two test files with `--json --outputFile=<session scratch file>` (same selection, exit code 0, 67 passed, 0 not passed). Its `collector autoclose derivation` results:
  - passed | excludes scraped tokens from autoclose when gh is unavailable (T1)
  - passed | excludes a prose-cited closed issue from autoclose (T2)
  - passed | excludes a prose-cited open out-of-scope issue from autoclose (T3)
  - passed | excludes a closed pending primary without printing it (closed) (T4)
  - passed | excludes a closed pending primary without printing it ((unknown)) (T4)
  - passed | excludes a closed pending primary without printing it (pull) (T4)
  - passed | excludes a closed pending primary without printing it (null) (T4)
  - passed | keeps an open pending primary (open) (T5)
  - passed | keeps an open pending primary (OPEN) (T5)
  - passed | fetches each issue once (T6)
- The 27 rejection cases and 7 collector cases that failed in [P2-T10] (evidence/regression-testing/ts-fail-first.2026-09-25T23-29.md) are all within the 67 passed.
