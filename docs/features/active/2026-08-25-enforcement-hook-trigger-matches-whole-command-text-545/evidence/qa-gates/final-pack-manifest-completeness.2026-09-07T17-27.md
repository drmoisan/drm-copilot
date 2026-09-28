# [P13-T10] Final re-run of the two pack-manifest completeness suites

Timestamp: 2026-09-07T17-27

Command:

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q
npx jest --runTestsByPath test/lib/push-down/claude-pack-manifest-completeness.test.ts    # cwd: extensions/drm-copilot
```

EXIT_CODE: 0

Both commands exited 0. Each exit code was captured directly from `$?` with no pipe in the command
line, so no pipeline stage could mask a non-zero status.

TOOLCHAIN_SUBSTITUTION: none required. Both suites are named in [P4-T13] with these exact commands
and both were run as written. `poetry` and `npx` are invocable in this session; only `pwsh` is not,
and neither of these suites is a PowerShell suite.

## Results, one row per suite

| # | Suite | Command | Passed | Failed | Exit code | Wall time |
|---|---|---|---|---|---|---|
| 1 | `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | `poetry run pytest ... -q` | 2 | 0 | 0 | 0.05 s |
| 2 | `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` | `npx jest --runTestsByPath ...` | 16 | 0 | 0 | 0.339 s |

Verbatim output:

```
..                                                                       [100%]
2 passed in 0.05s
```

```
Test Suites: 1 passed, 1 total
Tests:       16 passed, 16 total
Snapshots:   0 total
Time:        0.339 s, estimated 1 s
Ran all test suites within paths "test/lib/push-down/claude-pack-manifest-completeness.test.ts".
```

**Zero failed tests across both suites.**

## Named cases and their observed results

### Suite 1, the Python side

Collected node IDs, from `--collect-only`:

| Case | Observed |
|---|---|
| `test_bundled_claude_files_are_listed_in_some_pack_manifest` | **Passed** |
| `test_documented_exceptions_remain_absent_from_every_manifest` | **Passed** |

The first is the case [P4-T13] names explicitly. It is the mechanism that observes the [P4-T7]
registration: it enumerates the bundled `.claude` tree from disk and requires every bundled file to
appear in some pack manifest, so a parser file added to the bundle without a manifest entry fails it.
The second is its paired negative: it requires the documented exceptions to stay absent from every
manifest, so the first case cannot be satisfied by a manifest that simply lists everything.

### Suite 2, the TypeScript twin

Both cases sit under the `describe` block
`claude pack manifest completeness (real filesystem)`:

| Case | Observed |
|---|---|
| `lists every bundled .claude agent, skill, and hook file in some pack manifest` | **Passed** |
| `lists every bundled config/ file in some pack manifest` | **Passed** |

The first is the TypeScript twin of the Python case named above and is the title [P4-T13] requires
be recorded. The suite reports 16 passing tests in total: the two real-filesystem cases above plus
14 unit cases over the manifest-parsing helpers in the same file.

## What this confirms about the change

The four parser files added to the two bundle trees by this change —
`hook-command-scanner.ps1` and `hook-command-invocation.ps1` under
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and under
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` — are each listed
in a pack manifest. Both suites enumerate the bundled tree from disk rather than from a fixture, so
an unregistered bundled file fails them regardless of what any manifest claims. Their passing is the
independent observation that the [P4-T7] pack-manifest registration landed, distinct from the
[P4-T12] registration inventory, which counts entries in the manifests rather than files on disk.

Together with `evidence/qa-gates/final-codex-contract-suite.2026-09-07T17-18.md` ([P13-T6]) and
`evidence/qa-gates/final-python-contracts.2026-09-07T17-14.md` ([P13-T5]), this completes the
evidence set for AC-15: the Codex byte-identity assertion, the Claude content-equality assertion,
the shared-module pack-manifest assertion, and both bundled-tree pack-manifest completeness suites
are all green in the same change. **AC-15 is checked off in `spec.md` by this task.**

## Comparison against [P4-T13]

`evidence/qa-gates/pack-manifest-completeness.2026-09-07T12-56.md` recorded the same two suites
green at the point the registration landed in Phase 4. This re-run reproduces that result at the
final commit, after eleven further phases of edits, with the same passed counts of 2 and 16 and no
failures.

## Output Summary

Both pack-manifest completeness suites re-run and **both report zero failed tests**:
`test_push_down_claude_pack_manifest_completeness.py` at 2 passed / 0 failed, exit 0, and
`claude-pack-manifest-completeness.test.ts` at 16 passed / 0 failed, exit 0. Each suite is named
above with its observed result, and the two cases [P4-T13] requires by name —
`test_bundled_claude_files_are_listed_in_some_pack_manifest` and the TypeScript twin titled
`lists every bundled .claude agent, skill, and hook file in some pack manifest` — are recorded
individually as passing. AC-15 is discharged and checked off.
