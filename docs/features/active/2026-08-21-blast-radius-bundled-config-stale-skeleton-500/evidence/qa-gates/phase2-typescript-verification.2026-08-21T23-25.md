# Phase 2 TypeScript verification (Issue #500)

Timestamp: 2026-08-21T23:25:00Z
Issue: #500
Task: [P2-T8]

Command:

```
npm run test:unit
node run-jest.cjs --testPathPattern "blast-radius-derive"
wc -l <the three paths below>
```

(working directory for both Jest invocations: `extensions/drm-copilot`; line counts measured from
the worktree root)

EXIT_CODE: 0

Output Summary:

## Full unit run

```
Test Suites: 195 passed, 195 total
Tests:       2656 passed, 2656 total
Snapshots:   0 total
```

Zero failures. The test count rose from the Phase 0 baseline of 2654 to 2656: the published-document
assertion added by [P1-T4] and the payload-module negative assertion added by [P2-T6]. The [P1-T4]
assertion, which failed before the fix and is recorded in
`evidence/regression-testing/typescript-regression-fail-before.2026-08-21T23-10.md`, now passes.

## Targeted run of the two suites named by [P2-T8]

```
Test Suites: 2 passed, 2 total
Tests:       61 passed, 61 total
Ran all test suites matching blast-radius-derive.
```

Both `blast-radius-derive-core` and `blast-radius-derive` pass.

## File-size compliance against the 500-line ceiling

| File | Lines | Headroom |
| --- | --- | --- |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` | 482 | 18 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | 472 | 28 |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | 468 | 32 |

All three counts are at or under 500. The derive-core test file moved from 478 to 482: it lost five
`claude-runtime` lines across six expectations and gained the [P2-T6] negative assertion block. The
derive test file moved from 476 to 472, losing four lines. The production module moved from 452 to
468, losing one constant entry and gaining the rewritten `@remarks` doc comment required by [P2-T2].

## Toolchain stages run before this verification, in order

| Stage | Command | Exit code |
| --- | --- | --- |
| Format | `npm run format` | 0 (no file rewritten) |
| Lint | `npm run lint` | 0 |
| Type check | `npm run typecheck` | 0 |
| Test | `npm run test:unit` | 0 |

No stage failed and no stage rewrote a file, so no restart of the loop was required.
