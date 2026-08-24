# Expected Red — TypeScript After Phase 4 Derivation Tests (issue #472)

Timestamp: 2026-08-15T11-55

Command: `npm run test:unit` (working directory `extensions/drm-copilot/`)

EXIT_CODE: 1

Output Summary:

```
Test Suites: 1 failed, 184 passed, 185 total
Tests:       2 failed, 2550 passed, 2552 total
Time:        2.459 s
```

## Both new derivation test files pass in full

| Test file | Suite result | Tests |
| --- | --- | --- |
| `test/lib/push-down/blast-radius-derive-core.test.ts` | PASS | 43 passed, 43 total |
| `test/lib/push-down/blast-radius-derive.test.ts` | PASS | 14 passed, 14 total |

Verified by targeted runs (`npx jest test/lib/push-down/blast-radius-derive-core.test.ts` exit 0; `npx jest test/lib/push-down/blast-radius-derive.test.ts` exit 0) and by the aggregate suite count, which rose from 183 suites / 2495 tests at [P3-T5] to 185 suites / 2552 tests here — an increase of exactly the two new files and their 57 tests.

## The only failures are the two pre-existing tests slated for the Phase 5 rewrite

```
● issue #462 AC8: the published blast-radius default is generic › publishes the pinned generic document with no drm-copilot-only entries
● issue #462 AC8: the published blast-radius default is generic › overwrites the destination blast-radius rather than merging it
```

Both live in `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts`
and both are equality-against-seed assertions on the published blast-radius
document. The failure set is unchanged from [P3-T5]; Phase 4 added no new
failure.

## Disposition

This red state is planned and is exempt from the toolchain restart rule per plan
binding constraint 6. Phase 5 resolves it:

- [P5-T1] compacts the carriage test file below the size ceiling.
- [P5-T2] updates the `SOURCE_BLAST_RADIUS` seed to the corrected bundled document.
- [P5-T3] rewrites the genericity test as a property assertion.
- [P5-T4] amends the overwrite test to expect the derived document.
- [P5-T5] verifies a clean, zero-failure full unit run.

## Deviation recorded for the [P4-T2] guard-trip case

The plan's [P4-T2] text names "a guard trip raises before writing and leaves the
destination file untouched" as a decorator-level case. Implementation established
that a guard trip is **unreachable through the composed decorator**: the scanner
prunes `docs` and `tests` by name (algorithm step 1) before either can become an
observation, so the core is never offered a `docs/**` or `tests/**` glob, and a
root-level manifest is categorically excluded so `**` is likewise unreachable.

The pruning is correct and must not be relaxed: a destination workspace that
legitimately contains `docs/package.json` must publish successfully rather than
fail the push. Weakening the pruning to make the guard reachable would introduce
a functional defect.

The decorator test file therefore covers the guard-trip contract in three parts,
none of which weakens production code:

1. `never offers a location bucket to the guard, so no push can trip it` — a
   destination carrying `docs/package.json` and `tests/package.json` publishes
   successfully with neither bucket in the emitted map and no forbidden glob in
   the published text.
2. `emits no universal glob for a manifest at the destination root` — the
   root-manifest negative-path case AC9 names explicitly.
3. `still surfaces a guard trip as a raise before any write` — the core is
   invoked with an observation set the scanner cannot produce; the raise occurs
   during derivation and the pre-existing destination bytes are unchanged.

The guard's own raise-before-return behavior is additionally asserted directly in
`blast-radius-derive-core.test.ts` (three cases: parametrized `docs`/`tests`
trips, and an error-field assertion naming the offending module and glob).
