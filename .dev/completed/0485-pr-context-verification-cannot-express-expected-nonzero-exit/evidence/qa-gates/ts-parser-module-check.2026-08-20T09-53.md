# Gate — TypeScript parser file sizes and suite result

Timestamp: 2026-08-20T09-53

Task: [P4-T11]

Command: pwsh -NoProfile -Command "(Get-Content extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts).Count; (Get-Content extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts).Count" ; (from `extensions/drm-copilot`) npm run test:unit -- test/lib/pr-context/verification-evidence.test.ts
EXIT_CODE: 0

Both commands are recorded on the single `Command:` line above rather than on two lines, because a
duplicated required key resolves differently in the two parsers (Python last-wins,
TypeScript first-wins) and this artifact is itself inside the corpus the [P7-T4] cross-runtime
comparison reads. One key line per artifact keeps that comparison free of a divergence this change
does not fix.

## File sizes after the Phase 4 change

| File | Lines | 500-line limit |
| --- | --- | --- |
| `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | 303 | within (197 lines of headroom) |
| `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` | 456 | within (44 lines of headroom) |

Baseline counts recorded at [P0-T4] were 248 and 219, so the parser grew by 55 lines (the optional
field constant, the record member with its doc comment, the exported `normalizeResult` helper, the
separate accept `if`, the expectation read, the third unparseable branch, and the three
`expectedExitCode` assignments) and the test module grew by 237 lines (the eleven-shape table and
the eight named tests).

## Suite result

```
Test Suites: 1 passed, 1 total
Tests:       28 passed, 28 total
```

- Tests passed: 28 (the 9 pre-existing plus the 11 parametrized shape cases plus the 8 named tests)
- Tests failed: 0

Output Summary: Both files are within the 500-line limit — `verification-evidence.ts` at 303 lines
and `verification-evidence.test.ts` at 456 lines. The suite passes with exit code 0: 28 of 28 tests,
0 failures, comprising the 9 pre-existing tests (unedited), the 11 transcribed shape cases, and the
8 named tests fixed by `spec.md`.
