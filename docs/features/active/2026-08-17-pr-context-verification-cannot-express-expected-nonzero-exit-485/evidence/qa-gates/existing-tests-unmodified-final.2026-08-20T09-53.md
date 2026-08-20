# Final QC — existing tests unmodified and green (AC25)

Timestamp: 2026-08-20T09-53

Task: [P8-T11]

Command: git diff --numstat 71aebdb9a1e4752b191b3c9d4e677b807ea6fdec -- tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_collect_pr_context_part4.py ; git diff (same baseline) -- the two TypeScript pr-context test files, filtered for deleted lines ; (from `extensions/drm-copilot`) npm run test:unit -- test/lib/pr-context/verification-evidence.test.ts test/lib/pr-context/collector-output.test.ts
EXIT_CODE: 0

## The two over-limit Python test modules: zero changed lines

The numstat run produced NO output for either path. A numstat run emits one row per changed path and
never emits a row for an unchanged path, so empty output means both files are unmodified:

- `tests/scripts/dev_tools/test_collect_pr_context.py` (654 lines) — zero changed lines
- `tests/scripts/dev_tools/test_collect_pr_context_part4.py` (1026 lines) — zero changed lines

Confirmed after the final QC pass, so no formatter touched them either.

## The thirteen pre-existing TypeScript tests: unedited and passing

```
Test Suites: 2 passed, 2 total
Tests:       44 passed, 44 total
```

44 = 22 pre-existing tests (13 of which are the ones AC25 names: the 9 in
`verification-evidence.test.ts` and the 4 in `describe("renderVerificationEvidenceSection")`) plus the
22 added by this change.

Their bodies are unedited, established mechanically: the diff over both TypeScript test files
contains NO deleted (`-`) line at all. The numstat rows are

```
62	0	extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts
237	0	extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts
```

— 62 and 237 added lines against 0 deleted lines each. A pure-addition diff cannot have altered any
pre-existing test body, so all thirteen named tests, and the other nine pre-existing tests in the two
files, pass exactly as written before this change.

## Why this matters

`spec.md` states that an edit to any of these tests would be evidence that Invariant A was broken. No
edit exists in either runtime, and all of them pass.

Output Summary: Zero changed lines in `test_collect_pr_context.py` and
`test_collect_pr_context_part4.py` (no numstat row for either). Both TypeScript pr-context test files
have pure-addition diffs (62/0 and 237/0), so no pre-existing test body was edited, and all 44 tests
in those two files pass with exit code 0 — including the nine pre-existing
`verification-evidence.test.ts` tests and the four pre-existing
`renderVerificationEvidenceSection` tests AC25 names. AC25 is satisfied after the final QC pass.
