# Expected Red — TypeScript After Phase 3 Production Changes (issue #472)

Timestamp: 2026-08-15T11-40

Command: `npm run typecheck` then `npm run test:unit` (working directory `extensions/drm-copilot/`)

EXIT_CODE: `npm run typecheck` = 0; `npm run test:unit` = 1

Output Summary:

## `npm run typecheck` — EXIT_CODE 0

`tsc -p ./ --noEmit` completed with no diagnostics. The two new modules
(`claude-blast-radius-derive-core.ts`, `claude-blast-radius-derive.ts`), the
`ClaudePushDownOptions.listEntries` addition, and the decorator composition all
compile cleanly.

## `npm run test:unit` — EXIT_CODE 1 (planned red state)

```
Test Suites: 1 failed, 182 passed, 183 total
Tests:       2 failed, 2493 passed, 2495 total
```

### The two failing tests are exactly the two the plan predicted

Both live in `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts`,
in the `issue #462 AC8: the published blast-radius default is generic` describe block:

| Failing test | Location | Assertion |
| --- | --- | --- |
| `publishes the pinned generic document with no drm-copilot-only entries` | `claude-config-carriage.test.ts:385` | `expect(published).toBe(SOURCE_BLAST_RADIUS)` |
| `overwrites the destination blast-radius rather than merging it` | `claude-config-carriage.test.ts:406-408` | `expect(seeded.readTextFile(...)).toBe(SOURCE_BLAST_RADIUS)` |

Both are equality-against-seed assertions: they require the published bytes to
equal the seeded `SOURCE_BLAST_RADIUS` constant. The decorator now writes the
derived document instead, so the assertions no longer hold.

The reported diff shows the derived document differing from the seed by exactly
the two location-bucket modules the seed still declares:

```
      "config": [
        "config/**"
-     ],
-     "docs": [
-       "docs/**"
-     ],
-     "tests": [
-       "tests/**"
      ]
    },
```

The seeded destination is the in-memory `/dest` root, which the real-filesystem
default lister cannot see, so the scan yields zero observations and the core
returns the no-signal floor (`claude-runtime`, `config`). This is the documented
tolerance behavior, not a defect.

### No other test fails

182 of 183 suites pass; 2493 of 2495 tests pass. The two failures above are the
complete failure set.

## Disposition

This red state is planned, is exempt from the toolchain restart rule per plan
binding constraint 6, and is resolved in Phase 5:

- [P5-T2] updates the `SOURCE_BLAST_RADIUS` seed to the corrected bundled document.
- [P5-T3] rewrites the genericity test as a property assertion with an injected fake lister.
- [P5-T4] amends the overwrite test to expect the derived document.

The failures must not be silenced by weakening production code.
