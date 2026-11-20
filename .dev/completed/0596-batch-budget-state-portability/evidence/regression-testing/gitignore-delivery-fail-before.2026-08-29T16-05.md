# [P5-T2] Fail-before: destination-gitignore delivery suite

Timestamp: 2026-08-29T21-51

Command: `cd extensions/drm-copilot && npx jest test/lib/push-down/claude-gitignore-delivery.test.ts`

Absolute-path prefix actually used: the plan's `cd extensions/drm-copilot` was executed as
`cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5/extensions/drm-copilot`,
because the executing session's working directory is not the target worktree. No other part of the
command text was altered. The prohibited flags `--passWithNoTests`, `--onlyChanged`, and
`--lastCommit` were not used.

EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary: The suite fails before the call-site change, as predicted. Jest reported
`Test Suites: 1 failed, 1 total` and `Tests:       3 failed, 1 passed, 4 total`. Three of the four
cases are fail-before witnesses; the fourth is an invariance assertion that also holds when nothing
is written and therefore passes by construction at this point.

## Result lines, quoted verbatim

```
Test Suites: 1 failed, 1 total
Tests:       3 failed, 1 passed, 4 total
Snapshots:   0 total
Time:        0.743 s
Ran all test suites matching test/lib/push-down/claude-gitignore-delivery.test.ts.
```

## Failure showing the destination `.gitignore` was not produced

The two delivery cases fail on the existence assertion, which is the direct demonstration that no
destination `.gitignore` was written:

```
  ● issue #596: the Claude push-down delivers destination-side ignore configuration › delivers the managed ignore block to the destination on an unscoped publish

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: false

     51 |
     52 |     // Assert
    > 53 |     expect(seeded.isFile(DEST_GITIGNORE)).toBe(true);
        |                                           ^
     54 |     expect(seeded.readTextFile(DEST_GITIGNORE)).toBe(MANAGED_BLOCK);
     55 |   });
     56 |

      at Object.<anonymous> (test/lib/push-down/claude-gitignore-delivery.test.ts:53:43)
```

```
  ● issue #596: the Claude push-down delivers destination-side ignore configuration › delivers the managed ignore block to the destination on a pack-scoped publish

    expect(received).toBe(expected) // Object.is equality

    Expected: true
    Received: false

     63 |
     64 |     // Assert
    > 65 |     expect(seeded.isFile(DEST_GITIGNORE)).toBe(true);
        |                                           ^
     66 |     expect(seeded.readTextFile(DEST_GITIGNORE)).toBe(MANAGED_BLOCK);
     67 |   });
     68 |

      at Object.<anonymous> (test/lib/push-down/claude-gitignore-delivery.test.ts:65:43)
```

The second-publish case fails at its first `readTextFile` of the destination `.gitignore`
immediately after the first publish, exactly as the plan predicted, rather than reaching its
sentinel-occurrence assertion:

```
  ● issue #596: the Claude push-down delivers destination-side ignore configuration › leaves the destination gitignore byte-identical and unwritten on a second publish

    InMemoryPushDownFileSystem: missing file /dest/.gitignore

      at InMemoryPushDownFileSystem.readTextFile (test/lib/push-down/push-down.test-helpers.ts:123:13)
      at Object.<anonymous> (test/lib/push-down/claude-gitignore-delivery.test.ts:75:31)
```

## Observed versus predicted

| Prediction in [P5-T2] | Observed | Match |
| --- | --- | --- |
| Non-zero exit code | 1 | yes |
| `Tests:` line shows `3 failed, 1 passed, 4 total` | `Tests:       3 failed, 1 passed, 4 total` | yes |
| Unscoped delivery case fails (destination file absent) | fails at `isFile` returning false | yes |
| Pack-scoped delivery case fails (destination file absent) | fails at `isFile` returning false | yes |
| Second-publish case fails at its first `readTextFile` with `InMemoryPushDownFileSystem: missing file <path>`, not at the sentinel assertion | fails with `InMemoryPushDownFileSystem: missing file /dest/.gitignore` raised from `push-down.test-helpers.ts:123` and reached from test line 75, the first `readTextFile` | yes |
| `preserves unrelated destination entries and their relative order` passes before the fix and is not a fail-before witness | 1 passed; it is the only non-failing case | yes |

The observed failing-test set is the predicted set, with no divergence.

Failing test names observed:

- `delivers the managed ignore block to the destination on an unscoped publish`
- `delivers the managed ignore block to the destination on a pack-scoped publish`
- `leaves the destination gitignore byte-identical and unwritten on a second publish`

Passing test name observed:

- `preserves unrelated destination entries and their relative order`
