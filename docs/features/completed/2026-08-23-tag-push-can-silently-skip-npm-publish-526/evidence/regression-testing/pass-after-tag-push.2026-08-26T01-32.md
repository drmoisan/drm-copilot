# Pass-After Evidence — Tag Push Ordering and Inter-Push Gate (P3-T12)

Timestamp: 2026-08-26T01-32

Filename-stamp substitution: the plan fixes every evidence filename at
`.2026-08-24T13-10.md`. This execution ran on a different date, so the stamp
`2026-08-26T01-32` was substituted into that position per the plan's "Evidence
filename timestamps" rule. The path prefix and base name are unchanged.

Command: `mcp__drm-copilot__run_poshqc_test` (workspace root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3c3e2a8cfa4dbcd5`)

EXIT_CODE: 2

Output Summary:

## Target test file — `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1`

| Metric | Value |
|---|---|
| Passed | 21 |
| Failed | 0 |
| Skipped | 0 |

The failed count for that test file is 0, satisfying the first clause of the
P3-T12 acceptance condition.

## The named fail-before test now passes

The test `pushes the mcp-server tag before the extension tag`, added as an
`[expect-fail]` regression test by P1-T1 and recorded as failing in
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/regression-testing/fail-before-push-order.2026-08-25T23-46.md`,
**now passes**. It turned green when P3-T4 reversed the tag order in the loop of
`Invoke-ReleaseTagPushGuarded` so the mcp-server dependency tag is created and
pushed before the extension consumer tag.

Parsed from `artifacts/pester/pester-junit.xml`: the JUnit document contains no
`testcase` element carrying a `failure` child whose name is
`pushes the mcp-server tag before the extension tag`.

## Why EXIT_CODE is 2 and not 0

The non-zero exit code is a whole-suite figure, not a result for the target test
file. Exactly two tests fail suite-wide, and both are the Phase 4 `[expect-fail]`
regression tests added by P1-T3, which remain deliberately red until Phase 4
edits `.github/workflows/publish-mcp-npm.yml`:

- `publish-mcp-npm.yml workflow invariants.declares a pull_request trigger scoped to the mcp-server package and the workflow file` (delivered by P4-T1)
- `publish-mcp-npm.yml workflow invariants.guards the publish step on the tag ref and not on the event name` (delivered by P4-T2)

Both live in `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`, not in
the file this task measures. No other test in the suite fails.

## Whole-suite counts

| Metric | Phase 2 baseline | After Phase 3 | Delta |
|---|---|---|---|
| Passed | 3614 | 3620 | +6 |
| Failed | 3 | 2 | -1 |
| Skipped | 9 | 9 | 0 |
| Total | 3626 | 3631 | +5 |

The +5 total is the five tests Phase 3 adds to
`tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` (16 to 21). The -1
failure is the push-order test turning green. The arithmetic closes exactly
(3614 + 5 + 1 = 3620), so Phase 3 introduced no regression.

## Tests added or migrated in Phase 3

Added:

- `verifies the mcp-server tag with the registry check and the extension tag without it`
- `performs zero extension tag operations when the mcp verification does not resolve` (P3-T9)
- `returns non-zero when the extension post-push verification does not succeed` (P3-T6)
- `requires the Codex-pinned version itself to resolve after the mcp verification succeeds` (P3-T7)
- `aborts with VERSION_CONSUMED_ELSEWHERE and pushes nothing when the target version already resolves` (P3-T10)

Migrated (P3-T8), inside the context `confirmed run pushes both tags`, in the
test `derives both tags from the committed manifests and pushes both`: the
five-git-invocation total-count assertion was removed and the two order-free
regex matches on the joined push arguments were replaced with positional
assertions establishing mcp-first order (`$pushLines[0]` is the mcp-server push
and `$pushLines[1]` is the extension push, with the push count asserted at 2).
No assertion on a total of five git invocations and no assertion of
extension-first ordering remains anywhere in the file.
