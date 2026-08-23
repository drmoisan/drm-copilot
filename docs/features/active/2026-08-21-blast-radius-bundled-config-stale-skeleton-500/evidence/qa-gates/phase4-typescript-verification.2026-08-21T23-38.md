# Phase 4 TypeScript verification (Issue #500)

Timestamp: 2026-08-21T23:38:00Z
Issue: #500
Task: [P4-T5]

Command:

```
npm run test:unit
node run-jest.cjs --testPathPattern "claude-config-carriage"
```

(working directory: `extensions/drm-copilot`)

EXIT_CODE: 0

Output Summary:

## Targeted `claude-config-carriage` suite

```
Test Suites: 1 passed, 1 total
Tests:       16 passed, 16 total
Ran all test suites matching claude-config-carriage.
```

Zero failures. The 16 passing cases include both cases this phase depends on:

- the AC8 genericity case `publishes a document derived from the destination's own layout`, whose
  forbidden-substring list was narrowed by [P4-T1] from seven entries to five and whose rationale
  comment was rewritten by [P4-T2];
- the published-document assertion `publishes no claude-runtime module into a layout-free
  destination` added by [P1-T4], which failed before the fix and now passes.

## Full unit run

```
Test Suites: 195 passed, 195 total
Tests:       2656 passed, 2656 total
```

Zero failures.

## Ordering note

The plan's Phase 4 ordering is load-bearing and was followed: [P4-T1] and [P4-T2] narrowed the AC8
forbidden-substring list BEFORE [P4-T3] added `package-lock.json` and `poetry.lock` to
`SOURCE_BLAST_RADIUS`. `CARRIED_KEYS` in
`extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` copies
`shared_surfaces` verbatim into the published document, so the reverse order would have made the
un-narrowed list fail against the corrected constant.

## Toolchain stages run for this phase, in order

| Stage | Command | Exit code |
| --- | --- | --- |
| Format | `npm run format` | 0 (no file rewritten) |
| Lint | `npm run lint` | 0 |
| Type check | `npm run typecheck` | 0 |
| Test | `npm run test:unit` | 0 |

No stage failed and no stage rewrote a file, so no restart of the loop was required.
