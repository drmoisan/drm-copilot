# TypeScript Fail-First Run on Pre-Fix Production Code (P2-T10)

Timestamp: 2026-09-26T19-57
Command: node run-jest.cjs test/lib/pr-context/issue-reference-pattern.test.ts test/lib/pr-context/collector-core-autoclose.test.ts --verbose (from extensions/drm-copilot)
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
- `Test Suites: 2 failed, 2 total`
- `Tests:       34 failed, 33 passed, 67 total`
- The output contains no `Test suite failed to run` line for either file; every failure is an assertion failure.
- Failed (27): `rejects %s from %s` for `#ISO-8601`, `#CR-1`, `ISO-8601`, `CR-1`, `UTF-8`, `SHA-256`, `AC-12`, `#12abc`, and `#12_` under each of `feature-docs-parsers`, `render-pr-helpers`, and `render-feature-excerpts`. The `#١٢` case passes pre-fix because the JavaScript `\d` class is ASCII-only.
- Failed (7): T1 `excludes scraped tokens from autoclose when gh is unavailable` (author-asserted block lists `#468`, `#622`, `#CR-1`, `#ISO-8601`); T2 `excludes a prose-cited closed issue from autoclose`; T3 `excludes a prose-cited open out-of-scope issue from autoclose`; T4 `excludes a closed pending primary without printing it (closed|(unknown)|pull|null)` (last section line is `- #622`).
- Passed (33): all 18 `accepts %s from %s` cases; `rejects` for `abc#12`, `#`, `#١٢`, and `""` under all three exports (12); T5 `keeps an open pending primary (open|OPEN)`; T6 `fetches each issue once`.
